import pytest

from relay.database import Database


@pytest.fixture
def db():
    database = Database(db_path=":memory:")
    yield database
    database.close()


class TestInit:
    def test_creates_tables(self, db):
        rows = db._conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
        ).fetchall()
        names = [r["name"] for r in rows]
        assert "deleted_sessions" in names
        assert "sessions" in names


class TestSessionCRUD:
    def test_insert_and_load(self, db):
        db.insert_session("s1", "c1", "a1", "Session 1", "d1", 1000.0)
        rows = db.load_all_sessions()
        assert len(rows) == 1
        assert rows[0]["session_id"] == "s1"
        assert rows[0]["client_id"] == "c1"
        assert rows[0]["agent_id"] == "a1"
        assert rows[0]["name"] == "Session 1"
        assert rows[0]["daemon_id"] == "d1"
        assert rows[0]["created_at"] == 1000.0
        assert rows[0]["cwd"] == ""

    def test_insert_with_cwd(self, db):
        db.insert_session("s1", "c1", "a1", "S1", "d1", 1000.0, cwd="/tmp")
        rows = db.load_all_sessions()
        assert rows[0]["cwd"] == "/tmp"

    def test_insert_replace_preserves_cwd(self, db):
        db.insert_session("s1", "c1", "a1", "Old", "d1", 1000.0, cwd="/tmp")
        db.insert_session("s1", "c2", "a2", "New", "d2", 2000.0, cwd="/home")
        rows = db.load_all_sessions()
        assert len(rows) == 1
        assert rows[0]["name"] == "New"
        assert rows[0]["cwd"] == "/home"

    def test_update_name(self, db):
        db.insert_session("s1", "c1", "a1", "Old", "d1", 1000.0)
        db.update_name("s1", "Updated")
        rows = db.load_all_sessions()
        assert rows[0]["name"] == "Updated"

    def test_delete_session(self, db):
        db.insert_session("s1", "c1", "a1", "S1", "d1", 1000.0)
        db.delete_session("s1")
        assert db.load_all_sessions() == []

    def test_delete_client_sessions(self, db):
        db.insert_session("s1", "c1", "a1", "S1", "d1", 1000.0)
        db.insert_session("s2", "c1", "a2", "S2", "d2", 2000.0)
        db.insert_session("s3", "c2", "a1", "S3", "d1", 3000.0)
        db.delete_client_sessions("c1")
        rows = db.load_all_sessions()
        assert len(rows) == 1
        assert rows[0]["session_id"] == "s3"

    def test_load_empty(self, db):
        assert db.load_all_sessions() == []


class TestDeletedSessions:
    def test_mark_deleted(self, db):
        db.mark_deleted("s1", 1000.0)
        assert db.is_deleted("s1") is True

    def test_is_deleted_false(self, db):
        assert db.is_deleted("unknown") is False

    def test_load_deleted(self, db):
        db.mark_deleted("s1", 1000.0)
        db.mark_deleted("s2", 2000.0)
        deleted = db.load_deleted_sessions()
        assert deleted == {"s1", "s2"}

    def test_load_deleted_empty(self, db):
        assert db.load_deleted_sessions() == set()

    def test_mark_deleted_uses_default_timestamp(self, db):
        db.mark_deleted("s1")
        rows = db._conn.execute(
            "SELECT * FROM deleted_sessions WHERE session_id = ?", ("s1",)
        ).fetchall()
        assert len(rows) == 1
        assert rows[0]["deleted_at"] is not None


class TestMigration:
    def test_migration_idempotent(self, db):
        db._migrate_add_agent_id()
        db._migrate_add_agent_id()
        db.insert_session("s1", "c1", "a1", "S1", "d1", 1000.0)
        assert len(db.load_all_sessions()) == 1

    def test_migrate_add_cwd_idempotent(self, db):
        db._migrate_add_cwd()
        db._migrate_add_cwd()
        db.insert_session("s1", "c1", "a1", "S1", "d1", 1000.0, cwd="/tmp")
        rows = db.load_all_sessions()
        assert rows[0]["cwd"] == "/tmp"
