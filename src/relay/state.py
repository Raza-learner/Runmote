from fastapi import WebSocket
from common.logger import ACPLogger

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

# Track deleted session IDs persistently so session/list from agents that keep
# stale state (e.g. codex) cannot re-register them after daemon reconnects.
recently_deleted_sessions: set[str] = store.deleted_sessions()

# Auth state
token_to_daemons: dict[str, str] = {}
code_to_token: dict[str, str] = {}
app_to_token: dict[str, str] = {}
claimed_codes: set[str] = set()

# Shared logger
log = ACPLogger("Relay")
