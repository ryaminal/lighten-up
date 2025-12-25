mod config;
mod initialization;

use crate::app_state::AppState;
use crate::database::StoreDatabase;
use crate::domain::Event;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use tauri::{AppHandle, Emitter};

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;
pub type AppServices = AppState<StoreDatabase, AppNetwork>;

/// Initialize and setup the application services
pub async fn initialize_services(app: &AppHandle) -> Result<AppServices, String> {
    let (my_peer_id, my_name, passphrase) = config::load_config(app)?;
    let database = initialization::initialize_database(app).await?;
    let encryption = initialization::create_encryption(&passphrase)?;
    let network = initialization::create_network(my_peer_id.clone(), encryption).await?;
    let (services, event_rx) =
        initialization::create_services(&my_peer_id, &my_name, database, network).await?;
    start_background_tasks(app, &services, event_rx).await;
    Ok(services)
}

async fn start_background_tasks(
    app: &AppHandle,
    services: &AppServices,
    mut event_rx: tokio::sync::broadcast::Receiver<Event>,
) {
    let app_handle_clone = app.clone();
    tauri::async_runtime::spawn(async move {
        while let Ok(event) = event_rx.recv().await {
            forward_event(&app_handle_clone, &event);
        }
    });

    let peer_service_clone = services.peer_service.clone();
    tauri::async_runtime::spawn(async move {
        if let Err(e) = peer_service_clone.start().await {
            log::error!("Failed to start peer service: {:?}", e);
        }
    });
}

fn forward_event(app: &AppHandle, event: &Event) {
    let result = match event {
        Event::MyStateChanged { state } => {
            log::info!("[EVENT] Event: my-state-changed");
            app.emit("my-state-changed", state)
        }
        Event::PeerDiscovered { peer } => {
            log::info!("[EVENT] Event: peer-discovered");
            app.emit("peer-discovered", peer)
        }
        Event::PeerStateChanged { peer_id, state } => {
            log::info!("[EVENT] Event: peer-state-changed");
            app.emit("peer-state-changed", (peer_id, state))
        }
        Event::PeerLeft { peer_id } => {
            log::info!("[EVENT] Event: peer-left");
            app.emit("peer-left", peer_id)
        }
        Event::LightActivated { light } => {
            log::info!("[EVENT] Event: light-activated");
            app.emit("light-activated", light)
        }
        Event::LightDeactivated { light } => {
            log::info!("[EVENT] Event: light-deactivated");
            app.emit("light-deactivated", light)
        }
        Event::LightUpdated { light } => {
            log::info!("[EVENT] Event: light-updated");
            app.emit("light-updated", light)
        }
        Event::LightConfigChanged { config } => {
            log::info!("[EVENT] Event: light-config-changed");
            app.emit("light-config-changed", config)
        }
        Event::ControllerElected {
            controller_id,
            controller_name,
        } => {
            log::info!("[EVENT] Event: controller-elected");
            app.emit("controller-elected", (controller_id, controller_name))
        }
        Event::ControllerResigned { controller_id } => {
            log::info!("[EVENT] Event: controller-resigned");
            app.emit("controller-resigned", controller_id)
        }
    };

    if let Err(e) = result {
        log::error!("[ERROR] Failed to emit event: {:?}", e);
    }
}
