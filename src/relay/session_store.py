import time

try:
    from .database import Database
except ImportError:
    from database import Database


class SessionStore:
    def __init__(self, db: Database | None = None):
        self._db = db
        self._sessions: dict[str, dict] = {}
        self._daemon_id: str = ""

        if self._db:
            for s in self._db.load_all_sessions():
                self._sessions[s["session_id"]] = {
                    "sessionId": s["session_id"],
                    "clientId": s["client_id"],
                    "name": s["name"],
                    "daemonId": s["daemon_id"],
                    "createdAt": s["created_at"],
                }

    def set_daemon_id(self, daemon_id: str):
        self._daemon_id = daemon_id

    def register(self, session_id: str, client_id: str = "", name: str = "") -> None:
        now = time.time()
        display_name = name or f"Session {time.strftime('%H:%M')}"
        self._sessions[session_id] = {
            "sessionId": session_id,
            "clientId": client_id,
            "name": display_name,
            "daemonId": self._daemon_id,
            "createdAt": now,
        }
        if self._db:
            self._db.insert_session(session_id, client_id, display_name, self._daemon_id, now)

    def remove(self, session_id: str) -> None:
        self._sessions.pop(session_id, None)
        if self._db:
            self._db.delete_session(session_id)

    def remove_client(self, client_id: str) -> list[str]:
        removed = [
            sid for sid, info in self._sessions.items()
            if info["clientId"] == client_id
        ]
        for sid in removed:
            del self._sessions[sid]
        if self._db and removed:
            self._db.delete_client_sessions(client_id)
        return removed

    def rename(self, session_id: str, name: str) -> bool:
        if session_id in self._sessions:
            self._sessions[session_id]["name"] = name
            if self._db:
                self._db.update_name(session_id, name)
            return True
        return False

    def list_sessions(self) -> list[dict]:
        return list(self._sessions.values())

    def get(self, session_id: str) -> dict | None:
        return self._sessions.get(session_id)
