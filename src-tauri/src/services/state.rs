use crate::domain::{LightColor, LightState, PeerId, VectorClock};

/// Service state management
pub struct ServiceState {
    pub my_state: LightState,
    pub vector_clock: VectorClock,
}

impl ServiceState {
    pub fn new(state: LightState) -> Self {
        Self {
            vector_clock: state.vector_clock.clone(),
            my_state: state,
        }
    }

    pub fn update(&mut self, color: LightColor, timestamp: u64, peer_id: &PeerId) -> LightState {
        self.vector_clock.increment(peer_id);
        let new_state = LightState::new(color, self.vector_clock.clone(), timestamp);
        self.my_state = new_state.clone();
        new_state
    }
}
