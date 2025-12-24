// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

fn main() {
    // Store args in environment for config to read
    // SAFETY: We're setting environment variables at startup before any threads are created
    lighten_up_lib::run()
}
