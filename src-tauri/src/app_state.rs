use crate::adapters::{DatabaseAdapter, NetworkAdapter};
use crate::services::{LightService, PeerService};
use std::sync::Arc;

/// Application state managed by Tauri
pub struct AppState<D: DatabaseAdapter, N: NetworkAdapter> {
    pub light_service: Arc<LightService<D, N>>,
    pub peer_service: Arc<PeerService<D, N>>,
}

impl<D: DatabaseAdapter, N: NetworkAdapter> AppState<D, N> {
    pub fn new(
        light_service: Arc<LightService<D, N>>,
        peer_service: Arc<PeerService<D, N>>,
    ) -> Self {
        Self {
            light_service,
            peer_service,
        }
    }
}
