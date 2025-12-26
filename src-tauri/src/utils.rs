use std::time::{SystemTime, UNIX_EPOCH};

pub fn current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards")
        .as_secs()
}

pub fn generate_peer_id(name: &str) -> String {
    let short_uuid = &uuid::Uuid::new_v4().to_string()[..8];
    format!("{}-{}", name, short_uuid)
}
