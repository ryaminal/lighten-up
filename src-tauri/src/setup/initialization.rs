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
    let database =
        Arc::new(Database::new(db_path).map_err(|e| format!("Failed to create database: {}", e))?);

    // Initialize peer identity
    let (peer_id_str, peer_name) = initialize_peer_identity(&database)?;
    log::info!("Peer identity: {} ({})", peer_name, peer_id_str);

    // Create PeerId for network layer
    let peer_id = PeerId::new(peer_id_str.clone());

    // Create encryption and network
    let passphrase =
        std::env::var("LIGHTEN_UP_PASSPHRASE").unwrap_or_else(|_| "default-passphrase".to_string());
    let encryption = create_encryption(&passphrase)?;
    let network = create_network(peer_id, encryption).await?;

    // Create services
    let presence_service = Arc::new(PresenceService::new(peer_id_str.clone(), peer_name.clone()));
    let config_service = Arc::new(ConfigService::new(database.clone(), peer_id_str.clone()));
    let chat_service = Arc::new(ChatService::new(
        database.connection(),
        peer_id_str.clone(),
        peer_name,
    ));

    // Set up message routing
    setup_message_routing(RoutingContext {
        app: app.clone(),
        network: network.clone(),
        presence: presence_service.clone(),
        config: config_service.clone(),
        chat: chat_service.clone(),
    });

    // Start background tasks
    spawn_heartbeat_task(network.clone(), presence_service.clone());
    spawn_cleanup_task(presence_service.clone(), app.clone());
    spawn_online_presence_task(network.clone(), presence_service.clone());
    spawn_config_sync_task(network.clone(), config_service.clone(), peer_id_str.clone());

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

/// Holds the core services needed for message routing.
struct RoutingContext {
    app: AppHandle,
    network: Arc<AppNetwork>,
    presence: Arc<PresenceService>,
    config: Arc<ConfigService>,
    chat: Arc<ChatService>,
}

