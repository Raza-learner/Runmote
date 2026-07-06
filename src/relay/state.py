import json
import os
from pathlib import Path

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
recently_deleted_sessions: set = store.deleted_sessions()

# Auth state
_AUTH_STATE_PATH = Path(os.environ.get("ACP_CONFIG_DIR", Path.home() / ".config" / "acp")) / "relay_auth.json"
token_to_daemons: dict[str, str] = {}
code_to_token: dict[str, str] = {}
app_to_token: dict[str, str] = {}
claimed_codes: set[str] = set()


def _load_auth_state() -> None:
    global token_to_daemons, code_to_token
    if _AUTH_STATE_PATH.exists():
        try:
            with open(_AUTH_STATE_PATH, "r", encoding="utf-8") as f:
                data = json.load(f)
            token_to_daemons.update(data.get("token_to_daemons", {}))
            code_to_token.update(data.get("code_to_token", {}))
            print(f"Loaded auth state from {_AUTH_STATE_PATH}")
        except Exception as e:
            print(f"Warning: could not load auth state: {e}")


def save_auth_state() -> None:
    _AUTH_STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    try:
        with open(_AUTH_STATE_PATH, "w", encoding="utf-8") as f:
            json.dump({
                "token_to_daemons": token_to_daemons,
                "code_to_token": code_to_token,
            }, f)
    except Exception as e:
        print(f"Warning: could not save auth state: {e}")


_load_auth_state()

# Shared logger
log = ACPLogger("Relay")

