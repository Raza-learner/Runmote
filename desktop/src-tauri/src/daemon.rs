use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::sync::Mutex;
use std::{fs, thread, time::Duration};

use serde::Serialize;

fn ensure_relay_env() {
    // If the daemon token is already set, nothing to do.
    if std::env::var("ACP_DAEMON_TOKEN").is_ok() {
        return;
    }

    // The relay URL and token are injected into the install script by
    // the Cloudflare Worker. We download it and parse the values.
    // Writing to a tmp file avoids PowerShell inline quoting issues.
    let tmp = std::env::temp_dir().join("runmote-getcfg.ps1");
    let _ = fs::write(&tmp, br#"
$r = irm https://runmote.dev/install.ps1/dev -UseBasicParsing
foreach ($line in $r -split "`n") {
  if ($line -match 'ACP_DAEMON_TOKEN = "(.+)"') { Write-Output ("TOKEN=" + $matches[1]) }
  if ($line -match 'ACP_RELAY_URL = "(.+)"')   { Write-Output ("RELAY=" + $matches[1]) }
}
"#);
    let output = std::process::Command::new("powershell")
        .args(["-ExecutionPolicy", "Bypass", "-File", &tmp.to_string_lossy()])
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::null())
        .output()
        .ok();
    let _ = fs::remove_file(&tmp);

    if let Some(o) = output {
        if o.status.success() {
            let stdout = String::from_utf8_lossy(&o.stdout);
            for line in stdout.lines() {
                if let Some(val) = line.strip_prefix("TOKEN=") {
                    let val = val.trim();
                    if !val.is_empty() {
                        std::env::set_var("ACP_DAEMON_TOKEN", val);
                    }
                }
                if let Some(val) = line.strip_prefix("RELAY=") {
                    let val = val.trim();
                    if !val.is_empty() && std::env::var("ACP_RELAY_URL").is_err() {
                        std::env::set_var("ACP_RELAY_URL", val);
                    }
                }
            }
        }
    }
}

const PID_FILE: &str = "runmote-daemon.pid";
const LOG_FILE: &str = "runmote-daemon.log";
const ERR_FILE: &str = "runmote-daemon.err";
const CODE_FILE: &str = "runmote-pairing-code.txt";

#[derive(Clone, Serialize)]
pub struct DaemonStatus {
    pub running: bool,
    pub pid: Option<u32>,
}

pub struct DaemonManager {
    pub acp_path: PathBuf,
    pub child: Mutex<Option<Child>>,
}

impl DaemonManager {
    pub fn new(acp_path: PathBuf) -> Self {
        Self {
            acp_path,
            child: Mutex::new(None),
        }
    }

    fn temp_dir() -> PathBuf {
        std::env::temp_dir()
    }

    fn pid_file(&self) -> PathBuf {
        Self::temp_dir().join(PID_FILE)
    }

    fn log_file(&self) -> PathBuf {
        Self::temp_dir().join(LOG_FILE)
    }

    fn err_file(&self) -> PathBuf {
        Self::temp_dir().join(ERR_FILE)
    }

    fn code_file() -> PathBuf {
        Self::temp_dir().join(CODE_FILE)
    }

    fn find_python(&self) -> Result<PathBuf, String> {
        #[cfg(target_os = "windows")]
        let venv_python = self.acp_path.join(".venv").join("Scripts").join("python.exe");
        #[cfg(not(target_os = "windows"))]
        let venv_python = self.acp_path.join(".venv").join("bin").join("python");

        if venv_python.exists() {
            return Ok(venv_python);
        }

        // No .venv — run uv sync to create it and install deps.
        eprintln!("No .venv found at {:?}. Running uv sync...", self.acp_path);
        let uv = if cfg!(target_os = "windows") { "uv.exe" } else { "uv" };
        let status = std::process::Command::new(uv)
            .args(["sync", "--directory", &self.acp_path.to_string_lossy()])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::piped())
            .status()
            .map_err(|e| format!("uv not found on PATH (install from https://docs.astral.sh/uv): {}", e))?;

        if !status.success() {
            return Err(format!(
                "uv sync failed. Run 'cd {} && uv sync' manually and retry.",
                self.acp_path.display()
            ));
        }

