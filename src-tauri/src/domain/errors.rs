//! Application‑wide error type.
//!
//! The project mixes `anyhow::Error` in lower layers (e.g., database).
//! To satisfy the AGENTS rule of using a **single** error handling style
//! in the application layer, we introduce a typed error enum and expose a
//! `Result<T>` alias.

use thiserror::Error;

/// Top‑level error used by services and the application layer.
#[derive(Debug, Error)]
pub enum AppError {
    #[error("Message not found")]
    NotFound,
    #[error("Permission denied")]
    PermissionDenied,
    /// Wrap any lower‑level error (e.g., from `anyhow`).
    #[error("{0}")]
    Other(#[from] anyhow::Error),
}

/// Convenience alias mirroring `std::result::Result`.
pub type Result<T> = std::result::Result<T, AppError>;
