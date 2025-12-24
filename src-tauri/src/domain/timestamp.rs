/// Utility functions for timestamp handling
use std::time::{SystemTime, UNIX_EPOCH};

/// Get current timestamp in seconds since UNIX epoch
///
/// This function uses `expect` rather than `unwrap` because:
/// - SystemTime::now() can only fail if system clock is before 1970
/// - This is an unrecoverable system configuration error
/// - The error message helps diagnose the issue
pub fn current_timestamp_secs() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("System clock is set before UNIX epoch (1970)")
        .as_secs()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_current_timestamp_secs() {
        let ts = current_timestamp_secs();
        // Timestamp should be reasonable (after 2020)
        assert!(ts > 1_600_000_000);
    }
}