fn setup_message_routing(context: RoutingContext) {
    // Destructure the context for easier access
    let RoutingContext {
        app,
        network,
        presence,
        config,
        chat,
    } = context;
    tokio::spawn(async move {
        log::info!("[MESSAGE_ROUTING] Message routing task started");

        loop {
            match network.receive().await {
                Ok((_peer_id, msg)) => {
                    match msg {
                        Message::Presence(p) => {
                            log::debug!("[MESSAGE_ROUTING] Received presence message");
                            if let crate::protocol::messages::PresenceMessage::Goodbye { peer_id } =
                                &p
                            {
                                log::info!(
                                    "[MESSAGE_ROUTING] Received goodbye from peer {}",
                                    peer_id
                                );
                            }

                            match p {
                                // Normal online/goodbye handling
                                crate::protocol::messages::PresenceMessage::Online { .. }
                                | crate::protocol::messages::PresenceMessage::Goodbye { .. } => {
                                    presence.handle_presence(p).await;
                                }
                                // A peer is asking for status – reply directly to them
                                crate::protocol::messages::PresenceMessage::RequestStatus {
                                    peer_id,
                                } => {
                                    log::info!(
                                        "[MESSAGE_ROUTING] Received status request from {}, sending presence",
                                        peer_id
                                    );
                                    // Build our current presence and send back to the requester
                                    let my_presence = presence.get_my_presence().await;
                                    let reply = Message::Presence(my_presence);
                                    // Send directly to the requesting peer using its ID
                                    let target_peer = crate::domain::PeerId::new(peer_id.clone());
                                    if let Err(e) = network.send_to_peer(&target_peer, reply).await
                                    {
                                        log::error!(
                                            "[MESSAGE_ROUTING] Failed to reply to status request: {}",
                                            e
                                        );
                                    } else {
                                        log::info!(
                                            "[MESSAGE_ROUTING] Successfully sent presence to {}",
                                            peer_id
                                        );
                                    }
                                }
                            }

                            // Emit event to frontend
                            let peers = presence.get_all_peers().await;
                            if let Err(e) = app.emit("peers-changed", peers) {
                                log::error!(
                                    "[MESSAGE_ROUTING] Failed to emit peers-changed: {}",
                                    e
                                );
                            }
                        }
                        Message::Config(c) => {
                            log::debug!("[MESSAGE_ROUTING] Received config message");
                            match config.handle_config_message(c.clone()).await {
                                Ok(needs_sync_response) => {
                                    if needs_sync_response {
                                        // This was a RequestSync - send all our configs to the requester
                                        log::info!(
                                            "[MESSAGE_ROUTING] Received config sync request from {}, sending all configs",
                                            c.peer_id
                                        );
                                        let target_peer = crate::domain::PeerId::new(c.peer_id);
                                        match config.get_all_config_messages().await {
                                            Ok(messages) => {
                                                for msg in messages {
                                                    if let Err(e) = network
                                                        .send_to_peer(
                                                            &target_peer,
                                                            Message::Config(msg),
                                                        )
                                                        .await
                                                    {
                                                        log::error!(
                                                            "[MESSAGE_ROUTING] Failed to send config to peer: {}",
                                                            e
                                                        );
                                                    }
                                                }
                                            }
                                            Err(e) => log::error!(
                                                "[MESSAGE_ROUTING] Failed to get config messages: {}",
                                                e
                                            ),
                                        }
                                    }
                                }
                                Err(e) => {
                                    log::error!("[MESSAGE_ROUTING] Failed to handle config: {}", e);
                                }
                            }

                            // Emit event to frontend
                            match config.get_all_lights().await {
                                Ok(lights) => {
                                    log::info!(
                                        "[MESSAGE_ROUTING] Emitting lights-changed with {} lights",
                                        lights.len()
                                    );
                                    if let Err(e) = app.emit("lights-changed", lights) {
                                        log::error!(
                                            "[MESSAGE_ROUTING] Failed to emit lights-changed: {}",
                                            e
                                        );
                                    }
                                }
                                Err(e) => {
                                    log::error!("[MESSAGE_ROUTING] Failed to get lights: {}", e)
                                }
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
                        Message::Notification(notification) => {
                            log::debug!(
                                "[MESSAGE_ROUTING] Received notification type {:?} for peer {}",
                                notification.notification_type,
                                notification.target_peer_id
                            );

                            // Persist notification in presence service
                            presence
                                .set_peer_notification(
                                    notification.target_peer_id.clone(),
                                    notification.clone(),
                                )
                                .await;

                            // Emit peers-changed so UI updates with notification status
                            let peers = presence.get_all_peers().await;
                            if let Err(e) = app.emit("peers-changed", peers) {
                                log::error!(
                                    "[MESSAGE_ROUTING] Failed to emit peers-changed: {}",
                                    e
                                );
                            }

                            let my_peer_id = presence.get_my_peer_id();

                            // Always emit peer-notification-status for card indicators (everyone sees this)
                            if let Err(e) =
                                app.emit("peer-notification-status", notification.clone())
                            {
                                log::error!(
                                    "[MESSAGE_ROUTING] Failed to emit peer-notification-status: {}",
                                    e
                                );
                            }

                            // Only emit to my notification banner if I am the target
                            if notification.target_peer_id == my_peer_id {
                                log::info!(
                                    "[MESSAGE_ROUTING] Notification for me: {} from peer {}",
                                    notification.message,
                                    notification.sender_peer_id
                                );
                                if let Err(e) = app.emit("notification", notification) {
                                    log::error!(
                                        "[MESSAGE_ROUTING] Failed to emit notification: {}",
                                        e
                                    );
                                }
                            } else {
                                log::debug!(
                                    "[MESSAGE_ROUTING] Notification not for me, but showing status indicator"
                                );
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
        log::info!("[HEARTBEAT] Heartbeat task started, broadcasting every 10s");
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(10));
        loop {
            interval.tick().await;
            let msg = pres_for_heartbeat.get_my_presence().await;
            let message = crate::adapters::message::Message::Presence(msg);

            // Broadcast presence to all peers
            if let Err(e) = net_for_heartbeat.broadcast(message).await {
                log::error!("[HEARTBEAT] Failed to broadcast presence: {}", e);
            }
        }
    });
}

fn spawn_online_presence_task(network: Arc<AppNetwork>, presence: Arc<PresenceService>) {
    // Wait briefly for mDNS discovery, then immediately broadcast presence and request status
    let net_for_online = network.clone();
    let pres_for_online = presence.clone();
    tokio::spawn(async move {
        // Very short delay to allow mDNS to initialize (300ms is enough for local network)
        log::info!("[INIT] Waiting 300ms for mDNS initialization...");
        tokio::time::sleep(tokio::time::Duration::from_millis(300)).await;

        // Broadcast our presence and request status multiple times with short delays
        // This ensures we catch peers even if mDNS discovery is still in progress
        for attempt in 1..=3 {
            log::info!("[INIT] Broadcasting online presence (attempt {})", attempt);
            let online_msg = pres_for_online.get_my_presence().await;
            if let Err(e) = net_for_online
                .broadcast(Message::Presence(online_msg))
                .await
            {
                log::error!("[INIT] Failed to broadcast online presence: {}", e);
            }

            // Small delay between broadcasts
            tokio::time::sleep(tokio::time::Duration::from_millis(50)).await;

            log::info!(
                "[INIT] Broadcasting status request to get immediate peer updates (attempt {})",
                attempt
            );
            let request = crate::protocol::messages::PresenceMessage::RequestStatus {
                peer_id: pres_for_online.get_my_peer_id(),
            };
            if let Err(e) = net_for_online.broadcast(Message::Presence(request)).await {
                log::error!("[INIT] Failed to broadcast status request: {}", e);
            }

            // Wait before next attempt (except on last attempt)
            if attempt < 3 {
                tokio::time::sleep(tokio::time::Duration::from_millis(300)).await;
            }
        }

        log::info!("[INIT] Completed initial presence broadcast sequence");
    });
}

fn spawn_cleanup_task(presence: Arc<PresenceService>, app: AppHandle) {
    tokio::spawn(async move {
        log::info!("[CLEANUP] Cleanup task started, checking every 5s for stale peers");
        let mut interval = tokio::time::interval(tokio::time::Duration::from_secs(5));
        loop {
            interval.tick().await;
            let removed_any = presence.cleanup_stale_peers().await;

            // If we removed stale peers, notify the UI immediately
            if removed_any {
                let peers = presence.get_all_peers().await;
                if let Err(e) = app.emit("peers-changed", peers) {
                    log::error!("[CLEANUP] Failed to emit peers-changed: {}", e);
                }
            }
        }
    });
}

fn spawn_config_sync_task(network: Arc<AppNetwork>, _config: Arc<ConfigService>, peer_id: String) {
    tokio::spawn(async move {
        // Wait briefly for presence broadcasts to complete
        log::info!("[INIT] Waiting 500ms before requesting config sync...");
        tokio::time::sleep(tokio::time::Duration::from_millis(500)).await;

        log::info!("[INIT] Broadcasting config sync request");
        let sync_request = crate::protocol::messages::ConfigMessage {
            op: crate::protocol::messages::ConfigOp::RequestSync {
                peer_id: peer_id.clone(),
            },
            peer_id,
            timestamp: crate::utils::current_timestamp(),
        };

        if let Err(e) = network.broadcast(Message::Config(sync_request)).await {
            log::error!("[INIT] Failed to broadcast config sync request: {}", e);
        }
    });
}
