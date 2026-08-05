import base64
import hashlib
import hmac
import os
from dataclasses import dataclass, field
from pathlib import Path

from fastapi import WebSocket

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
app_to_daemon: dict[str, str] = {}  # client_id -> daemon_id
claimed_codes: set[str] = set()

# Persisted token -> daemon_id mapping.  Survives daemon disconnects AND
# relay restarts (stored in SQLite) so that mobile apps can auto-reconnect
# (auth/token) even when the daemon is temporarily offline or the relay
# spins down (free-tier Render).  The mapping is populated whenever a
# daemon identifies and is never purged (tokens are random per-session,
# so collisions are negligible).
known_tokens: dict[str, str] = db.load_known_tokens()

# Tracks daemons that have ever received a pairing (via pairing/complete).
# Survives daemon disconnects so the relay can tell a reconnecting daemon
# that it was previously paired but now has no active mobile apps.
daemon_ever_paired: set[str] = db.load_ever_paired()


def remember_token(token: str, daemon_id: str) -> None:
    """Persist an app token -> daemon_id mapping (memory + SQLite)."""
    known_tokens[token] = daemon_id
    try:
        db.save_known_token(token, daemon_id)
    except Exception:
        pass


def remember_ever_paired(daemon_id: str) -> None:
    """Persist the fact that a daemon has been paired (memory + SQLite)."""
    daemon_ever_paired.add(daemon_id)
    try:
        db.save_ever_paired(daemon_id)
    except Exception:
        pass


def get_daemon_by_code(code: str) -> DaemonSession | None:
    did = code_to_daemon.get(code)
    return daemons.get(did) if did else None


def get_daemon_for_app(client_id: str) -> DaemonSession | None:
    did = app_to_daemon.get(client_id)
    return daemons.get(did) if did else None


def get_daemon_id_by_token(token: str) -> str | None:
    """Look up a daemon_id by app auth token.

    ``known_tokens`` holds app-specific tokens generated during pairing.
    These survive daemon disconnects, so mobile apps can auto-reconnect
    even when the daemon is temporarily offline.  We also fall back to
    matching an active daemon's relay token for backward compatibility.
    """
    if token in known_tokens:
        return known_tokens[token]
    did = _resolve_deterministic_token(token)
    if did is not None:
        return did
    for did, session in daemons.items():
        if session.token == token:
            return did
    return None


# ── Deterministic reconnect tokens ────────────────────────────────────────────
#
# Free-tier Render wipes the SQLite DB (known_tokens) on every restart, so a
# random app token saved only there becomes invalid and forces re-pairing.
# To fix that, pairing also issues a token that is *derivable* from the
# daemon's own long-lived secret (the DAEMON_TOKEN it presents at
# identify). Because the daemon token is stored on the user's PC (env var or
# ~/.config/runmote/daemon-token) and survives relay restarts, the relay can
# re-verify the app token after a restart — as long as the daemon is online —
# without ever having persisted it.

_TOKEN_PREFIX = "v1."
_TOKEN_MSG = "acp-app:"


def _hmac_hex(key: str, msg: str) -> str:
    return hmac.new(key.encode(), msg.encode(), hashlib.sha256).hexdigest()


def issue_app_token(daemon_id: str, daemon_token: str) -> str:
    """Return a reconnect token the relay can verify without persistence.

    Format: v1.<base64url(daemon_id)>.<hex(hmac(daemon_token, msg))>.
    If the daemon has no token (development mode), the HMAC key is empty but
    the scheme still works deterministically.
    """
    did_b64 = base64.urlsafe_b64encode(daemon_id.encode()).decode().rstrip("=")
    sig = _hmac_hex(daemon_token, _TOKEN_MSG + daemon_id)
    return f"{_TOKEN_PREFIX}{did_b64}.{sig}"


def _resolve_deterministic_token(token: str) -> str | None:
    """Verify a deterministic token against the currently-connected daemon.

    Requires the daemon to be online so its DAEMON_TOKEN is available for
    verification. Returns the daemon_id on success, else None.
    """
    if not token.startswith(_TOKEN_PREFIX):
        return None
    try:
        _, did_b64, sig = token.split(".", 2)
        pad = "=" * (-len(did_b64) % 4)
        daemon_id = base64.urlsafe_b64decode(did_b64 + pad).decode()
    except Exception:
        return None
    session = daemons.get(daemon_id)
    if session is None:
        return None
    expected = _hmac_hex(session.token, _TOKEN_MSG + daemon_id)
    if not hmac.compare_digest(expected, sig):
        return None
    return daemon_id
