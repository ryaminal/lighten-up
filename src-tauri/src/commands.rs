use crate::domain::{LightColor, PeerInfo};
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
