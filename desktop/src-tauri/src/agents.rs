use std::env;
use std::path::PathBuf;

use serde::Serialize;

#[cfg(target_os = "windows")]
fn silent_cmd(name: &str) -> std::process::Command {
    use std::os::windows::process::CommandExt;
    let mut c = std::process::Command::new(name);
    c.creation_flags(0x08000000);
    c
}

#[cfg(not(target_os = "windows"))]
fn silent_cmd(name: &str) -> std::process::Command {
    std::process::Command::new(name)
}

#[derive(Clone, Serialize)]
pub struct AgentInfo {
    pub id: String,
    pub name: String,
    pub command: Vec<String>,
    pub found: bool,
    pub path: Option<String>,
}

fn find_exe(name: &str, extra_dirs: &[PathBuf]) -> Option<PathBuf> {
    if let Some(path) = find_exe_in_path(name) {
        return Some(path);
    }

    for dir in extra_dirs {
        if !dir.as_os_str().is_empty() && dir.is_dir() {
            #[cfg(target_os = "windows")]
            {
                if let Ok(entries) = dir.read_dir() {
                    for entry in entries.flatten() {
                        if entry.file_type().map(|t| t.is_file()).unwrap_or(false) {
                            let lower = entry.file_name().to_string_lossy().to_lowercase();
                            for ext in ["", ".cmd", ".bat", ".exe"] {
                                if lower == format!("{}{}", name, ext).to_lowercase() {
                                    return Some(entry.path());
                                }
                            }
                        }
                    }
                }
            }
            #[cfg(not(target_os = "windows"))]
            {
                let full = dir.join(name);
                if full.is_file() {
                    return Some(full);
                }
            }
        }
    }

    // Final fallback: ask the shell where the executable is.
    find_exe_via_shell(name)
}

fn find_exe_in_path(name: &str) -> Option<PathBuf> {
    if let Ok(path) = env::var("PATH") {
        for dir in env::split_paths(&path) {
            let full = dir.join(name);
            if full.is_file() {
                return Some(full);
            }
            #[cfg(target_os = "windows")]
            {
                for ext in [".cmd", ".bat", ".exe"] {
                    let with_ext = dir.join(format!("{}{}", name, ext));
                    if with_ext.is_file() {
                        return Some(with_ext);
                    }
                }
            }
        }
    }
    None
}

fn find_exe_via_shell(name: &str) -> Option<PathBuf> {
    #[cfg(target_os = "windows")]
    {
        let output = silent_cmd("where")
            .arg(name)
            .output()
            .ok()?;
        if !output.status.success() {
            return None;
        }
        let stdout = String::from_utf8_lossy(&output.stdout);
        for line in stdout.lines() {
            let path = PathBuf::from(line.trim());
            if path.is_file() {
                return Some(path);
            }
        }
    }
    #[cfg(not(target_os = "windows"))]
    {
        let output = silent_cmd("which")
            .arg(name)
            .output()
            .ok()?;
        if !output.status.success() {
            return None;
        }
        let stdout = String::from_utf8_lossy(&output.stdout);
        let path = PathBuf::from(stdout.trim());
        if path.is_file() {
            return Some(path);
        }
    }
    None
}

fn npm_global_prefix() -> PathBuf {
    // npm root -g works even when npm is on PATH.
    if let Ok(output) = silent_cmd("npm")
        .args(["root", "-g"])
        .output()
    {
        if output.status.success() {
            let stdout = String::from_utf8_lossy(&output.stdout);
            let p = PathBuf::from(stdout.trim());
            if p.is_dir() {
                return p;
            }
        }
    }
    PathBuf::new()
}