        if venv_python.exists() {
            Ok(venv_python)
        } else {
            Err(format!(
                ".venv still missing after uv sync. Run 'cd {} && uv sync' manually.",
                self.acp_path.display()
            ))
        }
    }

    fn kill_pid(pid: u32) {
        #[cfg(target_os = "windows")]
        {
            let _ = Command::new("taskkill")
                .args(["/PID", &pid.to_string(), "/F"])
                .stdin(Stdio::null())
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn();
        }
        #[cfg(not(target_os = "windows"))]
        {
            let _ = Command::new("kill")
                .args(["-9", &pid.to_string()])
                .stdin(Stdio::null())
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn();
        }
    }

    fn process_alive(pid: u32) -> bool {
        #[cfg(target_os = "windows")]
        {
            let output = Command::new("tasklist")
                .args(["/FI", &format!("PID eq {}", pid), "/NH"])
                .stdout(Stdio::piped())
                .stderr(Stdio::null())
                .output()
                .ok();
            if let Some(output) = output {
                let stdout = String::from_utf8_lossy(&output.stdout);
                stdout.contains(&pid.to_string())
            } else {
                false
            }
        }
        #[cfg(not(target_os = "windows"))]
        {
            std::path::Path::new(&format!("/proc/{}", pid)).exists()
        }
    }

    pub fn status(&self) -> DaemonStatus {
        let mut guard = self.child.lock().unwrap();

        if let Some(child) = guard.as_mut() {
            match child.try_wait() {
                Ok(Some(_)) => {
                    *guard = None;
                }
                Ok(None) => {
                    return DaemonStatus {
                        running: true,
                        pid: Some(child.id()),
                    };
                }
                Err(_) => {
                    *guard = None;
                }
            }
        }

        let pid_file = self.pid_file();
        if let Ok(pid_str) = fs::read_to_string(&pid_file) {
            if let Ok(pid) = pid_str.trim().parse::<u32>() {
                if Self::process_alive(pid) {
                    return DaemonStatus {
                        running: true,
                        pid: Some(pid),
                    };
                }
            }
        }

        if self.log_file().exists() {
            if let Ok(metadata) = self.log_file().metadata() {
                if let Ok(modified) = metadata.modified() {
                    if let Ok(elapsed) = modified.elapsed() {
                        if elapsed.as_secs() < 120 {
                            return DaemonStatus {
                                running: true,
                                pid: None,
                            };
                        }
                    }
                }
            }
        }

        DaemonStatus {
            running: false,
            pid: None,
        }
    }

    pub fn start(&self) -> Result<DaemonStatus, String> {
        if self.status().running {
            return Ok(self.status());
        }

        // Auto-configure relay URL + token from the public config endpoint.
        ensure_relay_env();

        let _ = fs::remove_file(self.pid_file());

        let log_file = self.log_file();
        let err_file = self.err_file();

        let log = fs::File::create(&log_file)
            .map_err(|e| format!("Failed to create log file: {}", e))?;
        let err = fs::File::create(&err_file)
            .map_err(|e| format!("Failed to create err file: {}", e))?;

        let python = self.find_python()?;

        #[cfg(target_os = "windows")]
        let child = {
            use std::os::windows::process::CommandExt;
            const CREATE_NO_WINDOW: u32 = 0x08000000;
            Command::new(&python)
                .args(["-m", "src.daemon.main"])
                .current_dir(&self.acp_path)
                .stdout(log.try_clone().map_err(|e| e.to_string())?)
                .stderr(err)
                .creation_flags(CREATE_NO_WINDOW)
                .spawn()
                .map_err(|e| format!("Failed to start daemon: {}", e))?
        };

        #[cfg(not(target_os = "windows"))]
        let child = {
            Command::new(&python)
                .args(["-m", "src.daemon.main"])
                .current_dir(&self.acp_path)
                .stdout(log.try_clone().map_err(|e| e.to_string())?)
                .stderr(err)
                .spawn()
                .map_err(|e| format!("Failed to start daemon: {}", e))?
        };

        let pid = child.id();
        fs::write(self.pid_file(), pid.to_string())
            .map_err(|e| format!("Failed to write PID file: {}", e))?;

        *self.child.lock().unwrap() = Some(child);

        thread::sleep(Duration::from_secs(1));

        Ok(DaemonStatus {
            running: true,
            pid: Some(pid),
        })
    }

    pub fn stop(&self) -> Result<DaemonStatus, String> {
        {
            let mut guard = self.child.lock().unwrap();
            if let Some(mut child) = guard.take() {
                let _ = child.kill();
                let _ = child.wait();
            }
        }

        if let Ok(pid_str) = fs::read_to_string(self.pid_file()) {
            if let Ok(pid) = pid_str.trim().parse::<u32>() {
                Self::kill_pid(pid);
            }
        }

        let _ = fs::remove_file(self.pid_file());
        let _ = fs::remove_file(self.log_file());
        let _ = fs::remove_file(self.err_file());
        let _ = fs::remove_file(Self::code_file());

        thread::sleep(Duration::from_millis(500));

        Ok(DaemonStatus {
            running: false,
            pid: None,
        })
    }
}

