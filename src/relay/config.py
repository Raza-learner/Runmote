import os

HOST = os.environ.get("ACP_RELAY_HOST", "0.0.0.0")
PORT = int(os.environ.get("ACP_RELAY_PORT", "8000"))
DAEMON_PATH = os.environ.get("ACP_DAEMON_PATH", "/daemon")
APP_PATH = os.environ.get("ACP_APP_PATH", "/app")
