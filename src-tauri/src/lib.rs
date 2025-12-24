pub mod adapters;
pub mod app_state;
pub mod commands;
pub mod database;
pub mod domain;
pub mod encryption;
pub mod network;
pub mod services;
pub mod setup;

use tauri::Manager;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            let services = tauri::async_runtime::block_on(async {
                setup::initialize_services(app.handle()).await
            })
            .expect("Failed to initialize services");

            app.manage(services);
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            commands::set_light_color,
            commands::get_my_state,
            commands::get_peers,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
