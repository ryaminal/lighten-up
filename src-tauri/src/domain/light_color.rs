use serde::{Deserialize, Serialize};

/// Represents a light color state
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum LightColor {
    Red,
    Green,
    Blue,
    Yellow,
    Orange,
    Purple,
    White,
    #[default]
    Off,
}
