use serde::{Deserialize, Serialize};
use ts_rs::TS;

/// Represents a light color state
/// Covers the 8 standard terminal/ANSI colors (0-7)
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize, Default, TS)]
#[ts(export, export_to = "../../src/lib/generated/")]
pub enum LightColor {
    Black,
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    #[default]
    Off,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn export_typescript_types() {
        // This test ensures TypeScript types are generated
        LightColor::export().expect("Failed to export TypeScript types");
    }
}
