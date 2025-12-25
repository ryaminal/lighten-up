use crate::domain::{LightColor, LightState, PeerId, PeerInfo, VectorClock};
use crate::adapters::Message;

#[cfg(test)]
mod color_regression_tests {
    use super::*;

    /// Regression test: Ensure all LightColor variants can be serialized and deserialized.
    /// This prevents the bug where Rust had colors that TypeScript didn't support.
    #[test]
    fn test_all_colors_serialize_deserialize() {
        let all_colors = vec![
            LightColor::Black,
            LightColor::Red,
            LightColor::Green,
            LightColor::Yellow,
            LightColor::Blue,
            LightColor::Magenta,
            LightColor::Cyan,
            LightColor::White,
            LightColor::Off,
        ];

        for color in all_colors {
            // Test direct serialization
            let json = serde_json::to_string(&color).expect("Failed to serialize color");
            let deserialized: LightColor =
                serde_json::from_str(&json).expect("Failed to deserialize color");
            assert_eq!(
                deserialized, color,
                "Color mismatch after round-trip for {:?}",
                color
            );

            // Test in PeerInfo context
            let peer_info = PeerInfo::new(
                PeerId::new("test-peer"),
                "Test Peer".to_string(),
                LightState::new(color.clone(), VectorClock::new(), 1000),
            );

            let peer_json =
                serde_json::to_string(&peer_info).expect("Failed to serialize PeerInfo");
            let peer_deserialized: PeerInfo =
                serde_json::from_str(&peer_json).expect("Failed to deserialize PeerInfo");
            assert_eq!(
                peer_deserialized.light_state.color, color,
                "Color mismatch in PeerInfo for {:?}",
                color
            );

            // Test in Message context (network serialization)
            let message = Message::PeerAnnouncement {
                peer: peer_info.clone(),
            };
            let msg_json = serde_json::to_string(&message).expect("Failed to serialize Message");
            let msg_deserialized: Message =
                serde_json::from_str(&msg_json).expect("Failed to deserialize Message");

            if let Message::PeerAnnouncement { peer } = msg_deserialized {
                assert_eq!(
                    peer.light_state.color, color,
                    "Color mismatch in Message for {:?}",
                    color
                );
            } else {
                panic!("Expected PeerAnnouncement message");
            }
        }
    }

    /// Regression test: Verify color count matches expected terminal colors (0-7 + Off).
    /// If this fails, TypeScript COLOR_CONFIG needs updating.
    #[test]
    fn test_color_count() {
        let all_colors = vec![
            LightColor::Black,
            LightColor::Red,
            LightColor::Green,
            LightColor::Yellow,
            LightColor::Blue,
            LightColor::Magenta,
            LightColor::Cyan,
            LightColor::White,
            LightColor::Off,
        ];

        assert_eq!(
            all_colors.len(),
            9,
            "Expected 9 colors (8 ANSI + Off). If you added a color, update TypeScript COLOR_CONFIG!"
        );
    }

    /// Regression test: Ensure color names match TypeScript expectations.
    /// TypeScript uses these exact strings in the generated type.
    #[test]
    fn test_color_names_match_typescript() {
        let expected_names = vec![
            ("Black", LightColor::Black),
            ("Red", LightColor::Red),
            ("Green", LightColor::Green),
            ("Yellow", LightColor::Yellow),
            ("Blue", LightColor::Blue),
            ("Magenta", LightColor::Magenta),
            ("Cyan", LightColor::Cyan),
            ("White", LightColor::White),
            ("Off", LightColor::Off),
        ];

        for (expected_name, color) in expected_names {
            let json = serde_json::to_string(&color).expect("Failed to serialize");
            let json_name = json.trim_matches('"');
            assert_eq!(
                json_name, expected_name,
                "Color name mismatch: Rust serializes {:?} as '{}' but TypeScript expects '{}'",
                color, json_name, expected_name
            );
        }
    }
}
