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
        self._deleted: set[str] = set()

        if self._db:
            for s in self._db.load_all_sessions():
                self._sessions[s["session_id"]] = {
                    "sessionId": s["session_id"],
                    "id": s["session_id"],
                    "clientId": s["client_id"],
                    "name": s["name"],
                    "title": s["name"],
                    "cwd": s.get("cwd", ""),
                    "agentId": s.get("agent_id", ""),
                    "daemonId": s["daemon_id"],
                    "createdAt": s["created_at"],
                    "updatedAt": s["created_at"],
                }
            self._deleted = self._db.load_deleted_sessions()

    def set_daemon_id(self, daemon_id: str):
        self._daemon_id = daemon_id

    def get_daemon_id(self) -> str:
        return self._daemon_id

    def clear_daemon_id(self):
        self._daemon_id = ""

    def register(
        self,
        session_id: str,
        client_id: str = "",
        name: str = "",
        cwd: str = "",
        agent_id: str = "",
        updated_at: float | None = None,
    ) -> None:
        now = time.time()
        display_name = name or f"Session {time.strftime('%H:%M')}"
        timestamp = updated_at or now
        self._sessions[session_id] = {
            "sessionId": session_id,
            "id": session_id,
            "clientId": client_id,
            "name": display_name,
            "title": display_name,
            "cwd": cwd,
            "agentId": agent_id,
            "daemonId": self._daemon_id,
            "createdAt": timestamp,
            "updatedAt": timestamp,
        }
        if self._db:
            try:
                self._db.insert_session(
                    session_id, client_id, agent_id, display_name, self._daemon_id, timestamp, cwd
                )
            except Exception as e:
                print(f"DB write failed: {e}")

    def remove(self, session_id: str, agent_id: str = "") -> None:
        existing = self._sessions.get(session_id)
        if existing and agent_id and existing.get("agentId") != agent_id:
            # Agent ID mismatch — don't remove from active sessions (it
            # belongs to another agent), but still mark as deleted so it
            # doesn't reappear on subsequent session/list responses.
            self._deleted.add(session_id)
            if self._db:
                self._db.mark_deleted(session_id)
            return
        self._sessions.pop(session_id, None)
        if self._db:
            self._db.delete_session(session_id)
            self._db.mark_deleted(session_id)
            self._deleted.add(session_id)

    def mark_deleted(self, session_id: str) -> None:
        self._deleted.add(session_id)
        if self._db:
            self._db.mark_deleted(session_id)

    def is_deleted(self, session_id: str) -> bool:
        return session_id in self._deleted

    def deleted_sessions(self) -> set[str]:
        return set(self._deleted)

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
            self._sessions[session_id]["title"] = name
            if self._db:
                self._db.update_name(session_id, name)
            return True
        return False

    def list_sessions(self, agent_id: str = "") -> list[dict]:
        if not agent_id:
            return list(self._sessions.values())
        return [
            session for session in self._sessions.values()
            if session.get("agentId") == agent_id
        ]

    def get(self, session_id: str) -> dict | None:
        return self._sessions.get(session_id)
