use crate::adapters::{Message, NetworkAdapter};
use crate::app_state::AppState;
use crate::database::Database;
use crate::domain::PeerId;
use crate::encryption::ChaCha20Encryption;
use crate::network::MdnsNetwork;
use crate::services::{ChatService, ConfigService, PresenceService};
use std::sync::Arc;
use tauri::{AppHandle, Emitter};

type AppNetwork = MdnsNetwork<ChaCha20Encryption>;

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

/// Initialize all services
pub async fn initialize_services(app: &AppHandle) -> Result<AppState, String> {
    log::info!("Initializing services");

    // Get data directory
    let data_dir = get_data_dir()?;
    let db_path = data_dir.join("lighten-up.db");

    // Create database
    let database = Arc::new(
        Database::new(db_path).map_err(|e| format!("Failed to create database: {}", e))?,
    );

    // Initialize peer identity
    let (peer_id_str, peer_name) = initialize_peer_identity(&database)?;
    log::info!("Peer identity: {} ({})", peer_name, peer_id_str);

    // Create PeerId for network layer
    let peer_id = PeerId::new(peer_id_str.clone());

    // Create encryption and network
    let passphrase = std::env::var("LIGHTEN_UP_PASSPHRASE")
        .unwrap_or_else(|_| "default-passphrase".to_string());
    let encryption = create_encryption(&passphrase)?;
    let network = create_network(peer_id, encryption).await?;

    // Create services
    let presence_service = Arc::new(PresenceService::new(
        peer_id_str.clone(),
        peer_name.clone(),
    ));
    let config_service = Arc::new(ConfigService::new(database.clone(), peer_id_str.clone()));
    let chat_service = Arc::new(ChatService::new(
        database.connection(),
        peer_id_str.clone(),
        peer_name,
    ));

    // Set up message routing
    setup_message_routing(
        app.clone(),
        network.clone(),
        presence_service.clone(),
        config_service.clone(),
        chat_service.clone(),
    );

    // Start background tasks
    spawn_heartbeat_task(network.clone(), presence_service.clone());
    spawn_cleanup_task(presence_service.clone());

    Ok(AppState::new(
        network,
        peer_id_str,
        presence_service,
        config_service,
        chat_service,
        database,
    ))
}

fn get_data_dir() -> Result<std::path::PathBuf, String> {
    let data_dir = if let Ok(custom_dir) = std::env::var("LIGHTEN_UP_DATA_DIR") {
        log::info!("Using custom data directory: {}", custom_dir);
        std::path::PathBuf::from(custom_dir)
    } else {
        dirs::data_local_dir()
            .map(|p| p.join("com.lighten-up.app"))
            .ok_or_else(|| "Failed to get data directory".to_string())?
    };

    std::fs::create_dir_all(&data_dir)
        .map_err(|e| format!("Failed to create data directory: {}", e))?;

    Ok(data_dir)
}

fn initialize_peer_identity(db: &Arc<Database>) -> Result<(String, String), String> {
    let peer_id = if let Ok(cli_id) = std::env::var("LIGHTEN_UP_PEER_ID") {
        log::info!("Using peer ID from CLI: {}", cli_id);
        cli_id
    } else {
        db.get_setting("peer_id").unwrap_or_else(|| {
            // Get hostname for generating peer_id
            let hostname = std::env::var("HOSTNAME")
                .or_else(|_| std::env::var("COMPUTERNAME"))
                .unwrap_or_else(|_| "unknown".to_string());
            let id = crate::utils::generate_peer_id(&hostname);
            db.set_setting("peer_id", &id)
                .expect("Failed to save peer_id");
            log::info!("Generated new peer ID: {}", id);
            id
        })
    };

    let peer_name = if let Ok(cli_name) = std::env::var("LIGHTEN_UP_PEER_NAME") {
        log::info!("Using peer name from CLI: {}", cli_name);
        db.set_setting("peer_name", &cli_name)
            .expect("Failed to save peer_name");
        cli_name
    } else {
        db.get_setting("peer_name").unwrap_or_else(|| {
            let name = std::env::var("HOSTNAME")
                .or_else(|_| std::env::var("COMPUTERNAME"))
                .unwrap_or_else(|_| "Unknown".to_string());
            db.set_setting("peer_name", &name)
                .expect("Failed to save peer_name");
            log::info!("Using hostname as peer name: {}", name);
            name
        })
    };

    Ok((peer_id, peer_name))
}

