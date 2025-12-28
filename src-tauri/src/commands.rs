use crate::adapters::{Message, NetworkAdapter};
use crate::app_state::AppState;
use crate::protocol::messages::{ChatMessage, LightConfig, Notification, NotificationType};
use crate::services::PeerPresence;
use tauri::{AppHandle, Emitter, State};

#[tauri::command]
pub async fn get_my_peer_name(state: State<'_, AppState>) -> Result<String, String> {
    Ok(state.presence_service.get_peer_name().await)
}

#[tauri::command]
pub async fn get_my_peer_id(state: State<'_, AppState>) -> Result<String, String> {
    Ok(state.presence_service.get_my_peer_id())
}

#[tauri::command]
pub async fn set_peer_name(
    name: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    // Update in-memory name
    state.presence_service.set_peer_name(name.clone()).await;

    // Persist to database
    state
        .database
        .set_setting("peer_name", &name)
        .map_err(|e| format!("Failed to save peer name: {}", e))?;

    // Broadcast updated presence to all peers
    let presence_msg = state.presence_service.get_my_presence().await;
    state
        .network
        .broadcast(Message::Presence(presence_msg))
        .await
        .map_err(|e| format!("Failed to broadcast presence: {}", e))?;

    // Emit local event for immediate UI update
    let peers = state.presence_service.get_all_peers().await;
    let _ = app.emit("peers-changed", peers);

    Ok(())
}

#[tauri::command]
pub async fn set_light_color(
    color: String,
    note: Option<String>,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    state.presence_service.set_light_color(color).await;
    state.presence_service.set_note(note).await;

    // Broadcast updated presence to all peers
    let presence_msg = state.presence_service.get_my_presence().await;
    state
        .network
        .broadcast(Message::Presence(presence_msg))
        .await
        .map_err(|e| format!("Failed to broadcast presence: {}", e))?;

    // Emit local event for immediate UI update
    let peers = state.presence_service.get_all_peers().await;
    let _ = app.emit("peers-changed", peers);

    Ok(())
}

#[tauri::command]
pub async fn get_peers(state: State<'_, AppState>) -> Result<Vec<PeerPresence>, String> {
    Ok(state.presence_service.get_all_peers().await)
}

#[tauri::command]
pub async fn get_lights(state: State<'_, AppState>) -> Result<Vec<LightConfig>, String> {
    state
        .config_service
        .get_all_lights()
        .await
        .map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn create_light(
    light: LightConfig,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let config_msg = state
        .config_service
        .upsert_light(light)
        .await
        .map_err(|e| e.to_string())?;

    state
        .network
        .broadcast(Message::Config(config_msg))
        .await
        .map_err(|e| format!("Failed to broadcast config: {}", e))?;

    // Emit local event for immediate UI update
    if let Ok(lights) = state.config_service.get_all_lights().await {
        let _ = app.emit("lights-changed", lights);
    }

    Ok(())
}

#[tauri::command]
pub async fn update_light(
    light: LightConfig,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let config_msg = state
        .config_service
        .upsert_light(light)
        .await
        .map_err(|e| e.to_string())?;

    state
        .network
        .broadcast(Message::Config(config_msg))
        .await
        .map_err(|e| format!("Failed to broadcast config: {}", e))?;

    // Emit local event for immediate UI update
    if let Ok(lights) = state.config_service.get_all_lights().await {
        let _ = app.emit("lights-changed", lights);
    }

    Ok(())
}

#[tauri::command]
pub async fn delete_light(
    id: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let config_msg = state
        .config_service
        .delete_light(id)
        .await
        .map_err(|e| e.to_string())?;

    state
        .network
        .broadcast(Message::Config(config_msg))
        .await
        .map_err(|e| format!("Failed to broadcast config: {}", e))?;

    // Emit local event for immediate UI update
    if let Ok(lights) = state.config_service.get_all_lights().await {
        let _ = app.emit("lights-changed", lights);
    }

    Ok(())
}

#[tauri::command]
pub async fn send_chat_message(
    content: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let chat_msg = state
        .chat_service
        .send_message(content)
        .await
        .map_err(|e| e.to_string())?;

    state
        .network
        .broadcast(Message::Chat(chat_msg.clone()))
        .await
        .map_err(|e| format!("Failed to broadcast chat: {}", e))?;

    // Emit local event for immediate UI update
    let _ = app.emit("chat-message", chat_msg);

    Ok(())
}

#[tauri::command]
pub async fn get_chat_messages(state: State<'_, AppState>) -> Result<Vec<ChatMessage>, String> {
    state
        .chat_service
        .get_all_messages()
        .await
        .map_err(|e| e.to_string())
}

#[tauri::command]
pub async fn edit_chat_message(
    id: String,
    content: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let chat_msg = state
        .chat_service
        .edit_message(id, content)
        .await
        .map_err(|e| e.to_string())?;

    state
        .network
        .broadcast(Message::Chat(chat_msg.clone()))
        .await
        .map_err(|e| format!("Failed to broadcast chat edit: {}", e))?;

    // Emit local event for immediate UI update
    let _ = app.emit("chat-message", chat_msg);

    Ok(())
}

#[tauri::command]
pub async fn delete_chat_message(
    id: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    state
        .chat_service
        .delete_message(id.clone())
        .await
        .map_err(|e| e.to_string())?;

    // Emit local event for immediate UI update - send the ID as a deletion event
    let _ = app.emit("chat-message-deleted", id);

    Ok(())
}

#[tauri::command]
pub async fn send_notification(
    target_peer_id: String,
    notification_type: String,
    message: String,
    priority: Option<String>,
    color: Option<String>,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let notif_type = match notification_type.as_str() {
        "patient-ready" => NotificationType::PatientReady,
        "room-ready" => NotificationType::RoomReady,
        "urgent-assist" => NotificationType::UrgentAssist,
        "general-message" => NotificationType::GeneralMessage,
        _ => return Err(format!("Unknown notification type: {}", notification_type)),
    };

    let notification = Notification {
        notification_type: notif_type,
        message,
        target_peer_id: target_peer_id.clone(),
        sender_peer_id: state.presence_service.get_my_peer_id(),
        timestamp: crate::utils::current_timestamp(),
        priority,
        color,
    };

    state
        .network
        .broadcast(Message::Notification(notification.clone()))
        .await
        .map_err(|e| format!("Failed to broadcast notification: {}", e))?;

    // Persist notification in presence service so it syncs with peer status
    state
        .presence_service
        .set_peer_notification(target_peer_id, notification.clone())
        .await;

    // Emit peers-changed so UI updates immediately with the notification status
    let peers = state.presence_service.get_all_peers().await;
    let _ = app.emit("peers-changed", peers);

    // Emit to local frontend for immediate UI update
    let my_peer_id = state.presence_service.get_my_peer_id();
    
    // Always emit peer-notification-status for card indicators
    let _ = app.emit("peer-notification-status", notification.clone());
    
    // Only show in banner (notification event) if we're the target
    if notification.target_peer_id == my_peer_id {
        let _ = app.emit("notification", notification);
    }

    Ok(())
}

// Legacy command for backwards compatibility - wraps send_notification
#[tauri::command]
pub async fn send_patient_notification(
    target_peer_id: String,
    patient_name: String,
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    send_notification(
        target_peer_id,
        "patient-ready".to_string(),
        patient_name,
        None,
        None,
        app,
        state,
    )
    .await
}
