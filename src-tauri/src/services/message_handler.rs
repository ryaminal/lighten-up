use crate::adapters::{DatabaseAdapter, Message, Result};
use crate::domain::{Event, LightState, PeerId, PeerInfo};
use crate::services::MessageContext;

/// Handle incoming message from a peer
pub async fn handle_message<D: DatabaseAdapter>(
    my_peer_id: &PeerId,
    peer_id: PeerId,
    message: Message,
    ctx: &MessageContext<D>,
) -> Result<()> {
    if peer_id == *my_peer_id {
        return Ok(());
    }

    // Update last_seen for this peer on any message
    touch_peer_last_seen(&peer_id, ctx).await?;

    match message {
        Message::PeerAnnouncement { peer } => handle_peer_announcement(peer, ctx).await,
        Message::StateUpdate { peer_id, state } => handle_state_update(peer_id, state, ctx).await,
        Message::PeerLeaving { peer_id } => handle_peer_leaving(peer_id, ctx).await,
        Message::Heartbeat { .. }
        | Message::StateSyncRequest
        | Message::ApplicationMessage { .. }
        | Message::StateSyncResponse { .. } => Ok(()),
    }
}

/// Update the last_seen timestamp for a peer
async fn touch_peer_last_seen<D: DatabaseAdapter>(
    peer_id: &PeerId,
    ctx: &MessageContext<D>,
) -> Result<()> {
    let mut peers_guard = ctx.peers.write().await;
    if let Some(peer) = peers_guard.get_mut(peer_id) {
        peer.touch();
        ctx.database.save_peer(peer).await?;
    }
    Ok(())
}

async fn handle_peer_announcement<D: DatabaseAdapter>(
    mut peer: PeerInfo,
    ctx: &MessageContext<D>,
) -> Result<()> {
    let peer_id = peer.id.clone();
    let is_new = !ctx.peers.write().await.contains_key(&peer_id);

    log::info!(
        "[PEER] {} peer announcement from {} ({})",
        if is_new { "New" } else { "Updated" },
        peer.name,
        peer_id.as_str()
    );

    peer.touch();
    ctx.database.save_peer(&peer).await?;
    ctx.peers.write().await.insert(peer_id, peer.clone());

    let _ = ctx.event_tx.send(Event::PeerDiscovered { peer });
    Ok(())
}

async fn handle_state_update<D: DatabaseAdapter>(
    peer_id: PeerId,
    new_state: LightState,
    ctx: &MessageContext<D>,
) -> Result<()> {
    let mut peers_guard = ctx.peers.write().await;

    let merged_state = if let Some(existing_peer) = peers_guard.get(&peer_id) {
        let mut state = existing_peer.light_state.clone();
        state.merge(&new_state);
        state
    } else {
        new_state.clone()
    };

    if let Some(peer) = peers_guard.get_mut(&peer_id) {
        peer.light_state = merged_state.clone();
        peer.touch();
        ctx.database.save_peer(peer).await?;
    }

    let _ = ctx.event_tx.send(Event::PeerStateChanged {
        peer_id,
        state: merged_state,
    });

    Ok(())
}

async fn handle_peer_leaving<D: DatabaseAdapter>(
    peer_id: PeerId,
    ctx: &MessageContext<D>,
) -> Result<()> {
    ctx.peers.write().await.remove(&peer_id);
    ctx.database.delete_peer(&peer_id).await?;

    let _ = ctx.event_tx.send(Event::PeerLeft { peer_id });

    Ok(())
}

#[cfg(test)]
mod tests;
