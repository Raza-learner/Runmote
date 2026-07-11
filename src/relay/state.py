import json
import os
from dataclasses import dataclass, field
from pathlib import Path

from fastapi import WebSocket
from common.logger import ACPLogger

try:
    from .database import Database
    from .session_store import SessionStore
except ImportError:
    from database import Database
    from session_store import SessionStore


@dataclass
class DaemonSession:
    websocket: WebSocket
    daemon_id: str
    token: str
    public_url: str = ""
    paired_apps: set[str] = field(default_factory=set)


db = Database()
store = SessionStore(db)
daemons: dict[str, DaemonSession] = {}  # keyed by daemon_id
app_clients: dict[str, WebSocket] = {}

# Track deleted session IDs persistently so session/list from agents that keep
# stale state (e.g. codex) cannot re-register them after daemon reconnects.
recently_deleted_sessions: set = store.deleted_sessions()

# Auth state
_AUTH_STATE_PATH = Path(os.environ.get("ACP_CONFIG_DIR", Path.home() / ".config" / "runmote")) / "relay_auth.json"
code_to_daemon: dict[str, str] = {}  # pairing code -> daemon_id
app_to_daemon: dict[str, str] = {}   # client_id -> daemon_id
claimed_codes: set[str] = set()

# Persisted token -> daemon_id mapping.  Survives daemon disconnects so that
# mobile apps can auto-reconnect (auth/token) even when the daemon is
# temporarily offline.  The mapping is populated whenever a daemon identifies
# and is never purged (tokens are random per-session, so collisions are
# negligible).
known_tokens: dict[str, str] = {}


def get_daemon_by_code(code: str) -> DaemonSession | None:
    did = code_to_daemon.get(code)
    return daemons.get(did) if did else None


def get_daemon_for_app(client_id: str) -> DaemonSession | None:
    did = app_to_daemon.get(client_id)
    return daemons.get(did) if did else None


def get_daemon_id_by_token(token: str) -> str | None:
    """Look up a daemon_id by auth token.

    Works for both *active* daemons (in ``daemons``) and *offline* daemons
    (only in ``known_tokens``), so mobile apps can auto-reconnect even when
    the daemon is temporarily disconnected.
    """
    for did, session in daemons.items():
        if session.token == token:
            return did
    return known_tokens.get(token)




