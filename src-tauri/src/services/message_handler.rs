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
        Message::StateUpdate { peer_id, state } => handle_state_update(peer_id, state, ctx).await,
        Message::PeerLeaving { peer_id } => handle_peer_leaving(peer_id, ctx).await,
        Message::LightActivated { light } => handle_light_activated(light, ctx).await,
        Message::LightDeactivated { light } => handle_light_deactivated(light, ctx).await,
        Message::LightCommentAdded { light } => handle_light_comment_added(light, ctx).await,
        Message::LightPriorityChanged { light } => handle_light_priority_changed(light, ctx).await,
        Message::LightSyncRequest => {
            handle_light_sync_request(&peer_id, ctx, network.clone()).await
        }
        Message::LightSyncResponse { lights } => handle_light_sync_response(lights, ctx).await,

        // Controller messages (pub/sub pattern)
        Message::ControllerElected {
            controller_id,
            controller_name,
        } => handle_controller_elected(controller_id, controller_name, ctx).await,
        Message::ControllerResigned { controller_id } => {
            handle_controller_resigned(controller_id, ctx).await
        }
        Message::ConfigSyncRequest { from_peer } => {
            handle_config_sync_request(from_peer, ctx, network.clone()).await
        }
        Message::ConfigUpdate {
            config,
            from_controller,
        } => handle_config_update(config, from_controller, ctx, network).await,
        Message::GlobalStatusCommand {
            color,
            reason,
            from_controller,
        } => handle_global_status_command(color, reason, from_controller, ctx, network).await,
        Message::TaskAssignment {
            target_peer,
            task,
            from_controller,
        } => handle_task_assignment(target_peer, task, from_controller, my_peer_id, ctx).await,
        Message::StatusOverride {
            peer_id,
            reason,
            original_command,
        } => handle_status_override(peer_id, reason, original_command, ctx).await,

        // Deprecated messages - handle for backward compatibility
        #[allow(deprecated)]
        Message::LightConfigRequest => {
            handle_config_sync_request(peer_id.clone(), ctx, network.clone()).await
        }
        #[allow(deprecated)]
        Message::LightConfigSync { config } => {
            // Treat as ConfigUpdate from unknown controller
            handle_config_update(config, peer_id, ctx, network).await
        }

        // Ignored messages
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

async fn handle_light_sync_request<D: DatabaseAdapter, N: NetworkAdapter>(
    peer_id: &PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    log::info!(
        "[MESSAGE_HANDLER] Received LightSyncRequest from {}",
        peer_id.as_str()
    );

    let lights = ctx.database.get_all_lights().await?;
    log::info!("[MESSAGE_HANDLER] Sending {} lights to peer", lights.len());

    let message = Message::LightSyncResponse { lights };
    network.send_to_peer(peer_id, message).await?;

    Ok(())
}

async fn handle_light_sync_response<D: DatabaseAdapter>(
    lights: Vec<Light>,
    ctx: &MessageContext<D>,
) -> Result<()> {
    log::info!(
        "[MESSAGE_HANDLER] Received LightSyncResponse with {} lights",
        lights.len()
    );

    for light in lights {
        log::info!("[MESSAGE_HANDLER] Syncing light: {:?}", light.id);
        ctx.database.save_light(&light).await?;

        // Emit appropriate event based on light state
        if light.is_active() {
            let _ = ctx.event_tx.send(Event::LightActivated {
                light: light.clone(),
            });
        } else {
            let _ = ctx.event_tx.send(Event::LightDeactivated {
                light: light.clone(),
            });
        }
    }

    log::info!("[MESSAGE_HANDLER] Light sync completed");
    Ok(())
}

// ========================================
// Controller Message Handlers
// ========================================

async fn handle_controller_elected<D: DatabaseAdapter>(
    controller_id: PeerId,
    controller_name: String,
    ctx: &MessageContext<D>,
) -> Result<()> {
    log::info!(
        "[CONTROLLER] Controller elected: {} ({})",
        controller_name,
        controller_id
    );

    if let Some(controller_service) = &ctx.controller_service {
        controller_service
            .set_controller(controller_id.clone(), controller_name.clone())
            .await;
    }

    let _ = ctx.event_tx.send(Event::ControllerElected {
        controller_id,
        controller_name,
    });

    Ok(())
}

async fn handle_controller_resigned<D: DatabaseAdapter>(
    controller_id: PeerId,
    ctx: &MessageContext<D>,
) -> Result<()> {
    log::info!("[CONTROLLER] Controller resigned: {}", controller_id);

    if let Some(controller_service) = &ctx.controller_service {
        controller_service.clear_controller().await;
    }

    let _ = ctx
        .event_tx
        .send(Event::ControllerResigned { controller_id });

    Ok(())
}

