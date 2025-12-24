use crate::adapters::DatabaseAdapter;
use crate::domain::{Event, PeerId, PeerInfo, current_timestamp_secs};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast, watch};

/// Default timeout in seconds after which a peer is considered stale
pub const PEER_TIMEOUT_SECS: u64 = 90;

/// How often to check for stale peers (in seconds)
const CLEANUP_INTERVAL_SECS: u64 = 30;

/// Start a background task to periodically check for and remove stale peers
pub fn start_stale_peer_cleanup<D>(
    peers: Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    database: Arc<D>,
    event_tx: broadcast::Sender<Event>,
    mut shutdown_rx: watch::Receiver<bool>,
) where
    D: DatabaseAdapter + 'static,
{
    tokio::spawn(async move {
        loop {
            tokio::select! {
                _ = shutdown_rx.changed() => {
                    log::info!("[CLEANUP] Stopping stale peer cleanup task");
                    break;
                }
                _ = tokio::time::sleep(tokio::time::Duration::from_secs(CLEANUP_INTERVAL_SECS)) => {
                    cleanup_stale_peers(&peers, &database, &event_tx).await;
                }
            }
        }
    });

    log::info!(
        "[CLEANUP] Started stale peer cleanup task (timeout: {}s, interval: {}s)",
        PEER_TIMEOUT_SECS,
        CLEANUP_INTERVAL_SECS
    );
}

/// Check for and remove stale peers
async fn cleanup_stale_peers<D>(
    peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    database: &Arc<D>,
    event_tx: &broadcast::Sender<Event>,
) where
    D: DatabaseAdapter,
{
    let mut peers_guard = peers.write().await;
    let stale_peer_ids = find_stale_peers(&peers_guard);

    for peer_id in stale_peer_ids {
        remove_stale_peer(&mut peers_guard, peer_id, database, event_tx).await;
    }
}

fn find_stale_peers(peers: &HashMap<PeerId, PeerInfo>) -> Vec<PeerId> {
    peers
        .iter()
        .filter(|(_, peer)| peer.is_stale(PEER_TIMEOUT_SECS))
        .map(|(id, peer)| {
            log_stale_peer(peer, id);
            id.clone()
        })
        .collect()
}

fn log_stale_peer(peer: &PeerInfo, id: &PeerId) {
    let elapsed = current_timestamp_secs().saturating_sub(peer.last_seen);

    log::warn!(
        "[CLEANUP] Removing stale peer {} ({}) - last seen {}s ago",
        peer.name,
        id.as_str(),
        elapsed
    );
}

async fn remove_stale_peer<D>(
    peers: &mut HashMap<PeerId, PeerInfo>,
    peer_id: PeerId,
    database: &Arc<D>,
    event_tx: &broadcast::Sender<Event>,
) where
    D: DatabaseAdapter,
{
    peers.remove(&peer_id);
    if let Err(e) = database.delete_peer(&peer_id).await {
        log::error!("Failed to delete stale peer {}: {:?}", peer_id.as_str(), e);
    }
    let _ = event_tx.send(Event::PeerLeft { peer_id });
}
