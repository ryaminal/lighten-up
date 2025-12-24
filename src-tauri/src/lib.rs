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
        .plugin(
            tauri_plugin_log::Builder::default()
                .targets([
                    tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::Stdout),
                    tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::LogDir {
                        file_name: Some("lighten-up".to_string()),
                    }),
                ])
                .level(log::LevelFilter::Info)
                .filter(|metadata| {
                    // Filter out noisy dependencies
                    let target = metadata.target();
                    !target.starts_with("mdns_sd")
                        && !target.starts_with("glycin")
                        && !target.starts_with("tao")
                        && !target.starts_with("winit")
                        && !target.starts_with("wry")
                })
                .build(),
        )
        .plugin(tauri_plugin_store::Builder::default().build())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_cli::init())
        .setup(|app| {
            // Parse CLI arguments and set environment variables
            // SAFETY: Setting env vars at startup before any threads access them
            if let Ok(matches) = tauri_plugin_cli::CliExt::cli(app).matches() {
                if let Some(id) = matches.args.get("id")
                    && let Some(id_str) = id.value.as_str()
                {
                    log::info!("Setting peer ID from CLI: {}", id_str);
                    unsafe {
                        std::env::set_var("LIGHTEN_UP_PEER_ID", id_str);
                    }
                }
                if let Some(name) = matches.args.get("name")
                    && let Some(name_str) = name.value.as_str()
                {
                    log::info!("Setting peer name from CLI: {}", name_str);
                    unsafe {
                        std::env::set_var("LIGHTEN_UP_PEER_NAME", name_str);
                    }
                }
                if let Some(data_dir) = matches.args.get("data-dir")
                    && let Some(dir_str) = data_dir.value.as_str()
                {
                    log::info!("Setting data directory from CLI: {}", dir_str);
                    unsafe {
                        std::env::set_var("LIGHTEN_UP_DATA_DIR", dir_str);
                    }
                }
            }

            let services = tauri::async_runtime::block_on(async {
                setup::initialize_services(app.handle()).await
            })
            .map_err(|e| {
                log::error!("Failed to initialize services: {}", e);
                e
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
