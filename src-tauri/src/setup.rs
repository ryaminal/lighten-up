use crate::app_state::AppState;
use crate::database::SqliteDatabase;
use crate::domain::{Event, PeerId};
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::{LightService, PeerService};
use std::sync::Arc;
use tauri::{AppHandle, Emitter, Manager};

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;
type AppServices = AppState<SqliteDatabase, AppNetwork>;

/// Initialize and setup the application services
pub async fn initialize_services(app: &AppHandle) -> Result<AppServices, String> {
    // Initialize database
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

    // Generate peer ID (in production, this should be persisted)
    let my_peer_id = PeerId::new("my-peer"); // TODO: Generate unique ID
    let my_name = "My Computer".to_string(); // TODO: Get from system

    // Initialize encryption
    let passphrase = "lighten-up-development"; // TODO: Secure key management
    let encryption = ChaCha20Encryption::from_passphrase(passphrase)
        .map_err(|e| format!("Failed to create encryption: {:?}", e))?;

    // Initialize network adapter
    let network = Arc::new(MdnsNetwork::new(my_peer_id.clone(), encryption));

    // Create services with shared event broadcast
    let (event_tx, _) = tokio::sync::broadcast::channel(100);

    let light_service = Arc::new(
        LightService::new(
            my_peer_id.clone(),
            my_name.clone(),
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

    // Forward events from services to Tauri event system
    let app_handle_clone = app.clone();
    let mut event_rx = light_service.subscribe();
    tauri::async_runtime::spawn(async move {
        while let Ok(event) = event_rx.recv().await {
            forward_event(&app_handle_clone, &event);
        }
    });

    // Start peer service message loop
    let peer_service_clone = peer_service.clone();
    tauri::async_runtime::spawn(async move {
        if let Err(e) = peer_service_clone.start().await {
            eprintln!("Failed to start peer service: {:?}", e);
        }
    });

    Ok(AppServices::new(light_service, peer_service))
}

fn forward_event(app: &AppHandle, event: &Event) {
    let result = match event {
        Event::MyStateChanged { state } => app.emit("my-state-changed", state),
        Event::PeerDiscovered { peer } => app.emit("peer-discovered", peer),
        Event::PeerStateChanged { peer_id, state } => {
            app.emit("peer-state-changed", (peer_id, state))
        }
        Event::PeerLeft { peer_id } => app.emit("peer-left", peer_id),
    };

    if let Err(e) = result {
        eprintln!("Failed to emit event: {:?}", e);
    }
}
