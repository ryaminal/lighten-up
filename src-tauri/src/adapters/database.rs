use crate::adapters::error::Result;
use crate::domain::{Light, LightConfig, LightId, LightState, PeerId, PeerInfo};
use crate::services::controller_service::ControllerInfo;
use async_trait::async_trait;

/// Database adapter trait for persistent storage
#[async_trait]
pub trait DatabaseAdapter: Send + Sync {
    /// Initialize the database schema
    async fn initialize(&self) -> Result<()>;

    /// Save or update peer information
    async fn save_peer(&self, peer: &PeerInfo) -> Result<()>;

    /// Get peer information by ID
    async fn get_peer(&self, peer_id: &PeerId) -> Result<PeerInfo>;

    /// Get all known peers
    async fn get_all_peers(&self) -> Result<Vec<PeerInfo>>;

    /// Delete a peer by ID
    async fn delete_peer(&self, peer_id: &PeerId) -> Result<()>;

    /// Save our own peer information
    async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()>;

    /// Get our own peer information
    async fn get_my_peer(&self) -> Result<PeerInfo>;

    /// Update the name of our peer
    async fn update_my_name(&self, name: String) -> Result<()>;

    /// Update our light state
    async fn update_my_light_state(&self, state: &LightState) -> Result<()>;

    // Light operations
    /// Save or update a light
    async fn save_light(&self, light: &Light) -> Result<()>;

    /// Get a light by ID
    async fn get_light(&self, light_id: &LightId) -> Result<Light>;

    /// Get all lights
    async fn get_all_lights(&self) -> Result<Vec<Light>>;

    /// Delete a light by ID
    async fn delete_light(&self, light_id: &LightId) -> Result<()>;

    /// Save light configuration
    async fn save_light_config(&self, config: &LightConfig) -> Result<()>;

    /// Get light configuration
    async fn get_light_config(&self) -> Result<LightConfig>;

    /// Save controller information
    async fn save_controller_info(&self, info: Option<ControllerInfo>) -> Result<()>;

    /// Get controller information
    async fn get_controller_info(&self) -> Result<Option<ControllerInfo>>;
}
