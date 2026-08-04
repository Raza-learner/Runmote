#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    #[cfg(windows)]
    {
        unsafe {
            use windows_sys::core::w;
            use windows_sys::Win32::Foundation::{GetLastError, ERROR_ALREADY_EXISTS};
            use windows_sys::Win32::System::Threading::CreateMutexW;
            let name = w!("Local\\Runmote-SingleInstance");
            CreateMutexW(std::ptr::null_mut(), 0, name);
            if GetLastError() == ERROR_ALREADY_EXISTS {
                std::process::exit(0);
            }
        }
    }

    runmote_lib::run();
}