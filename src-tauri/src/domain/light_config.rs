use crate::domain::LightColor;
use serde::{Deserialize, Serialize};
use ts_rs::TS;

/// Unique identifier for a light definition
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize, TS)]
#[ts(export, export_to = "../../src/lib/generated/")]
pub struct LightDefinitionId(String);

impl LightDefinitionId {
    pub fn generate() -> Self {
        Self(uuid::Uuid::new_v4().to_string())
    }

    pub fn as_str(&self) -> &str {
        &self.0
    }
}

impl From<String> for LightDefinitionId {
    fn from(s: String) -> Self {
        Self(s)
    }
}

/// Defines a configurable light with its meaning and display properties
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, TS)]
#[ts(export, export_to = "../../src/lib/generated/")]
pub struct LightDefinition {
    pub id: LightDefinitionId,
    pub color: LightColor,
    pub name: String,
    pub meaning: String,
    pub enabled: bool,
    pub order: u32,
    pub updated_at: u64,
    pub updated_by: String,
    #[serde(default)]
    pub deleted_at: Option<u64>,
}

impl LightDefinition {
    pub fn new(
        color: LightColor,
        name: impl Into<String>,
        meaning: impl Into<String>,
        order: u32,
        updated_by: impl Into<String>,
    ) -> Self {
        Self {
            id: LightDefinitionId::generate(),
            color,
            name: name.into(),
            meaning: meaning.into(),
            enabled: true,
            order,
            updated_at: crate::domain::current_timestamp_secs(),
            updated_by: updated_by.into(),
            deleted_at: None,
        }
    }

    pub fn is_deleted(&self) -> bool {
        self.deleted_at.is_some()
    }

    pub fn should_replace(&self, other: &Self) -> bool {
        if self.updated_at != other.updated_at {
            return other.updated_at > self.updated_at;
        }
        other.updated_by > self.updated_by
    }
}

/// Complete light configuration for the system
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, TS)]
#[ts(export, export_to = "../../src/lib/generated/")]
pub struct LightConfig {
    pub definitions: Vec<LightDefinition>,
    pub version: u64,
}

impl LightConfig {
    pub fn new() -> Self {
        Self {
            definitions: Vec::new(),
            version: 0,
        }
    }

    pub fn default_config(peer_id: impl Into<String>) -> Self {
        let peer_id = peer_id.into();
        let defaults = vec![
            LightDefinition::new(
                LightColor::Green,
                "Ready / Clear",
                "Room Available",
                0,
                &peer_id,
            ),
            LightDefinition::new(LightColor::Red, "Assistance Needed", "Urgent", 1, &peer_id),
            LightDefinition::new(LightColor::Blue, "Assistance", "Non-Urgent", 2, &peer_id),
            LightDefinition::new(
                LightColor::Magenta,
                "Admin / Vitals",
                "Process",
                3,
                &peer_id,
            ),
            LightDefinition::new(LightColor::Yellow, "Provider In", "Occupied", 4, &peer_id),
            LightDefinition::new(LightColor::White, "Custom", "Other", 5, &peer_id),
        ];

        Self {
            definitions: defaults,
            version: 1,
        }
    }

    pub fn merge(&mut self, other: &Self) {
        // If the other config has a significantly higher version, it's from an established
        // network and should take precedence over our default config
        let other_is_established = other.version > self.version;

        // Merge definitions from other config
        for other_def in &other.definitions {
            // First, try to find by ID
            let existing_by_id_pos = self.definitions.iter().position(|d| d.id == other_def.id);

            if let Some(pos) = existing_by_id_pos {
                // Found by ID - update if newer
                if self.definitions[pos].should_replace(other_def) {
                    self.definitions[pos] = other_def.clone();
                }
            } else {
                // Not found by ID - check if we have the same color with different ID
                let existing_by_color_pos = self
                    .definitions
                    .iter()
                    .position(|d| d.color == other_def.color);

                if let Some(pos) = existing_by_color_pos {
                    // Found same color with different ID
                    // If other config is from an established network (higher version),
                    // prefer it over our local definition
                    let should_use_other = if other_is_established {
                        // Established network wins over default config
                        true
                    } else {
                        // Otherwise use timestamp comparison
                        self.definitions[pos].should_replace(other_def)
                    };

                    if should_use_other {
                        self.definitions[pos] = other_def.clone();
                    }
                } else {
                    // Completely new definition - add it
                    self.definitions.push(other_def.clone());
                }
            }
        }

        self.version = self.version.max(other.version);
    }

