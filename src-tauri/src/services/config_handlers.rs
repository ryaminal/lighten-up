use crate::domain::{AppError, DomainResult as Result};
use crate::{database::Database, protocol::messages::LightConfig};
use log::info;
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
    info!("Applying upsert for light id={}", id);
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)
        .map_err(|e| AppError::Other(e.into()))?
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
        crate::database::queries::upsert_light(&conn, &light)
            .map_err(|e| AppError::Other(e.into()))?;
    }

    Ok(())
}

/// Deletes a light if the delete timestamp is newer or equal to the current value.
pub(crate) async fn apply_delete_if_newer(
    db: &Arc<Database>,
    id: &str,
    deleted_at: u64,
) -> Result<()> {
    info!("Applying delete check for light id={}", id);
    let conn = db.connection();
    let existing = crate::database::queries::get_all_lights(&conn)
        .map_err(|e| AppError::Other(e.into()))?
        .into_iter()
        .find(|l| l.id == id);

    let should_delete = match existing {
        Some(existing) => deleted_at >= existing.updated_at,
        None => false,
    };

    if should_delete {
        crate::database::queries::delete_light(&conn, id).map_err(|e| AppError::Other(e.into()))?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::database::Database;
    use tempfile::TempDir;

    fn setup_test_db() -> Arc<Database> {
        let temp_dir = TempDir::new().expect("Failed to create temp dir");
        let db_path = temp_dir.path().join("test.db");
        let db = Database::new(db_path).expect("Failed to create database");
        std::mem::forget(temp_dir);
        Arc::new(db)
    }

    #[tokio::test]
    async fn apply_upsert_creates_new_light() {
        let db = setup_test_db();

        let result = apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].id, "light-1");
        assert_eq!(lights[0].color, "red");
        assert_eq!(lights[0].name, "Room 1");
        assert_eq!(lights[0].enabled, true);
        assert_eq!(lights[0].priority, 1);
        assert_eq!(lights[0].updated_at, 1000);
        assert_eq!(lights[0].updated_by, "peer-1");
    }

    #[tokio::test]
    async fn apply_upsert_updates_existing_light_with_newer_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "blue".to_string(),
            "Room 1 Updated".to_string(),
            false,
            2,
            2000,
            "peer-2".to_string(),
        )
        .await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "blue");
        assert_eq!(lights[0].name, "Room 1 Updated");
        assert_eq!(lights[0].enabled, false);
        assert_eq!(lights[0].priority, 2);
        assert_eq!(lights[0].updated_at, 2000);
        assert_eq!(lights[0].updated_by, "peer-2");
    }

    #[tokio::test]
    async fn apply_upsert_updates_with_equal_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "green".to_string(),
            "Room 1 Equal".to_string(),
            false,
            3,
            1000,
            "peer-2".to_string(),
        )
        .await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "green");
        assert_eq!(lights[0].updated_at, 1000);
    }

    #[tokio::test]
    async fn apply_upsert_ignores_older_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            2000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "blue".to_string(),
            "Room 1 Old".to_string(),
            false,
            2,
            1000,
            "peer-2".to_string(),
        )
        .await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "red");
        assert_eq!(lights[0].name, "Room 1");
        assert_eq!(lights[0].enabled, true);
        assert_eq!(lights[0].priority, 1);
        assert_eq!(lights[0].updated_at, 2000);
        assert_eq!(lights[0].updated_by, "peer-1");
    }

    #[tokio::test]
    async fn apply_delete_removes_light_with_newer_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_delete_if_newer(&db, "light-1", 2000).await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 0);
    }

    #[tokio::test]
    async fn apply_delete_removes_light_with_equal_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_delete_if_newer(&db, "light-1", 1000).await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 0);
    }

    #[tokio::test]
    async fn apply_delete_ignores_older_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            2000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        let result = apply_delete_if_newer(&db, "light-1", 1000).await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].id, "light-1");
    }

    #[tokio::test]
    async fn apply_delete_ignores_nonexistent_light() {
        let db = setup_test_db();

        let result = apply_delete_if_newer(&db, "nonexistent", 1000).await;

        assert!(result.is_ok());
        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 0);
    }

    #[tokio::test]
    async fn concurrent_updates_last_write_wins() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Original".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "blue".to_string(),
            "Update A".to_string(),
            true,
            1,
            1500,
            "peer-2".to_string(),
        )
        .await
        .unwrap();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "green".to_string(),
            "Update B".to_string(),
            true,
            1,
            1200,
            "peer-3".to_string(),
        )
        .await
        .unwrap();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "yellow".to_string(),
            "Update C".to_string(),
            true,
            1,
            2000,
            "peer-4".to_string(),
        )
        .await
        .unwrap();

        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "yellow");
        assert_eq!(lights[0].name, "Update C");
        assert_eq!(lights[0].updated_at, 2000);
        assert_eq!(lights[0].updated_by, "peer-4");
    }

    #[tokio::test]
    async fn delete_vs_update_older_update_resurrects_after_delete() {
        // NOTE: This test documents a known limitation of the current CRDT implementation.
        // Once a light is deleted, there's no tombstone to track the deletion timestamp.
        // This means an update with an older timestamp can resurrect a deleted light.
        // This is acceptable for the current use case but could be improved with tombstones.
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        apply_delete_if_newer(&db, "light-1", 2000).await.unwrap();

        // This update has timestamp 1500 (older than delete at 2000)
        // but it will still recreate the light because there's no tombstone
        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "blue".to_string(),
            "Room 1 Revival".to_string(),
            true,
            1,
            1500,
            "peer-2".to_string(),
        )
        .await
        .unwrap();

        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "blue");
        assert_eq!(lights[0].updated_at, 1500);
    }

    #[tokio::test]
    async fn delete_vs_update_update_wins_with_newer_timestamp() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        apply_delete_if_newer(&db, "light-1", 1500).await.unwrap();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "blue".to_string(),
            "Room 1 Revival".to_string(),
            true,
            1,
            2000,
            "peer-2".to_string(),
        )
        .await
        .unwrap();

        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 1);
        assert_eq!(lights[0].color, "blue");
        assert_eq!(lights[0].name, "Room 1 Revival");
        assert_eq!(lights[0].updated_at, 2000);
    }

    #[tokio::test]
    async fn multiple_lights_independent_timestamps() {
        let db = setup_test_db();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "red".to_string(),
            "Room 1".to_string(),
            true,
            1,
            1000,
            "peer-1".to_string(),
        )
        .await
        .unwrap();

        apply_upsert_with_lww(
            &db,
            "light-2".to_string(),
            "blue".to_string(),
            "Room 2".to_string(),
            true,
            2,
            2000,
            "peer-2".to_string(),
        )
        .await
        .unwrap();

        apply_upsert_with_lww(
            &db,
            "light-1".to_string(),
            "green".to_string(),
            "Room 1 Update".to_string(),
            true,
            1,
            500,
            "peer-3".to_string(),
        )
        .await
        .unwrap();

        let lights = crate::database::queries::get_all_lights(&db.connection()).unwrap();
        assert_eq!(lights.len(), 2);

        let light1 = lights.iter().find(|l| l.id == "light-1").unwrap();
        assert_eq!(light1.color, "red");
        assert_eq!(light1.updated_at, 1000);

        let light2 = lights.iter().find(|l| l.id == "light-2").unwrap();
        assert_eq!(light2.color, "blue");
        assert_eq!(light2.updated_at, 2000);
    }
}
