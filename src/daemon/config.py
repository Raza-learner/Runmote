import json
import os
import shutil
import socket
import sys


RELAY_HOST = os.environ.get("ACP_RELAY_HOST", "relay.runmote.dev")
RELAY_PORT = os.environ.get("ACP_RELAY_PORT", "443")
_raw_relay_url = os.environ.get("ACP_RELAY_URL", "") or f"wss://{RELAY_HOST}/daemon"
# Auto-convert http/https to ws/wss so users can pass an https URL
if _raw_relay_url.startswith("https://"):
    RELAY_URL = _raw_relay_url.replace("https://", "wss://", 1)
elif _raw_relay_url.startswith("http://"):
    RELAY_URL = _raw_relay_url.replace("http://", "ws://", 1)
else:
    RELAY_URL = _raw_relay_url
_raw_agent_command = os.environ.get("ACP_AGENT_COMMAND", '["opencode", "acp"]')
AGENT_COMMAND = json.loads(_raw_agent_command)


def _find_exe(name, *win_dirs):
    """Find executable on PATH, returning full path or None.
    On Windows also check known install dirs with .cmd/.bat/.exe extensions."""
    path_hit = shutil.which(name)
    if path_hit:
        print(f"[ACP-DETECT] {name}: found on PATH at {path_hit}", flush=True)
        return path_hit
    if sys.platform != "win32":
        return None
    extensions = (".cmd", ".bat", ".exe", "")
    for directory in win_dirs:
        if not directory:
            continue
        if os.path.isdir(directory):
            for entry in os.scandir(directory):
                if entry.is_file():
                    lower_name = entry.name.lower()
                    for ext in extensions:
                        if lower_name == (name + ext).lower():
                            full = os.path.join(directory, entry.name)
                            print(
                                f"[ACP-DETECT] {name}: found in {directory} ({entry.name})",
                                flush=True,
                            )
                            return full
    return None


def _detect_acp_agents() -> list[dict]:
    agents = []

    # Known Windows install directories per agent
    _local = os.environ.get("LOCALAPPDATA", "")
    _appdata = os.environ.get("APPDATA", "")
    _pf = os.environ.get("PROGRAMFILES", "")
    _pf86 = os.environ.get("PROGRAMFILES(X86)", "")
    _home = os.environ.get("USERPROFILE", "")
    _programdata = os.environ.get("PROGRAMDATA", "")
    _npm = os.path.join(_appdata, "npm") if _appdata else ""
    _localbin = os.path.join(_home, ".local", "bin") if _home else ""
    _cargo = os.path.join(_home, ".cargo", "bin") if _home else ""
    _bun = os.path.join(_home, ".bun", "bin") if _home else ""
    _scoop = os.path.join(_home, "scoop", "shims") if _home else ""
    _choco = os.path.join(_programdata, "chocolatey", "bin") if _programdata else ""
    _winget = os.path.join(_local, "Microsoft", "WinGet", "Links") if _local else ""
    _pythonscripts = os.path.join(_appdata, "Python", "Scripts") if _appdata else ""
    _dotnet = os.path.join(_home, ".dotnet", "tools") if _home else ""

    # opencode — native ACP mode
    found = _find_exe(
        "opencode",
        os.path.join(_local, "Programs", "opencode") if _local else "",
        os.path.join(_pf, "OpenCode") if _pf else "",
        os.path.join(_pf86, "OpenCode") if _pf86 else "",
        os.path.join(_home, ".opencode", "bin") if _home else "",
        _localbin,
        _npm,
        _cargo,
        _bun,
        _scoop,
        _choco,
        _winget,
        _pythonscripts,
        _dotnet,
    )
    if found:
        agents.append({"id": "opencode", "name": "OpenCode", "command": [found, "acp"]})

    # codex — CLI + ACP adapter
    codex_cli = _find_exe("codex", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    if codex_cli:
        codex_acp = _find_exe("codex-acp", _npm, _localbin, _scoop, _choco, _winget, _pythonscripts, _dotnet)
        if codex_acp:
            agents.append({"id": "codex", "name": "Codex", "command": [codex_acp]})
        elif shutil.which("npx"):
            agents.append({"id": "codex", "name": "Codex", "command": ["npx", "-y", "@agentclientprotocol/codex-acp"]})

    # claude — CLI + ACP adapter
    claude_cli = (
        _find_exe("claude", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
        or _find_exe("claude-code", _localbin, _npm, _cargo, _bun, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    )
    if claude_cli:
        claude_acp = _find_exe(
            "claude-agent-acp", _npm, _localbin, _scoop, _choco, _winget, _pythonscripts, _dotnet
        )
        if claude_acp:
            agents.append({"id": "claude", "name": "Claude Code", "command": [claude_acp]})
        elif shutil.which("npx"):
            agents.append(
                {
                    "id": "claude",
                    "name": "Claude Code",
                    "command": ["npx", "-y", "@agentclientprotocol/claude-agent-acp"],
                }
            )

    # gemini — native ACP mode
    found = _find_exe("gemini", _localbin, _npm, _scoop, _choco, _winget, _pythonscripts, _dotnet)
    if found:
        agents.append({"id": "gemini", "name": "Gemini", "command": [found, "--acp"]})

    # cursor — native ACP mode
    found = _find_exe(
        "cursor-agent",
        os.path.join(_local, "Programs", "Cursor") if _local else "",
        os.path.join(_pf, "Cursor") if _pf else "",
        os.path.join(_pf86, "Cursor") if _pf86 else "",
        _localbin,
        _npm,
        _scoop,
        _choco,
        _winget,
        _pythonscripts,
        _dotnet,
    )
    if found:
        agents.append({"id": "cursor", "name": "Cursor", "command": [found, "acp"]})

    # copilot — native ACP mode
    found = _find_exe(
        "copilot",
        os.path.join(_local, "GitHubCLI") if _local else "",
        os.path.join(_pf, "GitHub CLI") if _pf else "",
        os.path.join(_pf86, "GitHub CLI") if _pf86 else "",
        _localbin,
        _npm,
        _scoop,
        _choco,
        _winget,
        _pythonscripts,
        _dotnet,
    )
    if found:
        agents.append({"id": "copilot", "name": "Copilot", "command": [found, "--acp", "--stdio"]})

    return agents if agents else [{"id": "default", "name": "Agent", "command": AGENT_COMMAND}]


_raw_agent_commands = os.environ.get("ACP_AGENT_COMMANDS")
if _raw_agent_commands:
    AGENT_CONFIGS = json.loads(_raw_agent_commands)
else:
    AGENT_CONFIGS = _detect_acp_agents()

DAEMON_ID = os.environ.get("ACP_DAEMON_ID", socket.gethostname())
DAEMON_TOKEN = os.environ.get("ACP_DAEMON_TOKEN", "")
RECONNECT_DELAY = int(os.environ.get("ACP_RECONNECT_DELAY", "5"))

# Log detected agents for debugging
_detected_ids = [a["id"] for a in AGENT_CONFIGS]
if _detected_ids:
    print(f"agents detected: {', '.join(_detected_ids)}", flush=True)
else:
    print("no ACP agents detected — install opencode, codex, or claude", flush=True)
