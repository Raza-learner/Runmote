from fastapi import WebSocket

try:
    from .database import Database
    from .session_store import SessionStore
except ImportError:
    from database import Database
    from session_store import SessionStore

db = Database()
store = SessionStore(db)
daemon_websocket: WebSocket | None = None
app_clients: dict[str, WebSocket] = {}