fn setup_message_routing(
    app: AppHandle,
    network: Arc<AppNetwork>,
    presence: Arc<PresenceService>,
    config: Arc<ConfigService>,
    chat: Arc<ChatService>,
) {
    tokio::spawn(async move {
        log::info!("[MESSAGE_ROUTING] Message routing task started");

        loop {
            match network.receive().await {
                Ok((_peer_id, msg)) => {
                    match msg {
                        Message::Presence(p) => {
                            log::debug!("[MESSAGE_ROUTING] Received presence message");
                            match p {
                                // Normal online/goodbye handling
                                crate::protocol::messages::PresenceMessage::Online { .. }
                                | crate::protocol::messages::PresenceMessage::Goodbye { .. } => {
                                    presence.handle_presence(p).await;
                                }
                                // A peer is asking for status – reply directly to them
                                crate::protocol::messages::PresenceMessage::RequestStatus { peer_id } => {
                                    // Build our current presence and send back to the requester
                                let my_presence = presence.get_my_presence().await;
                                let reply = Message::Presence(my_presence);
                                // Send directly to the requesting peer using its ID
                                let target_peer = crate::domain::PeerId::new(peer_id.clone());
                                if let Err(e) = network.send_to_peer(&target_peer, reply).await {
                                    log::error!("[MESSAGE_ROUTING] Failed to reply to status request: {}", e);
                                }
                                }
                            }

                            // Emit event to frontend
                            let peers = presence.get_all_peers().await;
                            if let Err(e) = app.emit("peers-changed", peers) {
                                log::error!("[MESSAGE_ROUTING] Failed to emit peers-changed: {}", e);
                            }
                        }
                        Message::Config(c) => {
                            log::debug!("[MESSAGE_ROUTING] Received config message");
                            if let Err(e) = config.handle_config_message(c).await {
                                log::error!("[MESSAGE_ROUTING] Failed to handle config: {}", e);
                            }
                            
                            // Emit event to frontend
                            match config.get_all_lights().await {
                                Ok(lights) => {
                                    if let Err(e) = app.emit("lights-changed", lights) {
                                        log::error!("[MESSAGE_ROUTING] Failed to emit lights-changed: {}", e);
                                    }
                                }
                                Err(e) => log::error!("[MESSAGE_ROUTING] Failed to get lights: {}", e),
                            }
                        }
                        Message::Chat(c) => {
                            log::debug!("[MESSAGE_ROUTING] Received chat message");
                            if let Err(e) = chat.handle_message(c.clone()).await {
                                log::error!("[MESSAGE_ROUTING] Failed to handle chat: {}", e);
                            }
                            
                            // Emit event to frontend
                            if let Err(e) = app.emit("chat-message", c) {
                                log::error!("[MESSAGE_ROUTING] Failed to emit chat-message: {}", e);
                            }
                        }
                    }
                }
                Err(e) => {
                    log::error!("[MESSAGE_ROUTING] Error receiving message: {}", e);
                    tokio::time::sleep(tokio::time::Duration::from_millis(100)).await;
                }
            }
        }
    });
}

fn spawn_heartbeat_task(network: Arc<AppNetwork>, presence: Arc<PresenceService>) {
    // Clone for use after moving into the heartbeat task.
    let net_for_heartbeat = network.clone();
    let pres_for_heartbeat = presence.clone();

    tokio::spawn(async move {
        log::info!("[HEARTBEAT] Heartbeat task started, broadcasting every 30s");
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(30));
        loop {
            interval.tick().await;
            let msg = pres_for_heartbeat.get_my_presence().await;
            log::info!("[HEARTBEAT] Broadcasting presence");

            let message = Message::Presence(msg);
            if let Err(e) = net_for_heartbeat.broadcast(message).await {
                log::error!("[HEARTBEAT] Failed to broadcast: {}", e);
            }
        }
    });

    // Immediately broadcast a status request so newly started client learns about existing peers.
    let request = crate::protocol::messages::PresenceMessage::RequestStatus {
        peer_id: presence.get_my_peer_id(),
    };
    let net_clone = network.clone();
    tokio::spawn(async move {
        if let Err(e) = net_clone.broadcast(Message::Presence(request)).await {
            log::error!("[INIT] Failed to broadcast status request: {}", e);
        }
    });
}

fn spawn_cleanup_task(presence: Arc<PresenceService>) {
    tokio::spawn(async move {
        log::info!("[CLEANUP] Cleanup task started");
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(30));
        loop {
            interval.tick().await;
            presence.cleanup_stale_peers().await;
        }
    });
}
