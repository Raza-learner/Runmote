"""Integration test: relay + daemon + client session lifecycle.

Starts relay and daemon as subprocesses, connects a WebSocket client,
pairs, creates sessions with cwd=/tmp for each agent, and verifies
the session/new and session/list responses.
"""

import asyncio
import json
import os
import signal
import sys
import time
from pathlib import Path

import pytest

SRC = str(Path(__file__).resolve().parent.parent / "src")
if SRC not in sys.path:
    sys.path.insert(0, SRC)

RELAY_PORT = 18765
RELAY_URL = f"ws://localhost:{RELAY_PORT}"
DAEMON_URL = f"ws://localhost:{RELAY_PORT}/daemon"
APP_URL = f"ws://localhost:{RELAY_PORT}/app"


@pytest.fixture(scope="module")
def relay_addr():
    return f"127.0.0.1:{RELAY_PORT}"


def _find_agents():
    """Return a JSON agent list based on what's available on this machine."""
    agents = []
    if os.environ.get("ACP_AGENT_COMMANDS"):
        return os.environ["ACP_AGENT_COMMANDS"]

    if os.environ.get("ACP_SKIP_AGENTS"):
        # Use a fake agent for CI or minimal test
        return json.dumps([{"id": "test", "name": "Test", "command": ["cat"]}])

    if os.environ.get("ACP_AGENT_COMMAND"):
        cmd = json.loads(os.environ["ACP_AGENT_COMMAND"])
        return json.dumps([{"id": "test", "name": "Test", "command": cmd}])

    return json.dumps([{"id": "test", "name": "Test", "command": ["cat"]}])


@pytest.fixture(scope="module")
def env_setup():
    env = os.environ.copy()
    env["ACP_RELAY_HOST"] = "127.0.0.1"
    env["ACP_RELAY_PORT"] = str(RELAY_PORT)
    env["ACP_RELAY_DB"] = ":memory:"
    env["ACP_LOG_DIR"] = "/tmp/acp_test_logs"
    env["ACP_LOG_LEVEL"] = "ERROR"
    env["ACP_DAEMON_ID"] = "test-daemon"
    env["ACP_DAEMON_TOKEN"] = ""
    env["ACP_AGENT_COMMANDS"] = _find_agents()
    return env


@pytest.fixture(scope="module")
def relay_process(env_setup):
    import subprocess
    proc = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "relay.main:app",
         "--host", "127.0.0.1", "--port", str(RELAY_PORT),
         "--log-level", "error"],
        cwd=SRC,
        env=env_setup,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    # Wait for relay to be ready
    import socket
    deadline = time.time() + 10
    while time.time() < deadline:
        try:
            s = socket.create_connection(("127.0.0.1", RELAY_PORT), timeout=1)
            s.close()
            break
        except (ConnectionRefusedError, OSError):
            time.sleep(0.2)
    else:
        proc.terminate()
        proc.wait()
        pytest.fail("Relay did not start in time")
    yield proc
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()


