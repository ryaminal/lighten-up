use crate::app_state::AppState;
use crate::database::SqliteDatabase;
use crate::domain::PeerId;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::{LightService, PeerService};
use std::sync::Arc;
use tauri::{AppHandle, Manager};

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;

/// Initialize the database
pub async fn initialize_database(app: &AppHandle) -> Result<Arc<SqliteDatabase>, String> {
    let db_path = app
        .path()
        .app_data_dir()
        .expect("Failed to get app data dir")
        .join("lighten-up.db");

    let database = Arc::new(
        SqliteDatabase::new(db_path.to_str().expect("Invalid path"))
            .map_err(|e| format!("Failed to create database: {:?}", e))?,
    );

    database
        .initialize()
        .await
        .map_err(|e| format!("Failed to initialize database: {:?}", e))?;

    Ok(database)
}

/// Create encryption adapter from passphrase
pub fn create_encryption(passphrase: &str) -> Result<ChaCha20Encryption, String> {
    ChaCha20Encryption::from_passphrase(passphrase)
        .map_err(|e| format!("Failed to create encryption: {:?}", e))
}

/// Create network adapter
pub fn create_network(peer_id: PeerId, encryption: ChaCha20Encryption) -> Arc<AppNetwork> {
    Arc::new(MdnsNetwork::new(peer_id, encryption))
}

/// Create light and peer services
pub async fn create_services(
    my_peer_id: &PeerId,
    my_name: &str,
    database: Arc<SqliteDatabase>,
    network: Arc<AppNetwork>,
) -> Result<AppState<SqliteDatabase, AppNetwork>, String> {
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
