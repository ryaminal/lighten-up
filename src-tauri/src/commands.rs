use crate::adapters::{Message, NetworkAdapter};
use crate::domain::{
    Light, LightColor, LightConfig, LightDefinition, LightDefinitionId, LightId, PeerInfo,
};
use tauri::{Emitter, State};

type AppServices = crate::app_state::AppState<
    crate::database::StoreDatabase,
    crate::network::MdnsNetwork<crate::encryption::ChaCha20Encryption>,
>;

/// Set the light color for this peer
#[tauri::command]
pub async fn set_light_color(
    state: State<'_, AppServices>,
    color: LightColor,
) -> Result<String, String> {
    log::info!("[CMD] Command: set_light_color({:?})", color);
    state
        .light_service
        .set_light_color(color)
        .await
        .map_err(|e| format!("Failed to set light color: {:?}", e))?;
    log::info!("[OK] Command completed, returning 'success'");
    Ok("success".to_string())
}

/// Set the light color and note for this peer
#[tauri::command]
pub async fn set_light_status(
    state: State<'_, AppServices>,
    color: LightColor,
    note: Option<String>,
) -> Result<String, String> {
    log::info!("[CMD] Command: set_light_status({:?}, {:?})", color, note);

    // Check if the color is enabled in the configuration
    // Off is always allowed
    if color != LightColor::Off {
        let config = state.config_service.get_config().await;
        let is_enabled = config
            .definitions
            .iter()
            .any(|def| def.color == color && def.enabled);

        if !is_enabled {
            log::warn!("[CMD] Attempted to set disabled light color: {:?}", color);
            return Err(format!("Light color {:?} is not enabled", color));
        }
    }

    state
        .light_service
        .set_light_status(color, note)
        .await
        .map_err(|e| format!("Failed to set light status: {:?}", e))?;
    log::info!("[OK] Command completed, returning 'success'");
    Ok("success".to_string())
}

/// Get my current light state
#[tauri::command]
pub async fn get_my_state(state: State<'_, AppServices>) -> Result<PeerInfo, String> {
    state
        .light_service
        .get_my_peer_info()
        .await
        .map_err(|e| format!("Failed to get my state: {:?}", e))
}

/// Get all known peers
#[tauri::command]
pub async fn get_peers(state: State<'_, AppServices>) -> Result<Vec<PeerInfo>, String> {
    Ok(state.peer_service.get_peers().await)
}

/// Create a new light
#[tauri::command]
pub async fn create_light(state: State<'_, AppServices>, name: String) -> Result<Light, String> {
    let peer_id = state.my_peer_id.clone();
    let light_id = LightId::new(format!("{}-{}", peer_id.as_str(), name));
    let light = Light::new(light_id, name);
    save_light(&state, &light).await?;
    Ok(light)
}

/// Activate a light
#[tauri::command]
pub async fn activate_light(
    state: State<'_, AppServices>,
    light_id: String,
) -> Result<Light, String> {
    let light_id = LightId::new(light_id);
    let peer_id = state.my_peer_id.clone();
    let mut light = get_light(&state, &light_id).await?;
    light.activate(peer_id);
    let msg = Message::LightActivated {
        light: light.clone(),
    };
    save_and_broadcast(&state, &light, msg).await?;
    Ok(light)
}

/// Deactivate a light
#[tauri::command]
pub async fn deactivate_light(
    state: State<'_, AppServices>,
    light_id: String,
) -> Result<Light, String> {
    let light_id = LightId::new(light_id);
    let mut light = get_light(&state, &light_id).await?;
    light.deactivate();
    let msg = Message::LightDeactivated {
        light: light.clone(),
    };
    save_and_broadcast(&state, &light, msg).await?;
    Ok(light)
}

/// Add a comment to a light
#[tauri::command]
pub async fn add_light_comment(
    state: State<'_, AppServices>,
    light_id: String,
    text: String,
) -> Result<Light, String> {
    let light_id = LightId::new(light_id);
    let peer_id = state.my_peer_id.clone();
    let mut light = get_light(&state, &light_id).await?;
    light.add_comment(text, peer_id);
    let msg = Message::LightCommentAdded {
        light: light.clone(),
    };
    save_and_broadcast(&state, &light, msg).await?;
    Ok(light)
}

