use crate::adapters::DatabaseAdapter;
use crate::adapters::network::NetworkAdapter;
use crate::app_state::AppState;
use crate::database::StoreDatabase;
use crate::domain::PeerId;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::{LightService, PeerService};
use std::sync::Arc;
use tauri::AppHandle;

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;

/// Initialize the database using Tauri store
pub async fn initialize_database(app: &AppHandle) -> Result<Arc<StoreDatabase>, String> {
    let database =
        StoreDatabase::new(app).map_err(|e| format!("Failed to create database: {:?}", e))?;

    database
        .initialize()
        .await
        .map_err(|e| format!("Failed to initialize database: {:?}", e))?;

    log::info!("Database initialized using Tauri store");
    Ok(Arc::new(database))
}

/// Create encryption adapter from passphrase
pub fn create_encryption(passphrase: &str) -> Result<ChaCha20Encryption, String> {
    ChaCha20Encryption::from_passphrase(passphrase)
        .map_err(|e| format!("Failed to create encryption: {:?}", e))
}

/// Create and start network adapter
pub async fn create_network(
    peer_id: PeerId,
    encryption: ChaCha20Encryption,
) -> Result<Arc<AppNetwork>, String> {
    let network = Arc::new(MdnsNetwork::new(peer_id, encryption));
    network
        .as_ref()
        .start()
        .await
        .map_err(|e| format!("Failed to start network: {:?}", e))?;
    log::info!("Network started successfully");
    Ok(network)
}

/// Create light and peer services
pub async fn create_services(
    my_peer_id: &PeerId,
    my_name: &str,
    database: Arc<StoreDatabase>,
    network: Arc<AppNetwork>,
) -> Result<AppState<StoreDatabase, AppNetwork>, String> {
    let (event_tx, _) = tokio::sync::broadcast::channel(100);

    let light_service = Arc::new(
        LightService::new(
            my_peer_id.clone(),
            my_name.to_string(),
            database.clone(),
            network.clone(),
        )
        .await
        .map_err(|e| format!("Failed to create LightService: {:?}", e))?,
    );

    let peer_service = Arc::new(
        PeerService::new(
            my_peer_id.clone(),
            database.clone(),
            network.clone(),
            event_tx.clone(),
        )
        .await
        .map_err(|e| format!("Failed to create PeerService: {:?}", e))?,
    );

    Ok(AppState::new(light_service, peer_service))
}
