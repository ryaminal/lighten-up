use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{Event, Light, LightState, PeerId, PeerInfo};
use crate::services::MessageContext;
use std::sync::Arc;

/// Handle incoming message from a peer
pub async fn handle_message<D: DatabaseAdapter, N: NetworkAdapter>(
    my_peer_id: &PeerId,
    peer_id: PeerId,
    message: Message,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    if peer_id == *my_peer_id {
        return Ok(());
    }

    // Update last_seen for this peer on any message
    touch_peer_last_seen(&peer_id, ctx).await?;

    match message {
        Message::PeerAnnouncement { peer } => handle_peer_announcement(peer, ctx).await,
        Message::StateUpdate { peer_id, state } => {
            handle_state_update(peer_id, state, ctx).await
        }
        Message::PeerLeaving { peer_id } => handle_peer_leaving(peer_id, ctx).await,
        Message::LightActivated { light } => handle_light_activated(light, ctx).await,
        Message::LightDeactivated { light } => handle_light_deactivated(light, ctx).await,
        Message::LightCommentAdded { light } => handle_light_comment_added(light, ctx).await,
        Message::LightPriorityChanged { light } => {
            handle_light_priority_changed(light, ctx).await
        }
        Message::LightConfigRequest => {
            handle_config_request(&peer_id, ctx, network).await
        }
        Message::LightConfigSync { config } => handle_config_sync(config, ctx).await,
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
        "[PEER] {} peer announcement from {} ({}) - note: {:?}",
        if is_new { "New" } else { "Updated" },
        peer.name,
        peer_id.as_str(),
        peer.note
    );

    peer.touch();
    ctx.database.save_peer(&peer).await?;
    ctx.peers.write().await.insert(peer_id, peer.clone());

    log::info!(
        "[PEER] Sending PeerDiscovered event - peer.note: {:?}",
        peer.note
    );
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

async fn handle_light_activated<D: DatabaseAdapter>(
    light: Light,
    ctx: &MessageContext<D>,
) -> Result<()> {
    ctx.database.save_light(&light).await?;
    let _ = ctx.event_tx.send(Event::LightActivated {
        light: light.clone(),
    });
    Ok(())
}

async fn handle_light_deactivated<D: DatabaseAdapter>(
    light: Light,
    ctx: &MessageContext<D>,
) -> Result<()> {
    ctx.database.save_light(&light).await?;
    let _ = ctx.event_tx.send(Event::LightDeactivated {
        light: light.clone(),
    });
    Ok(())
}

async fn handle_light_comment_added<D: DatabaseAdapter>(
    light: Light,
    ctx: &MessageContext<D>,
) -> Result<()> {
    ctx.database.save_light(&light).await?;
    let _ = ctx.event_tx.send(Event::LightUpdated {
        light: light.clone(),
    });
    Ok(())
}

async fn handle_light_priority_changed<D: DatabaseAdapter>(
    light: Light,
    ctx: &MessageContext<D>,
) -> Result<()> {
    ctx.database.save_light(&light).await?;
    let _ = ctx.event_tx.send(Event::LightUpdated {
        light: light.clone(),
    });
    Ok(())
}

async fn handle_config_request<D: DatabaseAdapter, N: NetworkAdapter>(
    peer_id: &PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    if let Some(config_service) = &ctx.config_service {
        let config = config_service.get_config().await;
        let message = Message::LightConfigSync { config };
        network.send_to_peer(peer_id, message).await?;
    }
    Ok(())
}

async fn handle_config_sync<D: DatabaseAdapter>(
    config: crate::domain::LightConfig,
    ctx: &MessageContext<D>,
) -> Result<()> {
    if let Some(config_service) = &ctx.config_service {
        config_service
            .merge_config(&config)
            .await
            .map_err(|e| {
                crate::adapters::AdapterError::Database(format!(
                    "Failed to merge config: {}",
                    e
                ))
            })?;

        let merged = config_service.get_config().await;
        let _ = ctx
            .event_tx
            .send(Event::LightConfigChanged { config: merged });
    }
    Ok(())
}

#[cfg(test)]
mod tests;
