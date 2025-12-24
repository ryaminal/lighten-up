use crate::adapters::{DatabaseAdapter, Message, NetworkAdapter, Result};
use crate::domain::{Event, LightColor, LightState, PeerId, PeerInfo, VectorClock};
use crate::services::state::ServiceState;
use std::sync::Arc;
use tokio::sync::{RwLock, broadcast};

/// Service for managing light state and synchronization
pub struct LightService<D: DatabaseAdapter, N: NetworkAdapter> {
    my_peer_id: PeerId,
    database: Arc<D>,
    network: Arc<N>,
    state: Arc<RwLock<ServiceState>>,
    event_tx: broadcast::Sender<Event>,
}

impl<D: DatabaseAdapter, N: NetworkAdapter> LightService<D, N> {
    /// Create a new light service
    pub async fn new(
        my_peer_id: PeerId,
        my_name: String,
        database: Arc<D>,
        network: Arc<N>,
        event_tx: broadcast::Sender<Event>,
    ) -> Result<Self> {
        let my_peer = Self::load_or_create_peer(&my_peer_id, &my_name, &database).await?;
        let state = Arc::new(RwLock::new(ServiceState::new(my_peer.light_state)));

        Ok(Self {
            my_peer_id,
            database,
            network,
            state,
            event_tx,
        })
    }

    async fn load_or_create_peer(
        peer_id: &PeerId,
        name: &str,
        database: &Arc<D>,
    ) -> Result<PeerInfo> {
        match database.get_my_peer().await {
            Ok(peer) => Ok(peer),
            Err(_) => {
                let initial_state = LightState::new(LightColor::Off, VectorClock::new(), 0);
                let peer = PeerInfo::new(peer_id.clone(), name.to_string(), initial_state);
                database.save_my_peer(&peer).await?;
                Ok(peer)
            }
        }
    }

    /// Subscribe to state change events
    pub fn subscribe(&self) -> broadcast::Receiver<Event> {
        self.event_tx.subscribe()
    }

    /// Get current light state
    pub async fn get_my_state(&self) -> LightState {
        self.state.read().await.my_state.clone()
    }

    /// Get full peer info including name
    pub async fn get_my_peer_info(&self) -> Result<PeerInfo> {
        self.database.get_my_peer().await
    }

    /// Set light color and broadcast to peers
    pub async fn set_light_color(&self, color: LightColor) -> Result<()> {
        let timestamp = current_timestamp();
        let new_state = self.update_and_persist(color, timestamp).await?;

        let message = Message::StateUpdate {
            peer_id: self.my_peer_id.clone(),
            state: new_state,
        };

        let result = self.network.broadcast(message).await;
        if let Err(e) = &result {
            log::warn!("Failed to broadcast: {:?}", e);
        }
        result
    }

    async fn update_and_persist(&self, color: LightColor, timestamp: u64) -> Result<LightState> {
        let mut state_guard = self.state.write().await;
        let new_state = state_guard.update(color, timestamp, &self.my_peer_id);

        let my_name = self.database.get_my_peer().await?.name;
        let peer_info = PeerInfo::new(self.my_peer_id.clone(), my_name, new_state.clone());
        self.database.save_my_peer(&peer_info).await?;

        let send_result = self.event_tx.send(Event::MyStateChanged {
            state: new_state.clone(),
        });

        if send_result.is_err() {
            log::warn!("No event listeners");
        }

        Ok(new_state)
    }
}

fn current_timestamp() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs()
}
