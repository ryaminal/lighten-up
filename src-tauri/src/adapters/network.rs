// Re‑export the NetworkAdapter trait defined in the domain layer.
// No additional imports are required here.
// Re‑export the domain‑level port so external crates can import it via
// `crate::adapters::network::NetworkAdapter` without breaking the clean‑
// architecture contract.
pub use crate::domain::NetworkAdapter;
