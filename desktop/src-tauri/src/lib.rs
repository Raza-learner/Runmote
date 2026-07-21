mod agents;
mod daemon;
mod pairing;
mod tray;

use std::path::PathBuf;
use tauri::Manager;

fn resolve_acp_path() -> PathBuf {
    // 1. Explicit env var wins.
    if let Ok(dir) = std::env::var("ACP_DIR") {
        let p = PathBuf::from(dir);
        if p.join("pyproject.toml").exists() {
            return p;
        }
    }

    // 2. Resolve relative to the EXE's own location
    //    (G:\Runmote\desktop\src-tauri\target\release\runmote.exe → G:\Runmote)
    if let Ok(exe) = std::env::current_exe() {
        // Walk up parents looking for pyproject.toml
        let mut candidate = exe.parent().unwrap_or(&exe).to_path_buf();
        loop {
            if candidate.join("pyproject.toml").exists() {
                return candidate;
            }
            if !candidate.pop() {
                break;
            }
        }
    }

    // 3. Fallback: check current_dir/..
    if let Ok(cwd) = std::env::current_dir() {
        let candidate = cwd.join("..");
        if candidate.join("pyproject.toml").exists() {
            return candidate;
        }
    }

    std::process::exit(1);
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let acp_path = resolve_acp_path();

    let app = tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .manage(daemon::DaemonManager::new(acp_path))
        .invoke_handler(tauri::generate_handler![
            daemon::daemon_status,
            daemon::daemon_start,
            daemon::daemon_stop,
            daemon::daemon_uninstall,
            pairing::get_pairing_info_cmd,
            agents::get_agents,
        ])
        .setup(|app| {
            tray::create_tray(app)?;
            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("error while building tauri application");

    app.run(|app_handle, event| {
        if let tauri::RunEvent::WindowEvent { label, event, .. } = event {
            if label == "main" {
                if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                    // Hide to tray instead of closing.
                    api.prevent_close();
                    if let Some(window) = app_handle.get_webview_window("main") {
                        let _ = window.hide();
                    }
                }
            }
        }
    });
}
