import os
import sqlite3
import time
from pathlib import Path

DB_PATH = os.environ.get("ACP_RELAY_DB", "runmote_relay.db")


class Database:
    def __init__(self, db_path: str = DB_PATH):
        Path(db_path).parent.mkdir(parents=True, exist_ok=True)
        self._conn = sqlite3.connect(db_path, check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self._init_db()

    def _init_db(self):
        self._conn.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                session_id TEXT PRIMARY KEY,
                client_id TEXT NOT NULL DEFAULT '',
                agent_id TEXT NOT NULL DEFAULT '',
                name TEXT NOT NULL DEFAULT '',
                daemon_id TEXT NOT NULL DEFAULT '',
                created_at REAL NOT NULL,
                cwd TEXT NOT NULL DEFAULT ''
            )
        """)
        self._conn.execute("""
            CREATE TABLE IF NOT EXISTS deleted_sessions (
                session_id TEXT PRIMARY KEY,
                deleted_at REAL NOT NULL
            )
        """)
        self._conn.commit()
        self._migrate_add_agent_id()
        self._migrate_add_cwd()

    def load_all_sessions(self) -> list[dict]:
        rows = self._conn.execute("SELECT * FROM sessions").fetchall()
        return [dict(row) for row in rows]

    def insert_session(
        self,
        session_id: str,
        client_id: str,
        agent_id: str,
        name: str,
        daemon_id: str,
        created_at: float,
        cwd: str = "",
    ):
        self._conn.execute(
            "INSERT OR REPLACE INTO sessions VALUES (?, ?, ?, ?, ?, ?, ?)",
            (session_id, client_id, agent_id, name, daemon_id, created_at, cwd),
        )
        self._conn.commit()

    def update_name(self, session_id: str, name: str):
        self._conn.execute(
            "UPDATE sessions SET name = ? WHERE session_id = ?", (name, session_id)
        )
        self._conn.commit()

    def delete_session(self, session_id: str):
        self._conn.execute("DELETE FROM sessions WHERE session_id = ?", (session_id,))
        self._conn.commit()

    def delete_client_sessions(self, client_id: str):
        self._conn.execute("DELETE FROM sessions WHERE client_id = ?", (client_id,))
        self._conn.commit()

    def mark_deleted(self, session_id: str, deleted_at: float | None = None):
        if deleted_at is None:
            deleted_at = time.time()
        self._conn.execute(
            "INSERT OR REPLACE INTO deleted_sessions VALUES (?, ?)",
            (session_id, deleted_at),
        )
        self._conn.commit()

    def load_deleted_sessions(self) -> set[str]:
        rows = self._conn.execute("SELECT session_id FROM deleted_sessions").fetchall()
        return {row["session_id"] for row in rows}

    def is_deleted(self, session_id: str) -> bool:
        row = self._conn.execute(
            "SELECT 1 FROM deleted_sessions WHERE session_id = ?", (session_id,)
        ).fetchone()
        return row is not None

    def _migrate_add_agent_id(self):
        """Add agent_id column to existing sessions table (pre-v2 schema)."""
        try:
            self._conn.execute("ALTER TABLE sessions ADD COLUMN agent_id TEXT NOT NULL DEFAULT ''")
            self._conn.commit()
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                return
            raise

    def _migrate_add_cwd(self):
        """Add cwd column to existing sessions table (when upgrading from an older schema)."""
        try:
            self._conn.execute("ALTER TABLE sessions ADD COLUMN cwd TEXT NOT NULL DEFAULT ''")
            self._conn.commit()
        except sqlite3.OperationalError as e:
            if "duplicate column name" in str(e).lower():
                return
            raise

    def close(self):
        self._conn.close()
