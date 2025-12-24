use crate::adapters::{DatabaseAdapter, Result};
use crate::database::sqlite::SqliteDatabase;
use crate::domain::{LightState, PeerId, PeerInfo};
use async_trait::async_trait;

#[async_trait]
impl DatabaseAdapter for SqliteDatabase {
    async fn initialize(&self) -> Result<()> {
        SqliteDatabase::initialize(self).await
    }

    async fn save_peer(&self, peer: &PeerInfo) -> Result<()> {
        SqliteDatabase::save_peer(self, peer).await
    }

    async fn get_peer(&self, peer_id: &PeerId) -> Result<PeerInfo> {
        SqliteDatabase::get_peer(self, peer_id).await
    }

    async fn get_all_peers(&self) -> Result<Vec<PeerInfo>> {
        SqliteDatabase::get_all_peers(self).await
    }

    async fn delete_peer(&self, peer_id: &PeerId) -> Result<()> {
        SqliteDatabase::delete_peer(self, peer_id).await
    }

    async fn save_my_peer(&self, peer: &PeerInfo) -> Result<()> {
        SqliteDatabase::save_my_peer(self, peer).await
    }

    async fn get_my_peer(&self) -> Result<PeerInfo> {
        SqliteDatabase::get_my_peer(self).await
    }

    async fn update_my_name(&self, name: String) -> Result<()> {
        SqliteDatabase::update_my_name(self, name).await
    }

    async fn update_my_light_state(&self, state: &LightState) -> Result<()> {
        SqliteDatabase::update_my_light_state(self, state).await
    }
}
