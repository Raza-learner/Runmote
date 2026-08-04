use std::io::Cursor;
use std::path::PathBuf;
use std::{env, fs};

use base64::Engine;
use image::{Luma, Rgba, RgbaImage};
use serde::Serialize;

const CODE_FILE: &str = "runmote-pairing-code.txt";
const PUBLIC_URL_FILE: &str = "public_url";

#[derive(Clone, Serialize)]
pub struct PairingInfo {
    pub code: String,
    pub formatted: String,
    pub qr_data_url: String,
    pub public_url: String,
}

fn temp_dir() -> PathBuf {
    env::temp_dir()
}

fn code_file_path() -> PathBuf {
    temp_dir().join(CODE_FILE)
}

fn config_dir() -> PathBuf {
    #[cfg(target_os = "windows")]
    {
        if let Ok(profile) = env::var("USERPROFILE") {
            PathBuf::from(profile).join(".config").join("runmote")
        } else {
            PathBuf::from(r"C:\Users\Public\.config\runmote")
        }
    }
    #[cfg(not(target_os = "windows"))]
    {
        if let Ok(home) = env::var("HOME") {
            PathBuf::from(home).join(".config").join("runmote")
        } else {
            PathBuf::from("/tmp/.config/runmote")
        }
    }
}

fn public_url_file_path() -> PathBuf {
    config_dir().join(PUBLIC_URL_FILE)
}

fn format_code(code: &str) -> String {
    if code.len() == 6 {
        format!("{}-{}", &code[..3], &code[3..])
    } else {
        format!("{}-{}", &code[..4.min(code.len())], &code[4.min(code.len())..])
    }
}

fn generate_qr_data_url(data: &str) -> Result<String, String> {
    let qr = qrcode::QrCode::new(data)
        .map_err(|e| format!("Failed to generate QR: {}", e))?;

    let gray = qr
        .render::<Luma<u8>>()
        .quiet_zone(true)
        .min_dimensions(300, 300)
        .dark_color(Luma([0u8]))
        .light_color(Luma([255u8]))
        .build();

    let (w, h) = gray.dimensions();
    let mut rgba = RgbaImage::new(w, h);
    for (x, y, pixel) in gray.enumerate_pixels() {
        let v = pixel[0];
        rgba.put_pixel(x, y, Rgba([v, v, v, 255]));
    }

    let mut buf = Vec::new();
    rgba.write_to(&mut Cursor::new(&mut buf), image::ImageFormat::Png)
        .map_err(|e| format!("Failed to encode PNG: {}", e))?;

    let b64 = base64::engine::general_purpose::STANDARD.encode(&buf);
    Ok(format!("data:image/png;base64,{}", b64))
}

pub fn get_pairing_info() -> Result<PairingInfo, String> {
    let code_path = code_file_path();
    if !code_path.exists() {
        return Err("No pairing code available. Start the daemon and wait for it to connect.".into());
    }

    let code = fs::read_to_string(&code_path)
        .map_err(|e| format!("Failed to read pairing code: {}", e))?
        .trim()
        .to_string();

    if code.is_empty() {
        return Err("Pairing code file is empty.".into());
    }

    let formatted = format_code(&code);

    let public_url_path = public_url_file_path();
    let public_url = if public_url_path.exists() {
        fs::read_to_string(&public_url_path)
            .unwrap_or_default()
            .trim()
            .to_string()
    } else {
        String::new()
    };

    let qr_data = if public_url.is_empty() {
        code.clone()
    } else {
        format!("{}/connect?code={}", public_url, code)
    };

    let qr_data_url = generate_qr_data_url(&qr_data)?;

    Ok(PairingInfo {
        code,
        formatted,
        qr_data_url,
        public_url,
    })
}

#[tauri::command]
pub fn get_pairing_info_cmd() -> Result<PairingInfo, String> {
    get_pairing_info()
}
