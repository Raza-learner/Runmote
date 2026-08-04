import os
from unittest import mock

import pytest


@pytest.fixture(autouse=True)
def _clear_env():
    saved = {k: os.environ.pop(k, None) for k in ["ACP_AGENT_COMMAND", "ACP_AGENT_COMMANDS", "ACP_AGENT_ID"]}
    yield
    for k, v in saved.items():
        if v is not None:
            os.environ[k] = v


class TestDetectAcpAgents:
    def test_fallback_to_default_when_no_agents_found(self):
        with (
            mock.patch("daemon.config.shutil.which", return_value=None),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            assert len(agents) == 1
            assert agents[0]["id"] == "default"

    def test_detects_claude(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd in ("claude", "claude-agent-acp") else None

        with (
            mock.patch("daemon.config.shutil.which", side_effect=which_side_effect),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "claude" in ids

    def test_detects_codex_binary(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd in ("codex", "codex-acp") else None

        with (
            mock.patch("daemon.config.shutil.which", side_effect=which_side_effect),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "codex" in ids

    def test_codex_falls_back_to_npx(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd in ("codex", "npx") else None

        with (
            mock.patch("daemon.config.shutil.which", side_effect=which_side_effect),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert "codex" in ids
            codex_cfg = next(a for a in agents if a["id"] == "codex")
            assert codex_cfg["command"] == ["npx", "-y", "@agentclientprotocol/codex-acp"]

    def test_detects_multiple_agents(self):
        def which_side_effect(cmd: str):
            found = {"codex", "codex-acp", "claude", "claude-agent-acp"}
            return "/usr/bin/" + cmd if cmd in found else None

        with (
            mock.patch("daemon.config.shutil.which", side_effect=which_side_effect),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            ids = {a["id"] for a in agents}
            assert ids >= {"codex", "claude"}

    def test_daemon_id_defaults_to_hostname(self):
        with mock.patch("daemon.config.socket.gethostname", return_value="myhost"):
            import importlib
            import daemon.config

            importlib.reload(daemon.config)
            assert daemon.config.DAEMON_ID == "myhost"

    def test_reconnect_delay_default(self):
        import daemon.config

        assert daemon.config.RECONNECT_DELAY == 5

    def test_find_exe_returns_path_when_on_path(self):
        with mock.patch("daemon.config.shutil.which", return_value="/usr/bin/opencode"):
            from daemon.config import _find_exe

            result = _find_exe("opencode")
            assert result == "/usr/bin/opencode"

    def test_find_exe_returns_none_when_not_found_on_linux(self):
        with mock.patch("daemon.config.shutil.which", return_value=None):
            from daemon.config import _find_exe

            result = _find_exe("opencode")
            assert result is None

    def test_find_exe_finds_cmd_on_windows(self):
        with (
            mock.patch("daemon.config.sys.platform", "win32"),
            mock.patch("daemon.config.shutil.which", return_value=None),
            mock.patch("daemon.config.os.path.isdir", return_value=True),
            mock.patch("daemon.config.os.scandir") as mock_scandir,
        ):
            mock_entry = mock.MagicMock()
            mock_entry.name = "opencode.cmd"
            mock_entry.is_file.return_value = True
            mock_scandir.return_value = [mock_entry]

            from daemon.config import _find_exe

            result = _find_exe("opencode", r"C:\npm")
            assert result == os.path.join(r"C:\npm", "opencode.cmd")

    def test_find_exe_finds_bat_on_windows(self):
        with (
            mock.patch("daemon.config.sys.platform", "win32"),
            mock.patch("daemon.config.shutil.which", return_value=None),
            mock.patch("daemon.config.os.path.isdir", return_value=True),
            mock.patch("daemon.config.os.scandir") as mock_scandir,
        ):
            mock_entry = mock.MagicMock()
            mock_entry.name = "opencode.bat"
            mock_entry.is_file.return_value = True
            mock_scandir.return_value = [mock_entry]

            from daemon.config import _find_exe

            result = _find_exe("opencode", r"C:\npm")
            assert result == os.path.join(r"C:\npm", "opencode.bat")

    def test_find_exe_finds_exe_on_windows(self):
        with (
            mock.patch("daemon.config.sys.platform", "win32"),
            mock.patch("daemon.config.shutil.which", return_value=None),
            mock.patch("daemon.config.os.path.isdir", return_value=True),
            mock.patch("daemon.config.os.scandir") as mock_scandir,
        ):
            mock_entry = mock.MagicMock()
            mock_entry.name = "opencode.exe"
            mock_entry.is_file.return_value = True
            mock_scandir.return_value = [mock_entry]

            from daemon.config import _find_exe

            result = _find_exe("opencode", r"C:\npm")
            assert result == os.path.join(r"C:\npm", "opencode.exe")

    def test_find_exe_prefers_shutil_which_over_scandir(self):
        with (
            mock.patch("daemon.config.sys.platform", "win32"),
            mock.patch("daemon.config.shutil.which", return_value=r"C:\Windows\opencode.exe"),
            mock.patch("daemon.config.os.path.isdir", return_value=True),
            mock.patch("daemon.config.os.scandir") as mock_scandir,
        ):
            mock_entry = mock.MagicMock()
            mock_entry.name = "opencode.cmd"
            mock_entry.is_file.return_value = True
            mock_scandir.return_value = [mock_entry]

            from daemon.config import _find_exe

            result = _find_exe("opencode", r"C:\npm")
            assert result == r"C:\Windows\opencode.exe"

    def test_find_exe_ignores_non_matching_names_on_windows(self):
        with (
            mock.patch("daemon.config.sys.platform", "win32"),
            mock.patch("daemon.config.shutil.which", return_value=None),
            mock.patch("daemon.config.os.path.isdir", return_value=True),
            mock.patch("daemon.config.os.scandir") as mock_scandir,
        ):
            mock_entry = mock.MagicMock()
            mock_entry.name = "other-tool.exe"
            mock_entry.is_file.return_value = True
            mock_scandir.return_value = [mock_entry]

            from daemon.config import _find_exe

            result = _find_exe("opencode", r"C:\npm")
            assert result is None

    def test_detected_codex_uses_resolved_path(self):
        def which_side_effect(cmd: str):
            return "/usr/bin/" + cmd if cmd in ("codex", "codex-acp") else None

        with (
            mock.patch("daemon.config.shutil.which", side_effect=which_side_effect),
            mock.patch("daemon.config.os.scandir", return_value=[]),
        ):
            from daemon.config import _detect_acp_agents

            agents = _detect_acp_agents()
            codex_cfg = next(a for a in agents if a["id"] == "codex")
            assert codex_cfg["command"][0] == "/usr/bin/codex-acp"
