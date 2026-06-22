import os
import sqlite3

DB_PATH = os.environ.get("ACP_RELAY_DB", "acp_relay.db")


class Database:
    def __init__(self, db_path: str = DB_PATH):
        self._conn = sqlite3.connect(db_path, check_same_thread=False)
        self._conn.row_factory = sqlite3.Row
        self._init_db()

    def _init_db(self):
        self._conn.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                session_id TEXT PRIMARY KEY,
                client_id TEXT NOT NULL DEFAULT '',
                name TEXT NOT NULL DEFAULT '',
                daemon_id TEXT NOT NULL DEFAULT '',
                created_at REAL NOT NULL
            )
        """)
        self._conn.commit()

    def load_all_sessions(self) -> list[dict]:
        rows = self._conn.execute("SELECT * FROM sessions").fetchall()
        return [dict(row) for row in rows]

    def insert_session(self, session_id: str, client_id: str, name: str, daemon_id: str, created_at: float):
        self._conn.execute(
            "INSERT OR REPLACE INTO sessions VALUES (?, ?, ?, ?, ?)",
            (session_id, client_id, name, daemon_id, created_at),
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

    def close(self):
        self._conn.close()
