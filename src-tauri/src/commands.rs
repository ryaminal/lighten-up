use crate::domain::{LightColor, LightState, PeerInfo};
use tauri::State;

type AppServices = crate::app_state::AppState<
    crate::database::SqliteDatabase,
    crate::network::MdnsNetwork<crate::encryption::ChaCha20Encryption>,
>;

/// Set the light color for this peer
#[tauri::command]
pub async fn set_light_color(
    state: State<'_, AppServices>,
    color: LightColor,
) -> Result<(), String> {
    state
        .light_service
        .set_light_color(color)
        .await
        .map_err(|e| format!("Failed to set light color: {:?}", e))
}

/// Get my current light state
#[tauri::command]
pub async fn get_my_state(state: State<'_, AppServices>) -> Result<LightState, String> {
    Ok(state.light_service.get_my_state().await)
}

/// Get all known peers
#[tauri::command]
pub async fn get_peers(state: State<'_, AppServices>) -> Result<Vec<PeerInfo>, String> {
    Ok(state.peer_service.get_peers().await)
}