fn has_npx() -> bool {
    let cmd = if cfg!(target_os = "windows") {
        "where"
    } else {
        "which"
    };
    silent_cmd(cmd)
        .arg("npx")
        .output()
        .ok()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

fn env_dir(key: &str) -> PathBuf {
    env::var(key)
        .ok()
        .map(PathBuf::from)
        .unwrap_or_default()
}

fn join_home(sub: &str) -> PathBuf {
    let home = if cfg!(target_os = "windows") {
        env_dir("USERPROFILE")
    } else {
        env_dir("HOME")
    };
    if home.as_os_str().is_empty() {
        PathBuf::new()
    } else {
        home.join(sub)
    }
}

fn program_files_dirs() -> Vec<PathBuf> {
    let mut dirs = Vec::new();
    for key in &["PROGRAMFILES", "PROGRAMFILES(X86)", "ProgramW6432"] {
        let d = env_dir(key);
        if !d.as_os_str().is_empty() {
            dirs.push(d);
        }
    }
    dirs
}

fn add_agent(
    agents: &mut Vec<AgentInfo>,
    id: &str,
    name: &str,
    command: Vec<String>,
    found: bool,
    path: Option<String>,
) {
    agents.push(AgentInfo {
        id: id.into(),
        name: name.into(),
        command,
        found,
        path,
    });
}

pub fn detect_agents() -> Vec<AgentInfo> {
    let local = env_dir("LOCALAPPDATA");
    let appdata = env_dir("APPDATA");

    let pf_dirs = program_files_dirs();
    let localbin = join_home(".local/bin");
    let npm = {
        let p = join_home("AppData/Roaming/npm");
        p
    };
    let cargo = join_home(".cargo/bin");
    let bun = join_home(".bun/bin");
    let scoop = join_home("scoop/shims");
    let choco_root = env_dir("PROGRAMDATA");
    let choco = if choco_root.as_os_str().is_empty() {
        PathBuf::new()
    } else {
        choco_root.join("chocolatey/bin")
    };
    let winget = if local.as_os_str().is_empty() {
        PathBuf::new()
    } else {
        local.join("Microsoft/WinGet/Links")
    };
    let pythonscripts = if appdata.as_os_str().is_empty() {
        PathBuf::new()
    } else {
        appdata.join("Python/Scripts")
    };
    let dotnet = join_home(".dotnet/tools");

    // Windows app aliases (stores agent .exe shortcuts from some installers)
    let windows_apps = {
        let p = local.join("Microsoft/WindowsApps");
        if p.is_dir() { p } else { PathBuf::new() }
    };
    // npm global prefix (more reliable than hardcoded AppData/npm)
    let npm_prefix = npm_global_prefix();

    let common_dirs: Vec<PathBuf> = vec![
        localbin.clone(),
        npm.clone(),
        cargo.clone(),
        bun.clone(),
        scoop.clone(),
        choco.clone(),
        winget.clone(),
        pythonscripts.clone(),
        dotnet.clone(),
        windows_apps.clone(),
        npm_prefix.clone(),
    ];

    let mut agents: Vec<AgentInfo> = Vec::new();

    // codex
    {
        let mut codex_dirs = common_dirs.clone();
        codex_dirs.extend([
            local.join("Programs/codex-cli"),
            local.join("Programs/Codex CLI"),
            local.join("codex-cli"),
        ]);
        let codex_cli = find_exe("codex", &codex_dirs);
        if codex_cli.is_some() {
            let codex_acp = find_exe("codex-acp", &common_dirs);
            if let Some(path) = codex_acp {
                add_agent(
                    &mut agents,
                    "codex",
                    "Codex",
                    vec![path.to_string_lossy().into_owned()],
                    true,
                    Some(path.to_string_lossy().into_owned()),
                );
            } else if has_npx() {
                add_agent(
                    &mut agents,
                    "codex",
                    "Codex",
                    vec!["npx".into(), "-y".into(), "@agentclientprotocol/codex-acp".into()],
                    true,
                    None,
                );
            } else {
                add_agent(&mut agents, "codex", "Codex", vec![], false, None);
            }
        } else {
            add_agent(&mut agents, "codex", "Codex", vec![], false, None);
        }
    }

    // claude
    {
        let mut claude_dirs = common_dirs.clone();
        claude_dirs.extend([
            local.join("Programs/claude-code"),
            local.join("Programs/Claude Code"),
            local.join("claude-code"),
            join_home(".claude/bin"),
        ]);
        let claude_cli = find_exe("claude", &claude_dirs)
            .or_else(|| find_exe("claude-code", &claude_dirs));
        if claude_cli.is_some() {
            let claude_acp = find_exe("claude-agent-acp", &claude_dirs);
            if let Some(path) = claude_acp {
                add_agent(
                    &mut agents,
                    "claude",
                    "Claude Code",
                    vec![path.to_string_lossy().into_owned()],
                    true,
                    Some(path.to_string_lossy().into_owned()),
                );
            } else if has_npx() {
                add_agent(
                    &mut agents,
                    "claude",
                    "Claude Code",
                    vec!["npx".into(), "-y".into(), "@agentclientprotocol/claude-agent-acp".into()],
                    true,
                    None,
                );
            } else {
                add_agent(&mut agents, "claude", "Claude Code", vec![], false, None);
            }
        } else {
            add_agent(&mut agents, "claude", "Claude Code", vec![], false, None);
        }
    }

    // cursor
    {
        let mut cursor_dirs: Vec<PathBuf> = pf_dirs
            .iter()
            .flat_map(|p| [p.join("cursor"), p.join("Cursor")])
            .chain(
                [
                    local.join("Programs/cursor"),
                    local.join("Programs/Cursor"),
                    local.join("Programs/cursor/resources/app"),
                    local.join("Programs/Cursor/resources/app"),
                ]
                .into_iter(),
            )
            .collect();
        cursor_dirs.extend(common_dirs.clone());

        let mut found = find_exe("cursor-agent", &cursor_dirs);
        let cursor_bin_dir = local.join("Programs/Cursor/resources/app");
        if found.is_none() && cursor_bin_dir.is_dir() {
            let cursor_dirs2 = vec![cursor_bin_dir];
            found = find_exe("agent", &cursor_dirs2);
        }
        if let Some(path) = found {
            add_agent(
                &mut agents,
                "cursor",
                "Cursor",
                vec![path.to_string_lossy().into_owned(), "acp".into()],
                true,
                Some(path.to_string_lossy().into_owned()),
            );
        } else {
            add_agent(&mut agents, "cursor", "Cursor", vec![], false, None);
        }
    }

    agents
}

#[tauri::command]
pub fn get_agents() -> Vec<AgentInfo> {
    detect_agents()
}
