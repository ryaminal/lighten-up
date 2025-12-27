use crate::{database::Database, protocol::messages::LightConfig};
use anyhow::Result;
use std::sync::Arc;

/// Applies a LightConfig update if the incoming message is newer or equal.
pub(crate) async fn apply_upsert_with_lww(
    db: &Arc<Database>,
    id: String,
    color: String,
    name: String,
    enabled: bool,
    priority: i32,
    updated_at: u64,
    updated_by: String,
) -> Result<()> {
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)?
        .into_iter()
        .find(|l| l.id == id);

    let should_apply = match existing {
        Some(existing) => updated_at >= existing.updated_at,
        None => true,
    };

    if should_apply {
        let light = LightConfig {
            id,
            color,
            name,
            enabled,
            priority,
            updated_at,
            updated_by,
        };
        crate::database::queries::upsert_light(&conn, &light)?;
    }

    Ok(())
}

/// Deletes a light if the delete timestamp is newer or equal to the current value.
pub(crate) async fn apply_delete_if_newer(
    db: &Arc<Database>,
    id: &str,
    deleted_at: u64,
) -> Result<()> {
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)?
        .into_iter()
        .find(|l| l.id == id);

    let should_delete = match existing {
        Some(existing) => deleted_at >= existing.updated_at,
        None => false,
    };

    if should_delete {
        crate::database::queries::delete_light(&conn, id)?;
    }

    Ok(())
}