    pub fn get_by_color(&self, color: &LightColor) -> Option<&LightDefinition> {
        self.definitions
            .iter()
            .find(|def| !def.is_deleted() && def.enabled && def.color == *color)
    }

    pub fn enabled_definitions(&self) -> Vec<&LightDefinition> {
        let mut defs: Vec<_> = self
            .definitions
            .iter()
            .filter(|def| !def.is_deleted() && def.enabled)
            .collect();
        defs.sort_by_key(|def| def.order);
        defs
    }

    pub fn active_definitions(&self) -> Vec<&LightDefinition> {
        self.definitions
            .iter()
            .filter(|def| !def.is_deleted())
            .collect()
    }
}

impl Default for LightConfig {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_light_definition_creation() {
        let def = LightDefinition::new(LightColor::Green, "Ready", "Room Available", 0, "peer1");

        assert_eq!(def.color, LightColor::Green);
        assert_eq!(def.name, "Ready");
        assert_eq!(def.meaning, "Room Available");
        assert!(def.enabled);
        assert_eq!(def.order, 0);
    }

    #[test]
    fn test_should_replace_by_timestamp() {
        let def1 = LightDefinition::new(LightColor::Green, "Ready", "Room Available", 0, "peer1");
        let mut def2 = def1.clone();

        def2.updated_at = def1.updated_at + 1;
        assert!(def1.should_replace(&def2));
        assert!(!def2.should_replace(&def1));
    }

    #[test]
    fn test_should_replace_by_peer_id() {
        let def1 = LightDefinition::new(LightColor::Green, "Ready", "Room Available", 0, "peer_a");
        let mut def2 = def1.clone();

        def2.updated_by = "peer_b".to_string();
        assert!(def1.should_replace(&def2));
        assert!(!def2.should_replace(&def1));
    }

    #[test]
    fn test_default_config_creation() {
        let config = LightConfig::default_config("test-peer");

        assert_eq!(config.definitions.len(), 6);
        assert_eq!(config.version, 1);
        assert!(config.definitions.iter().all(|d| d.enabled));
    }

    #[test]
    fn test_config_merge() {
        let mut config1 = LightConfig::default_config("peer1");
        let mut config2 = config1.clone();

        config2.definitions[0].name = "Updated Name".to_string();
        config2.definitions[0].updated_at += 1;
        config2.version = 2;

        config1.merge(&config2);

        assert_eq!(config1.definitions[0].name, "Updated Name");
        assert_eq!(config1.version, 2);
    }

    #[test]
    fn test_get_by_color() {
        let config = LightConfig::default_config("test-peer");

        let green_def = config.get_by_color(&LightColor::Green);
        assert!(green_def.is_some());
        assert_eq!(green_def.expect("checked").name, "Ready / Clear");

        let black_def = config.get_by_color(&LightColor::Black);
        assert!(black_def.is_none());
    }

    #[test]
    fn test_enabled_definitions_sorted() {
        let config = LightConfig::default_config("test-peer");
        let enabled = config.enabled_definitions();

        assert_eq!(enabled.len(), 6);
        for i in 1..enabled.len() {
            assert!(enabled[i - 1].order <= enabled[i].order);
        }
    }

    #[test]
    fn export_typescript_types() {
        LightDefinitionId::export().expect("export ID type");
        LightDefinition::export().expect("export definition type");
        LightConfig::export().expect("export config type");
    }
}
