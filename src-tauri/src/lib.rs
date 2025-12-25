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
        .plugin(configure_logging().build())
        .plugin(tauri_plugin_store::Builder::default().build())
        .plugin(tauri_plugin_os::init())
        .plugin(tauri_plugin_opener::init())
        .plugin(tauri_plugin_cli::init())
        .setup(setup_application)
        .on_window_event(handle_window_event)
        .invoke_handler(tauri::generate_handler![
            commands::set_light_color,
            commands::set_light_status,
            commands::get_my_state,
            commands::get_peers,
            commands::create_light,
            commands::activate_light,
            commands::deactivate_light,
            commands::add_light_comment,
            commands::get_all_lights,
            commands::get_light_config,
            commands::update_light_definition,
            commands::delete_light_definition,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn configure_logging() -> tauri_plugin_log::Builder {
    tauri_plugin_log::Builder::default()
        .targets([
            tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::Stdout),
            tauri_plugin_log::Target::new(tauri_plugin_log::TargetKind::LogDir {
                file_name: Some("lighten-up".to_string()),
            }),
        ])
        .level(log::LevelFilter::Info)
        .filter(should_log_target)
}

fn should_log_target(metadata: &log::Metadata) -> bool {
    let target = metadata.target();
    !target.starts_with("mdns_sd")
        && !target.starts_with("glycin")
        && !target.starts_with("tao")
        && !target.starts_with("winit")
        && !target.starts_with("wry")
}

fn setup_application(app: &mut tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    parse_cli_args(app);
    initialize_services_sync(app)?;
    Ok(())
}

fn parse_cli_args(app: &tauri::App) {
    if let Ok(matches) = tauri_plugin_cli::CliExt::cli(app).matches() {
        set_peer_id_from_cli(&matches);
        set_peer_name_from_cli(&matches);
        set_data_dir_from_cli(&matches);
    }
}

fn set_peer_id_from_cli(matches: &tauri_plugin_cli::Matches) {
    if let Some(id) = matches.args.get("id")
        && let Some(id_str) = id.value.as_str()
    {
        log::info!("Setting peer ID from CLI: {}", id_str);
        unsafe {
            std::env::set_var("LIGHTEN_UP_PEER_ID", id_str);
        }
    }
}

fn set_peer_name_from_cli(matches: &tauri_plugin_cli::Matches) {
    if let Some(name) = matches.args.get("name")
        && let Some(name_str) = name.value.as_str()
    {
        log::info!("Setting peer name from CLI: {}", name_str);
        unsafe {
            std::env::set_var("LIGHTEN_UP_PEER_NAME", name_str);
        }
    }
}

fn set_data_dir_from_cli(matches: &tauri_plugin_cli::Matches) {
    if let Some(data_dir) = matches.args.get("data-dir")
        && let Some(dir_str) = data_dir.value.as_str()
    {
        log::info!("Setting data directory from CLI: {}", dir_str);
        unsafe {
            std::env::set_var("LIGHTEN_UP_DATA_DIR", dir_str);
        }
    }
}

fn initialize_services_sync(app: &mut tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    let services =
        tauri::async_runtime::block_on(async { setup::initialize_services(app.handle()).await })
            .map_err(|e| {
                log::error!("Failed to initialize services: {}", e);
                e
            })?;

    app.manage(services);
    Ok(())
}

fn handle_window_event(window: &tauri::Window, event: &tauri::WindowEvent) {
    if let tauri::WindowEvent::CloseRequested { .. } = event {
        perform_graceful_shutdown(window);
    }
}

fn perform_graceful_shutdown(window: &tauri::Window) {
    log::info!("Window close requested, initiating graceful shutdown");
    let app_handle = window.app_handle();
    let services = app_handle.state::<setup::AppServices>();

    tauri::async_runtime::block_on(async {
        if let Err(e) = services.shutdown().await {
            log::error!("Error during shutdown: {}", e);
        }
    });
}
