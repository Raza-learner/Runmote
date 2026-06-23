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

# Auth state
token_to_daemons: dict[str, str] = {}
code_to_token: dict[str, str] = {}
app_to_token: dict[str, str] = {}
claimed_codes: set[str] = set()

# Shared logger
log = ACPLogger("Relay")
