use crate::domain::PeerId;
use tauri::AppHandle;
use tauri_plugin_store::StoreExt;

/// Load or create application configuration
pub fn load_config(app: &AppHandle) -> Result<(PeerId, String, String), String> {
    let store = app.store("store.json").map_err(|e| e.to_string())?;
    let my_peer_id = get_or_create_peer_id(&store)?;
    let my_name = get_hostname()?;
    let passphrase = get_or_create_passphrase(&store)?;
    Ok((my_peer_id, my_name, passphrase))
}

fn get_or_create_peer_id(store: &tauri_plugin_store::Store<tauri::Wry>) -> Result<PeerId, String> {
    // Check for environment variable override first (for testing)
    if let Ok(id) = std::env::var("LIGHTEN_UP_PEER_ID") {
        log::info!("Using peer ID from environment: {}", id);
        return Ok(PeerId::new(&id));
    }

    if let Some(peer_id_str) = store.get("peer_id") {
        let peer_id = peer_id_str.as_str().ok_or("Invalid peer_id format")?;
        log::info!("Loaded existing peer ID: {}", peer_id);
        return Ok(PeerId::new(peer_id));
    }

    let peer_id = PeerId::generate();
    store.set("peer_id", serde_json::json!(peer_id.as_str()));
    store.save().map_err(|e| e.to_string())?;
    log::info!("Generated new peer ID: {}", peer_id.as_str());
    Ok(peer_id)
}

fn get_hostname() -> Result<String, String> {
    // Check for environment variable override first (for testing)
    if let Ok(name) = std::env::var("LIGHTEN_UP_PEER_NAME") {
        log::info!("Using peer name from environment: {}", name);
        return Ok(name);
    }
    
    Ok(tauri_plugin_os::hostname())
}

fn get_or_create_passphrase(
    store: &tauri_plugin_store::Store<tauri::Wry>,
) -> Result<String, String> {
    if let Some(passphrase) = store.get("passphrase") {
        let pass = passphrase.as_str().ok_or("Invalid passphrase")?;
        return Ok(pass.to_string());
    }

    let passphrase = "lighten-up-development".to_string();
    store.set("passphrase", serde_json::json!(passphrase));
    store.save().map_err(|e| e.to_string())?;
    log::warn!("Using development passphrase");
    Ok(passphrase)
}
