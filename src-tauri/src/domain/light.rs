use crate::domain::{PeerId, current_timestamp_secs};
use serde::{Deserialize, Serialize};

/// Unique identifier for a light
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct LightId(String);

impl LightId {
    pub fn new(id: impl Into<String>) -> Self {
        Self(id.into())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

/// Status of a light
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LightStatus {
    Off,
    On,
}

/// Priority level for light escalation
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum LightPriority {
    Normal,
    High,
    Urgent,
}

/// A light represents an actionable alert/task in the system
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Light {
    pub id: LightId,
    pub name: String,
    pub status: LightStatus,
    pub priority: LightPriority,
    pub activated_at: Option<u64>,
    pub activated_by: Option<PeerId>,
    pub comments: Vec<LightComment>,
}

/// A comment attached to a light
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct LightComment {
    pub text: String,
    pub author: PeerId,
    pub timestamp: u64,
}

impl Light {
    pub fn new(id: LightId, name: String) -> Self {
        Self {
            id,
            name,
            status: LightStatus::Off,
            priority: LightPriority::Normal,
            activated_at: None,
            activated_by: None,
            comments: Vec::new(),
        }
    }

    pub fn activate(&mut self, by: PeerId) {
        self.status = LightStatus::On;
        self.activated_at = Some(current_timestamp_secs());
        self.activated_by = Some(by);
    }

    pub fn deactivate(&mut self) {
        self.status = LightStatus::Off;
        self.activated_at = None;
        self.activated_by = None;
    }

    pub fn add_comment(&mut self, text: String, author: PeerId) {
        self.comments.push(LightComment {
            text,
            author,
            timestamp: current_timestamp_secs(),
        });
    }

    pub fn set_priority(&mut self, priority: LightPriority) {
        self.priority = priority;
    }

    pub fn is_active(&self) -> bool {
        matches!(self.status, LightStatus::On)
    }

    pub fn elapsed_seconds(&self) -> Option<u64> {
        self.activated_at
            .map(|t| current_timestamp_secs().saturating_sub(t))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_light_activate() {
        let mut light = Light::new(LightId::new("test"), "Test Light".to_string());
        let peer_id = PeerId::new("peer1");

        assert!(!light.is_active());
        assert!(light.activated_at.is_none());

        light.activate(peer_id.clone());

        assert!(light.is_active());
        assert!(light.activated_at.is_some());
        assert_eq!(light.activated_by, Some(peer_id));
    }

    #[test]
    fn test_light_deactivate() {
        let mut light = Light::new(LightId::new("test"), "Test Light".to_string());
        let peer_id = PeerId::new("peer1");

        light.activate(peer_id);
        assert!(light.is_active());

        light.deactivate();
        assert!(!light.is_active());
        assert!(light.activated_at.is_none());
        assert!(light.activated_by.is_none());
    }

    #[test]
    fn test_light_add_comment() {
        let mut light = Light::new(LightId::new("test"), "Test Light".to_string());
        let peer_id = PeerId::new("peer1");

        assert_eq!(light.comments.len(), 0);

        light.add_comment("Test comment".to_string(), peer_id.clone());

        assert_eq!(light.comments.len(), 1);
        assert_eq!(light.comments[0].text, "Test comment");
        assert_eq!(light.comments[0].author, peer_id);
    }

    #[test]
    fn test_light_priority() {
        let mut light = Light::new(LightId::new("test"), "Test Light".to_string());

        assert_eq!(light.priority, LightPriority::Normal);

        light.set_priority(LightPriority::Urgent);
        assert_eq!(light.priority, LightPriority::Urgent);
    }
}