/// Get all lights
#[tauri::command]
pub async fn get_all_lights(state: State<'_, AppServices>) -> Result<Vec<Light>, String> {
    state
        .light_service
        .get_all_lights()
        .await
        .map_err(|e| format!("Failed to get lights: {:?}", e))
}

async fn get_light(state: &AppServices, light_id: &LightId) -> Result<Light, String> {
    state
        .light_service
        .get_light(light_id)
        .await
        .map_err(|e| format!("Failed to get light: {:?}", e))
}

async fn save_and_broadcast(
    state: &AppServices,
    light: &Light,
    message: Message,
) -> Result<(), String> {
    save_light(state, light).await?;
    broadcast_message(state, message).await?;
    Ok(())
}

async fn save_light(state: &AppServices, light: &Light) -> Result<(), String> {
    state
        .light_service
        .save_light(light)
        .await
        .map_err(|e| format!("Failed to save light: {:?}", e))
}

async fn broadcast_message(state: &AppServices, message: Message) -> Result<(), String> {
    state
        .network
        .broadcast(message)
        .await
        .map_err(|e| format!("Failed to broadcast: {:?}", e))
}

// ========================================
// Controller Commands
// ========================================

/// Get controller information
#[tauri::command]
pub async fn get_controller_info(
    state: State<'_, AppServices>,
) -> Result<Option<crate::services::ControllerInfo>, String> {
    Ok(state.controller_service.get_controller().await)
}

/// Get my controller role
#[tauri::command]
pub async fn get_my_role(state: State<'_, AppServices>) -> Result<crate::domain::PeerRole, String> {
    Ok(state.controller_service.get_my_role().await)
}

/// Become the network controller
#[tauri::command]
pub async fn become_controller(state: State<'_, AppServices>) -> Result<(), String> {
    log::info!("[CMD] Command: become_controller");

    let my_peer = state
        .light_service
        .get_my_peer_info()
        .await
        .map_err(|e| format!("Failed to get my state: {:?}", e))?;

    state
        .controller_service
        .become_controller(my_peer.name.clone())
        .await;

    let msg = Message::ControllerElected {
        controller_id: state.my_peer_id.clone(),
        controller_name: my_peer.name.clone(),
    };

    state
        .network
        .broadcast(msg)
        .await
        .map_err(|e| format!("Failed to broadcast: {:?}", e))?;

    log::info!("[OK] Command completed - now controller");
    Ok(())
}

/// Resign as network controller
#[tauri::command]
pub async fn resign_controller(state: State<'_, AppServices>) -> Result<(), String> {
    log::info!("[CMD] Command: resign_controller");

    if !state.controller_service.is_controller().await {
        return Err("Not currently the controller".to_string());
    }

    state.controller_service.resign_controller().await;

    let msg = Message::ControllerResigned {
        controller_id: state.my_peer_id.clone(),
    };

    state
        .network
        .broadcast(msg)
        .await
        .map_err(|e| format!("Failed to broadcast: {:?}", e))?;

    log::info!("[OK] Command completed - resigned as controller");
    Ok(())
}

/// Get the current light configuration
#[tauri::command]
pub async fn get_light_config(state: State<'_, AppServices>) -> Result<LightConfig, String> {
    log::info!("[CMD] Command: get_light_config");
    let config = state.config_service.get_config().await;
    log::info!(
        "[OK] Command completed, returning config with {} definitions",
        config.definitions.len()
    );
    Ok(config)
}