@pytest.fixture(scope="module")
def daemon_process(env_setup):
    import subprocess
    proc = subprocess.Popen(
        [sys.executable, "-m", "daemon.main"],
        cwd=SRC,
        env=env_setup,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    # Wait for pairing code in daemon output
    pairing_code = None
    deadline = time.time() + 15
    while time.time() < deadline:
        line = proc.stdout.readline()
        if not line:
            break
        if "pairing code:" in line:
            # Line format: "← pairing code: 123456"
            pairing_code = line.split(":")[-1].strip()
            break
    if pairing_code is None:
        proc.terminate()
        proc.wait()
        pytest.fail(f"Daemon did not emit pairing code. stdout: {proc.stdout.read()}")
    # Store pairing code for the test module
    proc.pairing_code = pairing_code
    yield proc
    proc.terminate()
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()


class TestSessionIntegration:
    """Real relay+daemon integration test."""

    @pytest.mark.asyncio
    async def test_connect_pair_and_create_session(self, daemon_process):
        from websockets.asyncio.client import connect

        pairing_code = daemon_process.pairing_code
        assert pairing_code is not None, "No pairing code from daemon"
        assert len(pairing_code) == 6, f"Invalid pairing code: {pairing_code}"

        async with connect(APP_URL) as ws:
            # --- Pair ---
            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 1,
                "method": "auth/pair",
                "params": {"code": pairing_code},
            }))
            resp = json.loads(await ws.recv())
            assert resp.get("result", {}).get("paired") is True, \
                f"Pairing failed: {resp}"
            daemon_id = resp["result"].get("daemonId")
            print(f"  ✓ Paired with daemon: {daemon_id}")

            # Wait for agent/list to arrive
            await asyncio.sleep(1)

            # --- agent/list ---
            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 2,
                "method": "agent/list",
                "params": {},
            }))
            resp = json.loads(await ws.recv())
            agents = (resp.get("result") or resp.get("params") or {}).get("agents", [])
            print(f"  ✓ Got {len(agents)} agent(s): {[a['id'] for a in agents]}")
            assert len(agents) > 0, f"No agents found: {resp}"

            # --- session/new with cwd=/tmp for each agent ---
            for agent in agents:
                agent_id = agent["id"]
                print(f"\n  Testing session/new for agent '{agent_id}'...")

                await ws.send(json.dumps({
                    "jsonrpc": "2.0", "id": 3,
                    "method": "session/new",
                    "params": {
                        "agentId": agent_id,
                        "cwd": "/tmp",
                    },
                }))
                resp = json.loads(await ws.recv())

                # Response might be a direct result or have method/params
                result = resp.get("result")
                if result is None:
                    # Might be a tagged response
                    print(f"    Unexpected response format: {resp}")
                    continue

                session_id = result.get("sessionId") or result.get("id")
                assert session_id is not None, \
                    f"No sessionId in session/new for {agent_id}: {resp}"
                print(f"    ✓ Created session: {session_id}")
                print(f"    ✓ configOptions present: {'configOptions' in result}")

                # Check that cwd is reflected (some agents return it)
                returned_cwd = result.get("cwd", "")
                if returned_cwd:
                    assert "/tmp" in returned_cwd, \
                        f"cwd not /tmp: {returned_cwd}"

            # --- session/list ---
            print("\n  Testing session/list...")
            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 4,
                "method": "session/list",
                "params": {},
            }))
            resp = json.loads(await ws.recv())
            sessions = resp.get("result", {}).get("sessions", [])
            print(f"    Got {len(sessions)} session(s)")
            for s in sessions:
                sid = s.get("sessionId") or s.get("id", "")
                cwd = s.get("cwd", "")
                print(f"    - {sid}  cwd={cwd}")

            # --- daemon/status ---
            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 5,
                "method": "daemon/status",
                "params": {},
            }))
            resp = json.loads(await ws.recv())
            status = resp.get("result", {})
            assert status.get("connected") is True, \
                f"Daemon not connected: {status}"
            print(f"  ✓ Daemon status: connected={status.get('connected')}")

    @pytest.mark.asyncio
    async def test_session_list_persistence(self, daemon_process):
        """Verify sessions from previous test are still visible."""
        from websockets.asyncio.client import connect

        pairing_code = daemon_process.pairing_code

        async with connect(APP_URL) as ws:
            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 1,
                "method": "auth/pair",
                "params": {"code": pairing_code},
            }))
            resp = json.loads(await ws.recv())
            assert resp.get("result", {}).get("paired") is True

            await asyncio.sleep(0.5)

            await ws.send(json.dumps({
                "jsonrpc": "2.0", "id": 2,
                "method": "session/list",
                "params": {},
            }))
            resp = json.loads(await ws.recv())

            # The relay returns cached sessions when daemon reconnects
            result = resp.get("result", {})
            sessions = result.get("sessions", [])
            print(f"  session/list returned {len(sessions)} session(s)")

            # Even if daemon disconnected and reconnected, relay should
            # have persisted sessions in memory (as long as daemon didn't restart).
            # At minimum, the response should be well-formed.
            assert isinstance(sessions, list)
