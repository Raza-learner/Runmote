import os
import sys
from pathlib import Path

SRC = str(Path(__file__).resolve().parent.parent / "src")
if SRC not in sys.path:
    sys.path.insert(0, SRC)

os.environ.setdefault("ACP_AGENT_COMMAND", '["echo", "acp"]')
os.environ.setdefault("ACP_AGENT_COMMANDS", '[{"id":"test","name":"Test","command":["echo","acp"]}]')
os.environ.setdefault("ACP_RELAY_DB", ":memory:")
os.environ.setdefault("ACP_LOG_DIR", "/tmp/acp_test_logs")
os.environ.setdefault("ACP_LOG_LEVEL", "ERROR")
