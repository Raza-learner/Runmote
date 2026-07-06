import os
import sys

HOST = os.environ.get("ACP_RELAY_HOST", "0.0.0.0")
RAW_PORT = os.environ.get("ACP_RELAY_PORT", "8000")
try:
    PORT = int(RAW_PORT)
except ValueError:
    print(
        f"FATAL: ACP_RELAY_PORT has invalid value {RAW_PORT!r}. "
        "Check your environment variables are not misconfigured.",
        file=sys.stderr,
    )
    sys.exit(1)

DAEMON_PATH = os.environ.get("ACP_DAEMON_PATH", "/daemon")
APP_PATH = os.environ.get("ACP_APP_PATH", "/app")
# Auth token daemons must present. If unset, auth is skipped (development mode).
RELAY_TOKEN = os.environ.get("ACP_RELAY_TOKEN")

# Cloud/public deployment settings
DISABLE_DISCOVERY = os.environ.get("ACP_RELAY_DISABLE_DISCOVERY", "").lower() in ("1", "true", "yes")
PUBLIC_URL = os.environ.get("ACP_RELAY_PUBLIC_URL", "").rstrip("/")
ALLOWED_ORIGINS = os.environ.get("ACP_RELAY_ALLOWED_ORIGINS", "*")

# Enforce authentication in cloud/public mode
if DISABLE_DISCOVERY and not RELAY_TOKEN:
    print(
        "ERROR: ACP_RELAY_TOKEN must be set when ACP_RELAY_DISABLE_DISCOVERY is true "
        "(cloud deployment requires authentication).",
        file=sys.stderr,
    )
    sys.exit(1)
