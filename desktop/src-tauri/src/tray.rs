use std::sync::Arc;
use std::time::Duration;

use tauri::{
    image::Image,
    menu::{MenuItem, PredefinedMenuItem},
    tray::TrayIconBuilder,
    Emitter, Manager,
};

use crate::daemon::DaemonManager;
use crate::pairing;

fn load_tray_icon() -> Image<'static> {
    let img = image::load_from_memory(include_bytes!("../icons/32x32.png"))
        .expect("Failed to load tray icon");
    let rgba = img.to_rgba8();
    let (w, h) = rgba.dimensions();
    let pixels = rgba.into_raw();
    Image::new_owned(pixels, w, h)
}

pub fn create_tray(app: &tauri::App) -> tauri::Result<()> {
    let start = MenuItem::with_id(app, "start", "Start Daemon", true, None::<&str>)?;
    let stop = MenuItem::with_id(app, "stop", "Stop Daemon", true, None::<&str>)?;
    let sep1 = PredefinedMenuItem::separator(app)?;
    let qr = MenuItem::with_id(app, "qr", "Show Pairing QR", true, None::<&str>)?;
    let text = MenuItem::with_id(
        app,
        "text",
        "Show Pairing Code (text)",
        true,
        None::<&str>,
    )?;
    let sep2 = PredefinedMenuItem::separator(app)?;
    let uninstall = MenuItem::with_id(app, "uninstall", "Uninstall Daemon", true, None::<&str>)?;
    let quit = MenuItem::with_id(app, "quit", "Quit", true, None::<&str>)?;

    let menu = tauri::menu::Menu::new(app)?;
    menu.append(&start)?;
    menu.append(&stop)?;
    menu.append(&sep1)?;
    menu.append(&qr)?;
    menu.append(&text)?;
    menu.append(&sep2)?;
    menu.append(&uninstall)?;
    menu.append(&quit)?;

    let icon = load_tray_icon();

    let start_arc = Arc::new(start);
    let stop_arc = Arc::new(stop);
    let qr_arc = Arc::new(qr);
    let text_arc = Arc::new(text);

    TrayIconBuilder::new()
        .icon(icon)
        .menu(&menu)
        .tooltip("Runmote - ACP Daemon Controller")
        .on_menu_event(|app, event| {
            let daemon = app.state::<DaemonManager>();
            match event.id().as_ref() {
                "start" => {
                    if let Err(e) = daemon.start() {
                        eprintln!("Failed to start daemon: {}", e);
                    }
                }
                "stop" => {
                    if let Err(e) = daemon.stop() {
                        eprintln!("Failed to stop daemon: {}", e);
                    }
                }
                "qr" => {
                    if let Ok(info) = pairing::get_pairing_info() {
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.show();
                            let _ = window.set_focus();
                        }
                        let _ = app.emit("tray:show-qr", info);
                    }
                }
                "text" => {
                    if let Ok(info) = pairing::get_pairing_info() {
                        if let Some(window) = app.get_webview_window("main") {
                            let _ = window.show();
                            let _ = window.set_focus();
                        }
                        let _ = app.emit("tray:show-text", info.formatted);
                    }
                }
                "uninstall" => {
                    if let Some(window) = app.get_webview_window("main") {
                        let _ = window.show();
                        let _ = window.set_focus();
                    }
                    let _ = app.emit("tray:uninstall", ());
                }
                "quit" => {
                    app.exit(0);
                }
                _ => {}
            }
        })
        .build(app)?;

    let app_handle = app.handle().clone();
    std::thread::spawn(move || loop {
        std::thread::sleep(Duration::from_secs(3));
        let daemon = app_handle.state::<DaemonManager>();
        let status = daemon.status();
        if let Some(tray) = app_handle.tray_by_id("main") {
            let tooltip = if status.running {
                format!("Runmote - Running (PID {})", status.pid.unwrap_or(0))
            } else {
                "Runmote - Stopped".into()
            };
            let _ = tray.set_tooltip(Some(tooltip));
        }

        let _ = start_arc.set_enabled(!status.running);
        let _ = stop_arc.set_enabled(status.running);
        let _ = qr_arc.set_enabled(status.running);
        let _ = text_arc.set_enabled(status.running);
    });

    Ok(())
}