async fn handle_config_sync_request<D: DatabaseAdapter, N: NetworkAdapter>(
    from_peer: PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    log::info!("[CONFIG] Config sync requested by: {}", from_peer);

    if let Some(config_service) = &ctx.config_service {
        let config = config_service.get_config().await;

        let response = Message::ConfigUpdate {
            config,
            from_controller: ctx.my_peer_id.clone(),
        };

        if let Err(e) = network.broadcast(response).await {
            log::error!("[CONFIG] Failed to send config update: {:?}", e);
        }
    }

    Ok(())
}

async fn handle_config_update<D: DatabaseAdapter, N: NetworkAdapter>(
    config: crate::domain::LightConfig,
    from_controller: PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    log::info!(
        "[CONFIG] Received config update from controller: {}",
        from_controller
    );

    if let Some(controller_service) = &ctx.controller_service
        && controller_service.is_controller().await
    {
        log::info!("[CONFIG] Ignoring config update - we are the controller");
        return Ok(());
    }

    if let Some(config_service) = &ctx.config_service {
        config_service
            .replace_config(&config)
            .await
            .map_err(crate::adapters::AdapterError::Database)?;

        let _ = ctx.event_tx.send(Event::LightConfigChanged {
            config: config.clone(),
        });

        check_if_light_disabled_and_turn_off(ctx, network).await?;
    }

    Ok(())
}

async fn handle_global_status_command<D: DatabaseAdapter, N: NetworkAdapter>(
    color: crate::domain::LightColor,
    reason: String,
    from_controller: PeerId,
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    log::info!(
        "[GLOBAL] Global status command from {}: {:?} - {}",
        from_controller,
        color,
        reason
    );

    let timestamp = crate::domain::current_timestamp_secs();
    let my_peer = ctx.database.get_my_peer().await?;
    let new_state = LightState::new(color, my_peer.light_state.vector_clock.clone(), timestamp);

    ctx.database.update_my_light_state(&new_state).await?;

    let updated_peer = ctx.database.get_my_peer().await?;
    let announcement = Message::PeerAnnouncement { peer: updated_peer };

    network.broadcast(announcement).await?;

    let _ = ctx.event_tx.send(Event::MyStateChanged {
        state: new_state.clone(),
    });

    Ok(())
}

async fn handle_task_assignment<D: DatabaseAdapter>(
    target_peer: PeerId,
    task: String,
    from_controller: PeerId,
    my_peer_id: &PeerId,
    _ctx: &MessageContext<D>,
) -> Result<()> {
    if target_peer != *my_peer_id {
        return Ok(());
    }

    log::info!("[TASK] Task assigned from {}: {}", from_controller, task);

    // TODO: Emit task assignment event to frontend
    // For now, just log it

    Ok(())
}

async fn handle_status_override<D: DatabaseAdapter>(
    peer_id: PeerId,
    reason: String,
    original_command: crate::domain::LightColor,
    _ctx: &MessageContext<D>,
) -> Result<()> {
    log::info!(
        "[OVERRIDE] Peer {} overrode {:?}: {}",
        peer_id,
        original_command,
        reason
    );

    // TODO: Notify controller that follower overrode global status

    Ok(())
}

async fn check_if_light_disabled_and_turn_off<D: DatabaseAdapter, N: NetworkAdapter>(
    ctx: &MessageContext<D>,
    network: Arc<N>,
) -> Result<()> {
    let my_peer = ctx.database.get_my_peer().await?;
    let current_color = my_peer.light_state.color.clone();

    if current_color == crate::domain::LightColor::Off {
        return Ok(());
    }

    if let Some(config_service) = &ctx.config_service {
        let config = config_service.get_config().await;

        let is_enabled = config
            .definitions
            .iter()
            .any(|def| !def.is_deleted() && def.enabled && def.color == current_color);

        if !is_enabled {
            log::info!(
                "[CONFIG] Current light {:?} is now disabled, turning off",
                current_color
            );

            let timestamp = crate::domain::current_timestamp_secs();
            let new_state = LightState::new(
                crate::domain::LightColor::Off,
                my_peer.light_state.vector_clock.clone(),
                timestamp,
            );

            ctx.database.update_my_light_state(&new_state).await?;

            let updated_peer = ctx.database.get_my_peer().await?;
            let announcement = Message::PeerAnnouncement { peer: updated_peer };

            network.broadcast(announcement).await?;

            let _ = ctx.event_tx.send(Event::MyStateChanged {
                state: new_state.clone(),
            });
        }
    }

    Ok(())
}

#[cfg(test)]
mod tests;
