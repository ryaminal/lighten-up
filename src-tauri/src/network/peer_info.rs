use crate::domain::PeerId;
use std::net::SocketAddr;

/// Information about a discovered peer
#[derive(Debug, Clone)]
pub struct PeerConnection {
    pub peer_id: PeerId,
    pub addr: SocketAddr,
}

impl PeerConnection {
    pub fn new(peer_id: PeerId, addr: SocketAddr) -> Self {
        Self { peer_id, addr }
    }
}
