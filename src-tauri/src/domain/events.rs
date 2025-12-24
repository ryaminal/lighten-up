use crate::domain::{light_state::LightState, peer_id::PeerId};
use serde::{Deserialize, Serialize};

/// Represents information about a peer
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct PeerInfo {
    pub id: PeerId,
    pub name: String,
    pub light_state: LightState,
}

impl PeerInfo {
    pub fn new(id: PeerId, name: String, light_state: LightState) -> Self {
        Self {
            id,
            name,
            light_state,
        }
    }
}

/// Events that can occur in the system
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum Event {
    PeerDiscovered { peer: PeerInfo },
    PeerStateChanged { peer_id: PeerId, state: LightState },
    PeerLeft { peer_id: PeerId },
    MyStateChanged { state: LightState },
}
