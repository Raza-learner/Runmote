mod agents;
mod daemon;
mod pairing;
mod tray;

use std::fs;
use std::path::PathBuf;
use tauri::Manager;

fn copy_recursively(src: &std::path::Path, dst: &std::path::Path) -> Result<(), String> {
    if src.is_dir() {
        if !dst.exists() {
            fs::create_dir_all(dst).map_err(|e| e.to_string())?;
        }
        for entry in fs::read_dir(src).map_err(|e| e.to_string())? {
            let entry = entry.map_err(|e| e.to_string())?;
            let file_type = entry.file_type().map_err(|e| e.to_string())?;
            let src_path = entry.path();
            let dst_path = dst.join(entry.file_name());
            if file_type.is_dir() {
                copy_recursively(&src_path, &dst_path)?;
            } else {
                if dst_path.exists() {
                    fs::remove_file(&dst_path).map_err(|e| e.to_string())?;
                }
                fs::copy(&src_path, &dst_path).map_err(|e| e.to_string())?;
            }
        }
    } else if src.exists() {
        if let Some(parent) = dst.parent() {
            fs::create_dir_all(parent).map_err(|e| e.to_string())?;
        }
        if dst.exists() {
            fs::remove_file(&dst).map_err(|e| e.to_string())?;
        }
        fs::copy(src, dst).map_err(|e| e.to_string())?;
    }
    Ok(())
}

fn resolve_acp_path(app: &tauri::AppHandle) -> PathBuf {
    // 1. Explicit env var wins.
    if let Ok(dir) = std::env::var("ACP_DIR") {
        let p = PathBuf::from(dir);
        if p.join("pyproject.toml").exists() {
            return p;
        }
    }

    // 2. Walk up from exe (development mode — pyproject.toml at project root).
    if let Ok(exe) = std::env::current_exe() {
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

    // 3. Bundled resources (shipped with the NSIS installer).
    let app_data = app.path().app_data_dir().ok();
    if let Some(data_dir) = app_data {
        let bundled = data_dir.join("acp");
        if bundled.join("pyproject.toml").exists() {
            return bundled;
        }
    }

    std::process::exit(1);
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let app = tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![
            daemon::daemon_status,
            daemon::daemon_start,
            daemon::daemon_stop,
            daemon::daemon_uninstall,
            pairing::get_pairing_info_cmd,
            agents::get_agents,
        ])
        .setup(|app| {
            // Extract bundled ACP resources to app data dir if needed.
            if let Ok(resource_dir) = app.path().resource_dir() {
                let bundled_src = resource_dir.join("acp-src");
                if bundled_src.join("pyproject.toml").exists() {
                    if let Ok(app_data) = app.path().app_data_dir() {
                        let dest = app_data.join("acp");
                        let _ = copy_recursively(&bundled_src, &dest);
                    }
                }
            }

            let acp_path = resolve_acp_path(app.handle());
            app.manage(daemon::DaemonManager::new(acp_path));
            tray::create_tray(app)?;
            Ok(())
        })
        .build(tauri::generate_context!())
        .expect("error while building tauri application");

    app.run(|app_handle, event| {
        if let tauri::RunEvent::WindowEvent { label, event, .. } = event {
            if label == "main" {
                if let tauri::WindowEvent::CloseRequested { api, .. } = event {
                    api.prevent_close();
                    if let Some(window) = app_handle.get_webview_window("main") {
                        let _ = window.hide();
                    }
                }
            }
        }
    });
}