#[tauri::command]
pub fn daemon_status(state: tauri::State<'_, DaemonManager>) -> Result<DaemonStatus, String> {
    Ok(state.status())
}

#[tauri::command]
pub fn daemon_start(state: tauri::State<'_, DaemonManager>) -> Result<DaemonStatus, String> {
    state.start()
}

#[derive(Clone, Serialize)]
pub struct UninstallResult {
    pub daemon_stopped: bool,
    pub autostart_removed: bool,
    pub wrapper_removed: bool,
    pub config_cleaned: bool,
    pub temp_cleaned: bool,
}

fn home_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        std::env::var("USERPROFILE")
            .map(PathBuf::from)
            .unwrap_or_else(|_| PathBuf::from(r"C:\Users\Public"))
    }
    #[cfg(not(target_os = "windows"))]
    {
        std::env::var("HOME")
            .map(PathBuf::from)
            .unwrap_or_else(|_| PathBuf::from("/tmp"))
    }
}

fn config_dir() -> PathBuf {
    home_dir().join(".config").join("runmote")
}

fn user_bin_dir() -> PathBuf {
    home_dir().join(".local").join("bin")
}

fn disable_windows_autostart() {
    // Disable the scheduled task that auto-starts the daemon.
    // Without this, Task Scheduler's "restart on failure" policy
    // re-launches the daemon within 1 minute of stopping it.
    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("schtasks")
            .args(["/Change", "/TN", "Runmote Daemon", "/DISABLE"])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        // Also remove the Run registry key so it doesn't start at next login.
        let _ = std::process::Command::new("reg")
            .args([
                "delete",
                "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run",
                "/v",
                "Runmote Daemon",
                "/f",
            ])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
    }
}

#[tauri::command]
pub fn daemon_stop(state: tauri::State<'_, DaemonManager>) -> Result<DaemonStatus, String> {
    disable_windows_autostart();
    state.stop()
}

#[tauri::command]
pub fn daemon_uninstall(
    state: tauri::State<'_, DaemonManager>,
) -> Result<UninstallResult, String> {
    let daemon_stopped = state.stop().is_ok();

    let autostart_removed;
    #[cfg(target_os = "windows")]
    {
        let _ = std::process::Command::new("schtasks")
            .args(["/Delete", "/TN", "Runmote Daemon", "/F"])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        autostart_removed = true;
    }
    #[cfg(target_os = "linux")]
    {
        let _ = std::process::Command::new("systemctl")
            .args(["--user", "disable", "--now", "runmote.service"])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        let svc = home_dir().join(".config/systemd/user/runmote.service");
        let _ = fs::remove_file(&svc);
        autostart_removed = true;
    }
    #[cfg(target_os = "macos")]
    {
        let plist = home_dir().join("Library/LaunchAgents/com.runmote.daemon.plist");
        let _ = std::process::Command::new("launchctl")
            .args(["unload", "-w", &plist.to_string_lossy()])
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        let _ = fs::remove_file(&plist);
        autostart_removed = true;
    }
    #[cfg(not(any(target_os = "windows", target_os = "linux", target_os = "macos")))]
    {
        autostart_removed = false;
    }

    let wrapper_removed;
    {
        let cmd_path = user_bin_dir().join("runmote.cmd");
        let _ = fs::remove_file(&cmd_path);
        let daemon_sh = state.acp_path.join("scripts").join("run-daemon.ps1");
        let _ = fs::remove_file(&daemon_sh);
        let daemon_sh2 = state.acp_path.join("scripts").join("run-daemon.sh");
        let _ = fs::remove_file(&daemon_sh2);
        wrapper_removed = true;
    }

    let config_cleaned;
    {
        let cfg = config_dir();
        if cfg.exists() {
            let _ = fs::remove_dir_all(&cfg);
            config_cleaned = true;
        } else {
            config_cleaned = true;
        }
    }

    let temp_cleaned = true;

    Ok(UninstallResult {
        daemon_stopped,
        autostart_removed,
        wrapper_removed,
        config_cleaned,
        temp_cleaned,
    })
}
