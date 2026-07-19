mod agents;
mod daemon;
mod pairing;
mod tray;

use std::path::PathBuf;

fn resolve_acp_path() -> PathBuf {
    if let Ok(dir) = std::env::var("ACP_DIR") {
        return PathBuf::from(dir);
    }

    if let Ok(cwd) = std::env::current_dir() {
        let candidate = cwd.join("..");
        if candidate.join("pyproject.toml").exists() {
            return candidate;
        }
    }

    PathBuf::from("..")
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let acp_path = resolve_acp_path();

    tauri::Builder::default()
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
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
