import os
from unittest import mock

import pytest


@pytest.fixture(autouse=True)
def _clear_env():
    saved = {
        k: os.environ.pop(k, None)
        for k in ["ACP_AGENT_COMMAND", "ACP_AGENT_COMMANDS", "ACP_AGENT_ID"]
    }
    yield
    for k, v in saved.items():
        if v is not None:
            os.environ[k] = v


class TestDetectAcpAgents:
    def test_fallback_to_default_when_no_agents_found(self):
        with mock.patch("daemon.config.shutil.which", return_value=None):
            from daemon.config import _detect_acp_agents
            agents = _detect_acp_agents()
            assert len(agents) == 1
            assert agents[0]["id"] == "default"

    def test_detects_opencode(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd == "opencode" else None
        with mock.patch("daemon.config.shutil.which", side_effect=which_side_effect):
            from daemon.config import _detect_acp_agents
            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "opencode" in ids

    def test_detects_codex_binary(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd == "codex-acp" else None
        with mock.patch("daemon.config.shutil.which", side_effect=which_side_effect):
            from daemon.config import _detect_acp_agents
            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "codex" in ids

    def test_codex_falls_back_to_npx(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd == "npx" else None
        with mock.patch("daemon.config.shutil.which", side_effect=which_side_effect):
            from daemon.config import _detect_acp_agents
            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "codex" in ids
            codex_cfg = next(a for a in agents if a["id"] == "codex")
            assert codex_cfg["command"] == ["npx", "-y", "@agentclientprotocol/codex-acp"]

    def test_detects_multiple_agents(self):
        def which_side_effect(cmd: str):
            found = {"opencode", "gemini", "claude-agent-acp"}
            return "/usr/bin/" + cmd if cmd in found else None
        with mock.patch("daemon.config.shutil.which", side_effect=which_side_effect):
            from daemon.config import _detect_acp_agents
            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert ids >= {"opencode", "gemini", "claude"}

    def test_daemon_id_defaults_to_hostname(self):
        with mock.patch("daemon.config.socket.gethostname", return_value="myhost"):
            import importlib
            import daemon.config
            importlib.reload(daemon.config)
            assert daemon.config.DAEMON_ID == "myhost"

    def test_reconnect_delay_default(self):
        import daemon.config
        assert daemon.config.RECONNECT_DELAY == 5