/// Update or create a light definition
#[tauri::command]
pub async fn update_light_definition(
    state: State<'_, AppServices>,
    app: tauri::AppHandle,
    definition: LightDefinition,
) -> Result<(), String> {
    log::info!(
        "[CMD] Command: update_light_definition({:?})",
        definition.id
    );

    let mut config = state.config_service.get_config().await;

    // Check if this definition is being disabled
    let is_being_disabled = !definition.enabled;
    let color = definition.color.clone();

    // Find and update or add new definition
    if let Some(idx) = config
        .definitions
        .iter()
        .position(|d| d.id == definition.id)
    {
        config.definitions[idx] = definition;
    } else {
        config.definitions.push(definition);
    }

    // Save updated config
    state
        .config_service
        .update_config(config.clone())
        .await
        .map_err(|e| format!("Failed to update config: {:?}", e))?;

    // If this light was disabled, turn it off if it's currently active
    if is_being_disabled {
        let my_state = state
            .light_service
            .get_my_peer_info()
            .await
            .map_err(|e| format!("Failed to get my state: {:?}", e))?;

        if my_state.light_state.color == color {
            log::info!(
                "[CMD] Light {:?} was disabled and is currently active, turning off",
                color
            );
            state
                .light_service
                .set_light_status(LightColor::Off, None)
                .await
                .map_err(|e| format!("Failed to turn off light: {:?}", e))?;
        }
    }

    // Emit event to frontend
    if let Err(e) = app.emit("light-config-changed", &config) {
        log::error!("Failed to emit light-config-changed event: {:?}", e);
    }

    // Broadcast the update (controllers publish config to followers)
    let msg = Message::ConfigUpdate {
        config: config.clone(),
        from_controller: state.my_peer_id.clone(),
    };
    log::info!(
        "[CMD] Broadcasting ConfigUpdate after update - enabled lights: {}",
        config
            .definitions
            .iter()
            .filter(|d| d.enabled && d.deleted_at.is_none())
            .count()
    );
    state
        .network
        .broadcast(msg)
        .await
        .map_err(|e| format!("Failed to broadcast config: {:?}", e))?;

    log::info!("[OK] Command completed");
    Ok(())
}

/// Delete a light definition
#[tauri::command]
pub async fn delete_light_definition(
    state: State<'_, AppServices>,
    app: tauri::AppHandle,
    id: String,
) -> Result<(), String> {
    log::info!("[CMD] Command: delete_light_definition({})", id);

    let definition_id = LightDefinitionId::from(id);

    let mut config = state.config_service.get_config().await;

    // Find the definition and mark it as deleted (tombstone)
    let deleted_color = config
        .definitions
        .iter_mut()
        .find(|d| d.id == definition_id)
        .map(|def| {
            let color = def.color.clone();
            def.deleted_at = Some(crate::domain::current_timestamp_secs());
            def.updated_at = crate::domain::current_timestamp_secs();
            color
        });

    if deleted_color.is_none() {
        return Err("Light definition not found".to_string());
    }

    // Save updated config
    state
        .config_service
        .update_config(config.clone())
        .await
        .map_err(|e| format!("Failed to update config: {:?}", e))?;

    // If this light was active, turn it off
    if let Some(color) = deleted_color {
        let my_state = state
            .light_service
            .get_my_peer_info()
            .await
            .map_err(|e| format!("Failed to get my state: {:?}", e))?;

        if my_state.light_state.color == color {
            log::info!(
                "[CMD] Light {:?} was deleted and is currently active, turning off",
                color
            );
            state
                .light_service
                .set_light_status(LightColor::Off, None)
                .await
                .map_err(|e| format!("Failed to turn off light: {:?}", e))?;
        }
    }

    // Emit event to frontend
    if let Err(e) = app.emit("light-config-changed", &config) {
        log::error!("Failed to emit light-config-changed event: {:?}", e);
    }

    // Broadcast the update (including tombstone)
    let msg = Message::ConfigUpdate {
        config: config.clone(),
        from_controller: state.my_peer_id.clone(),
    };
    log::info!(
        "[CMD] Broadcasting ConfigUpdate with {} definitions ({} deleted)",
        config.definitions.len(),
        config
            .definitions
            .iter()
            .filter(|d| d.deleted_at.is_some())
            .count()
    );
    state
        .network
        .broadcast(msg)
        .await
        .map_err(|e| format!("Failed to broadcast config: {:?}", e))?;

    log::info!("[OK] Command completed");
    Ok(())
}
