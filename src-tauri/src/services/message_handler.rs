use crate::adapters::{DatabaseAdapter, Message, Result};
use crate::domain::{Event, LightState, PeerId, PeerInfo};
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

/// Handle incoming message from a peer
pub async fn handle_message<D: DatabaseAdapter>(
    my_peer_id: &PeerId,
    peer_id: PeerId,
    message: Message,
    database: &Arc<D>,
    peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    event_tx: &broadcast::Sender<Event>,
) -> Result<()> {
    if peer_id == *my_peer_id {
        return Ok(());
    }

    match message {
        Message::PeerAnnouncement { peer } => {
            handle_peer_announcement(peer, database, peers, event_tx).await
        }
        Message::StateUpdate { peer_id, state } => {
            handle_state_update(peer_id, state, database, peers, event_tx).await
        }
        Message::PeerLeaving { peer_id } => {
            handle_peer_leaving(peer_id, database, peers, event_tx).await
        }
        Message::Heartbeat { .. } => Ok(()),
        Message::StateSyncRequest | Message::StateSyncResponse { .. } => Ok(()),
        Message::ApplicationMessage { .. } => Ok(()),
    }
}

async fn handle_peer_announcement<D: DatabaseAdapter>(
    peer: PeerInfo,
    database: &Arc<D>,
    peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    event_tx: &broadcast::Sender<Event>,
) -> Result<()> {
    let peer_id = peer.id.clone();
    let is_new = !peers.read().await.contains_key(&peer_id);

    database.save_peer(&peer).await?;
    peers.write().await.insert(peer_id.clone(), peer.clone());

    if is_new {
        let _ = event_tx.send(Event::PeerDiscovered { peer });
    }

    Ok(())
}

async fn handle_state_update<D: DatabaseAdapter>(
    peer_id: PeerId,
    new_state: LightState,
    database: &Arc<D>,
    peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    event_tx: &broadcast::Sender<Event>,
) -> Result<()> {
    let mut peers_guard = peers.write().await;

    let merged_state = if let Some(existing_peer) = peers_guard.get(&peer_id) {
        let mut state = existing_peer.light_state.clone();
        state.merge(&new_state);
        state
    } else {
        new_state.clone()
    };

    if let Some(peer) = peers_guard.get_mut(&peer_id) {
        peer.light_state = merged_state.clone();
        database.save_peer(peer).await?;
    }

    let _ = event_tx.send(Event::PeerStateChanged {
        peer_id,
        state: merged_state,
    });

    Ok(())
}

async fn handle_peer_leaving<D: DatabaseAdapter>(
    peer_id: PeerId,
    database: &Arc<D>,
    peers: &Arc<RwLock<HashMap<PeerId, PeerInfo>>>,
    event_tx: &broadcast::Sender<Event>,
) -> Result<()> {
    peers.write().await.remove(&peer_id);
    database.delete_peer(&peer_id).await?;

    let _ = event_tx.send(Event::PeerLeft { peer_id });

    Ok(())
}

#[cfg(test)]
mod tests;
