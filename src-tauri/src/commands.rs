use crate::adapters::{Message, NetworkAdapter};
use crate::domain::{Light, LightColor, LightId, PeerInfo};
use tauri::State;

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
pub async fn create_light(
    state: State<'_, AppServices>,
    name: String,
) -> Result<Light, String> {
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
