use crate::adapters::{AdapterError, Result};
use crate::domain::{LightColor, LightState, PeerId, PeerInfo, VectorClock};
use rusqlite::Row;

/// Serialize VectorClock to JSON string
pub fn serialize_vector_clock(clock: &VectorClock) -> Result<String> {
    serde_json::to_string(clock).map_err(|e| {
        AdapterError::Serialization(format!("Failed to serialize vector clock: {}", e))
    })
}

/// Deserialize VectorClock from JSON string
pub fn deserialize_vector_clock(json: &str) -> Result<VectorClock> {
    serde_json::from_str(json).map_err(|e| {
        AdapterError::Serialization(format!("Failed to deserialize vector clock: {}", e))
    })
}

/// Serialize LightColor to string
pub fn serialize_light_color(color: &LightColor) -> String {
    format!("{:?}", color)
}

/// Deserialize LightColor from string
pub fn deserialize_light_color(s: &str) -> Result<LightColor> {
    match s {
        "Red" => Ok(LightColor::Red),
        "Green" => Ok(LightColor::Green),
        "Blue" => Ok(LightColor::Blue),
        "Yellow" => Ok(LightColor::Yellow),
        "Purple" => Ok(LightColor::Purple),
        "Orange" => Ok(LightColor::Orange),
        _ => Err(AdapterError::InvalidData(format!(
            "Unknown light color: {}",
            s
        ))),
    }
}

/// Convert database row to PeerInfo
pub fn row_to_peer_info(row: &Row) -> rusqlite::Result<PeerInfo> {
    let peer_id = PeerId::new(row.get::<_, String>(0)?);
    let name: String = row.get(1)?;
    let color_str: String = row.get(2)?;
    let clock_json: String = row.get(3)?;
    let timestamp_i64: i64 = row.get(4)?;
    let timestamp = timestamp_i64 as u64;

    let color = deserialize_light_color(&color_str)
        .map_err(|e| rusqlite::Error::ToSqlConversionFailure(Box::new(e)))?;
    let vector_clock = deserialize_vector_clock(&clock_json)
        .map_err(|e| rusqlite::Error::ToSqlConversionFailure(Box::new(e)))?;

    let light_state = LightState::new(color, vector_clock, timestamp);

    Ok(PeerInfo::new(peer_id, name, light_state))
}
