mod config;
mod initialization;

use crate::app_state::AppState;
use crate::database::StoreDatabase;
use crate::domain::Event;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use tauri::{AppHandle, Emitter};

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;
type AppServices = AppState<StoreDatabase, AppNetwork>;

/// Initialize and setup the application services
pub async fn initialize_services(app: &AppHandle) -> Result<AppServices, String> {
    let (my_peer_id, my_name, passphrase) = config::load_config(app)?;
    let database = initialization::initialize_database(app).await?;
    let encryption = initialization::create_encryption(&passphrase)?;
    let network = initialization::create_network(my_peer_id.clone(), encryption).await?;
    let services =
        initialization::create_services(&my_peer_id, &my_name, database, network).await?;
    start_background_tasks(app, &services).await;
    Ok(services)
}

async fn start_background_tasks(app: &AppHandle, services: &AppServices) {
    let app_handle_clone = app.clone();
    let mut event_rx = services.light_service.subscribe();
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
            log::info!("📤 Event: my-state-changed");
            app.emit("my-state-changed", state)
        }
        Event::PeerDiscovered { peer } => {
            log::info!("📤 Event: peer-discovered");
            app.emit("peer-discovered", peer)
        }
        Event::PeerStateChanged { peer_id, state } => {
            log::info!("📤 Event: peer-state-changed");
            app.emit("peer-state-changed", (peer_id, state))
        }
        Event::PeerLeft { peer_id } => {
            log::info!("📤 Event: peer-left");
            app.emit("peer-left", peer_id)
        }
    };

    if let Err(e) = result {
        log::error!("❌ Failed to emit event: {:?}", e);
    }
}
