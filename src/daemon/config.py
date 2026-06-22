import json
import os


RELAY_URL = os.environ.get("ACP_RELAY_URL", "ws://localhost:8000/daemon")

_raw_agent_command = os.environ.get("ACP_AGENT_COMMAND", '["opencode", "acp"]')
AGENT_COMMAND = json.loads(_raw_agent_command)

DAEMON_ID = os.environ.get("ACP_DAEMON_ID", "my-pc")
RECONNECT_DELAY = int(os.environ.get("ACP_RECONNECT_DELAY", "5"))
