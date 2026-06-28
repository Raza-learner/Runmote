import asyncio
import json
import os
import signal
import stat
import sys
from copy import deepcopy
from pathlib import Path

_src = Path(__file__).resolve().parent
if str(_src) not in sys.path:
    sys.path.insert(0, str(_src))

from config import AGENT_CONFIGS, DAEMON_ID, DAEMON_TOKEN, RECONNECT_DELAY, RELAY_URL, _detect_acp_agents
from websockets.asyncio.client import connect


def log(msg: str):
    print(msg, flush=True)


def _normalize_path(path: str) -> str:
    return path.replace("\\", "/")


def _is_hidden(entry: os.DirEntry) -> bool:
    if entry.name.startswith("."):
        return True
    if sys.platform == "win32":
        attrs = entry.stat(follow_symlinks=False).st_file_attributes
        if attrs is not None:
            return bool(attrs & stat.FILE_ATTRIBUTE_HIDDEN)
    return False


class AgentProcess:
    def __init__(self, config: dict):
        self.id = config["id"]
        self.name = config.get("name", self.id)
        self.command = config["command"]
        self.proc = None
        self.online = False
        self.version = ""
        self.info = {"name": self.name, "version": ""}
        self.capabilities = {}

    async def start(self):
        if self.proc and self.proc.returncode is None:
            return

        self.proc = await asyncio.create_subprocess_exec(
            *self.command,
            stdin=asyncio.subprocess.PIPE,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        self.online = True
        await self.send({
            "jsonrpc": "2.0",
            "method": "initialize",
            "id": f"daemon_init_{self.id}",
            "params": {"protocolVersion": 1},
        })
        await self.send({
            "jsonrpc": "2.0",
            "method": "session/list",
            "id": f"daemon_sessions_{self.id}",
            "params": {},
        })
        log(f"Started {self.id}: {' '.join(self.command)}")

    async def send(self, message: dict):
        if not self.proc or not self.proc.stdin or self.proc.returncode is not None:
            self.online = False
            raise RuntimeError(f"agent {self.id} is not running")
        self.proc.stdin.write(json.dumps(message).encode() + b"\n")
        await self.proc.stdin.drain()

    async def stop(self):
        if self.proc is None or self.proc.returncode is not None:
            return
        self.proc.terminate()
        try:
            await asyncio.wait_for(self.proc.wait(), timeout=5)
        except asyncio.TimeoutError:
            self.proc.kill()
            await self.proc.wait()
        self.online = False

    def as_json(self) -> dict:
        return {
            "id": self.id,
            "name": self.info.get("name") or self.name,
            "version": self.info.get("version") or self.version,
            "online": self.online,
            "command": self.command,
        }


def _agent_list_message(agents: dict[str, AgentProcess], msg_id=None) -> dict:
    message = {
        "jsonrpc": "2.0",
        "result": {"agents": [agent.as_json() for agent in agents.values()]},
    }
    if msg_id is None:
        message["method"] = "agent/list"
    else:
        message["id"] = msg_id
    return message


def _default_agent_id(agents: dict[str, AgentProcess]) -> str:
    for agent in agents.values():
        if agent.online:
            return agent.id
    return next(iter(agents))


def _extract_agent_id(message: dict, agents: dict[str, AgentProcess]) -> str:
    params = message.get("params")
    agent_id = message.get("agentId")
    if isinstance(params, dict):
        agent_id = params.get("agentId") or agent_id
    if agent_id in agents:
        return agent_id
    return _default_agent_id(agents)


def _message_for_agent(message: dict) -> dict:
    forwarded = deepcopy(message)
    forwarded.pop("agentId", None)
    params = forwarded.get("params")
    if isinstance(params, dict):
        params.pop("agentId", None)
    return forwarded


def _tag_agent_response(message: dict, agent: AgentProcess) -> dict:
    tagged = deepcopy(message)
    result = tagged.get("result")
    if isinstance(result, dict):
        result.setdefault("agentId", agent.id)
        sessions = result.get("sessions")
        if isinstance(sessions, list):
            for session in sessions:
                if isinstance(session, dict):
                    session.setdefault("agentId", agent.id)
    params = tagged.get("params")
    if isinstance(params, dict):
        params.setdefault("agentId", agent.id)
    error = tagged.get("error")
    if isinstance(error, dict):
        data = error.setdefault("data", {})
        if isinstance(data, dict):
            data.setdefault("agentId", agent.id)
    return tagged


def _capture_agent_info(message: dict, agent: AgentProcess):
    result = message.get("result")
    if not isinstance(result, dict):
        return

    info = result.get("agentInfo")
    if isinstance(info, dict):
        # Prefer daemon-configured display name over agent self-reported name
        # so codex shows "Codex" instead of "@agentclientprotocol/codex-acp".
        display_name = agent.name or info.get("name")
        info["name"] = display_name
        agent.info = {
            "name": display_name,
            "version": info.get("version") or "",
        }
        agent.version = agent.info["version"]

    capabilities = result.get("agentCapabilities")
    if isinstance(capabilities, dict):
        agent.capabilities = capabilities


async def _send_json(websocket, message: dict):
    await websocket.send(json.dumps(message))


async def run_daemon():
    agents = {
        config["id"]: AgentProcess(config)
        for config in AGENT_CONFIGS
        if config.get("id") and config.get("command")
    }
    if not agents:
        raise RuntimeError("no ACP agents configured")

    while True:
        try:
            async with connect(RELAY_URL) as websocket:
                log("Connected to relay!")

                identify_id = "daemon_ident"
                await _send_json(websocket, {
                    "jsonrpc": "2.0",
                    "id": identify_id,
                    "method": "daemon/identify",
                    "params": {"daemonId": DAEMON_ID, "token": DAEMON_TOKEN},
                })


                async for msg in websocket:
                    try:
                        data = json.loads(msg)
                        if data.get("id") == identify_id:
                            result = data.get("result") or {}
                            pairing_code = result.get("pairingCode", "")
                            if pairing_code:
                                log(f"← pairing code: {pairing_code}")
                                banner = (
                                    "\n"
                                    "╔═══════════════════════════════════════╗\n"
                                    f"║        Device Code:  {pairing_code:<18}║\n"
                                    "╚═══════════════════════════════════════╝\n"
                                )
                                print(banner, flush=True)
                            break
                    except json.JSONDecodeError:
                        log(f"Invalid JSON from relay during identify: {msg[:200]}")

                for agent in agents.values():
                    try:
                        await agent.start()
                    except Exception as e:
                        agent.online = False
                        log(f"Failed to start {agent.id}: {e}")

                await _send_json(websocket, _agent_list_message(agents))

                async def relay_to_agents():
                    async for message in websocket:
                        try:
                            data = json.loads(message)
                        except json.JSONDecodeError:
                            log(f"Invalid JSON from relay: {message[:200]}")
                            continue

                        method = data.get("method")
                        msg_id = data.get("id")
                        if method == "agent/list":
                            detected = {a["id"]: a for a in _detect_acp_agents()
                                        if a.get("id") != "default"}
                            for aid in list(agents.keys()):
                                if aid not in detected:
                                    log(f"Agent '{aid}' no longer detected, stopping...")
                                    if aid in agent_tasks:
                                        at = agent_tasks.pop(aid)
                                        for t in [at["relay"], at["stderr"], at.get("watch"), at.get("sender")]:
                                            if t and not t.done():
                                                t.cancel()
                                    send_queues.pop(aid, None)
                                    await agents[aid].stop()
                                    del agents[aid]
                            for aid, cfg in detected.items():
                                if aid not in agents:
                                    log(f"Agent '{aid}' newly detected, starting...")
                                    agents[aid] = AgentProcess(cfg)
                                    try:
                                        await agents[aid].start()
                                    except Exception as e:
                                        agents[aid].online = False
                                        log(f"Failed to start new agent {aid}: {e}")
                                    if agents[aid].online:
                                        send_q = asyncio.Queue()
                                        send_queues[aid] = send_q
                                        agent_tasks[aid] = {
                                            "agent": agents[aid],
                                            "relay": asyncio.create_task(agent_to_relay(agents[aid])),
                                            "stderr": asyncio.create_task(log_stderr(agents[aid])),
                                            "watch": asyncio.create_task(watch_agent(agents[aid])),
                                            "sender": asyncio.create_task(agent_sender(agents[aid], send_q)),
                                        }
                            await _send_json(websocket, _agent_list_message(agents, msg_id))
                            continue

                        if method == "filesystem/list_drives":
                            try:
                                drives = []
                                if sys.platform == "win32":
                                    import string
                                    for letter in string.ascii_uppercase:
                                        drive = f"{letter}:\\"
                                        if os.path.exists(drive):
                                            drives.append({
                                                "name": f"{letter}:",
                                                "path": _normalize_path(os.path.abspath(drive)),
                                                "type": "directory",
                                                "size": 0,
                                                "isSymlink": False,
                                            })
                                else:
                                    drives.append({
                                        "name": "/",
                                        "path": "/",
                                        "type": "directory",
                                        "size": 0,
                                        "isSymlink": False,
                                    })
                                await _send_json(websocket, {
                                    "jsonrpc": "2.0",
                                    "id": msg_id,
                                    "result": {"entries": drives},
                                })
                            except Exception as e:
                                await _send_json(websocket, {
                                    "jsonrpc": "2.0",
                                    "id": msg_id,
                                    "error": {"code": -32000, "message": f"Failed to list drives: {e}"},
                                })
                            continue

                        if method == "filesystem/get_home":
                            await _send_json(websocket, {
                                "jsonrpc": "2.0",
                                "id": msg_id,
                                "result": {"home": _normalize_path(os.path.expanduser("~"))},
                            })
                            continue

                        if method == "filesystem/list_directory":
                            params = data.get("params") or {}
                            path = os.path.expanduser(params.get("path", ".") or ".")
                            show_hidden = params.get("showHidden", False)
                            try:
                                entries = []
                                for entry in os.scandir(path):
                                    if not show_hidden and _is_hidden(entry):
                                        continue
                                    try:
                                        is_dir = entry.is_dir()
                                        is_file = entry.is_file()
                                        is_symlink = entry.is_symlink()
                                        stat_info = entry.stat(follow_symlinks=False)
                                        entries.append({
                                            "name": entry.name,
                                            "path": _normalize_path(os.path.abspath(entry.path)),
                                            "type": "directory" if is_dir else "file" if is_file else "other",
                                            "size": stat_info.st_size if is_file else 0,
                                            "isSymlink": is_symlink,
                                        })
                                    except OSError:
                                        pass
                                entries.sort(key=lambda e: (0 if e["type"] == "directory" else 1, e["name"].lower()))
                                await _send_json(websocket, {
                                    "jsonrpc": "2.0",
                                    "id": msg_id,
                                    "result": {
                                        "entries": entries,
                                        "path": _normalize_path(os.path.abspath(path)),
                                    },
                                })
                            except Exception as e:
                                await _send_json(websocket, {
                                    "jsonrpc": "2.0",
                                    "id": msg_id,
                                    "error": {"code": -32000, "message": f"Failed to list directory: {e}"},
                                })
                            continue

                        agent = agents[_extract_agent_id(data, agents)]
                        if not agent.online:
                            await _send_json(websocket, {
                                "jsonrpc": "2.0",
                                "id": msg_id,
                                "error": {
                                    "code": -32005,
                                    "message": f"agent {agent.id} is not running",
                                    "data": {"agentId": agent.id},
                                },
                            })
                            continue

                        if agent.id in send_queues:
                            await send_queues[agent.id].put(_message_for_agent(data))
                        else:
                            log(f"No send queue for {agent.id}, dropping message")

                async def agent_to_relay(agent: AgentProcess):
                    if not agent.proc or not agent.proc.stdout:
                        return
                    buf = b''
                    while True:
                        try:
                            chunk = await agent.proc.stdout.read(65536)
                        except Exception:
                            break
                        if not chunk:
                            break
                        buf += chunk
                        while b'\n' in buf:
                            line, buf = buf.split(b'\n', 1)
                            raw = line.decode(errors='replace').strip()
                            if not raw:
                                continue
                            try:
                                data = json.loads(raw)
                                _capture_agent_info(data, agent)
                                tagged = _tag_agent_response(data, agent)
                                await _send_json(websocket, tagged)
                            except json.JSONDecodeError:
                                await websocket.send(raw)
                        if len(buf) > 1_048_576:
                            log(f"{agent.id} stdout: discarding oversized buffer ({len(buf)} bytes without newline)")
                            buf = b''
                    if buf:
                        raw = buf.decode(errors='replace').strip()
                        if raw:
                            try:
                                data = json.loads(raw)
                                _capture_agent_info(data, agent)
                                tagged = _tag_agent_response(data, agent)
                                await _send_json(websocket, tagged)
                            except json.JSONDecodeError:
                                await websocket.send(raw)

                async def log_stderr(agent: AgentProcess):
                    if not agent.proc or not agent.proc.stderr:
                        return
                    async for line in agent.proc.stderr:
                        if line:
                            print(
                                f"{agent.id} stderr: {line.decode().strip()}",
                                file=sys.stderr,
                                flush=True,
                            )

                async def watch_agent(agent: AgentProcess):
                    if not agent.proc:
                        return
                    await agent.proc.wait()
                    agent.online = False
                    log(f"Agent {agent.id} exited with code {agent.proc.returncode}")
                    await _send_json(websocket, _agent_list_message(agents))

                async def agent_sender(agent: AgentProcess, queue: asyncio.Queue):
                    while True:
                        message = await queue.get()
                        try:
                            await agent.send(message)
                        except Exception:
                            break

                relay_task = asyncio.create_task(relay_to_agents())
                send_queues: dict[str, asyncio.Queue] = {}
                agent_tasks: dict = {}
                for agent in agents.values():
                    if agent.online:
                        send_q = asyncio.Queue()
                        send_queues[agent.id] = send_q
                        agent_tasks[agent.id] = {
                            "agent": agent,
                            "relay": asyncio.create_task(agent_to_relay(agent)),
                            "stderr": asyncio.create_task(log_stderr(agent)),
                            "watch": asyncio.create_task(watch_agent(agent)),
                            "sender": asyncio.create_task(agent_sender(agent, send_q)),
                        }

                while agent_tasks:
                    # Wait for any agent to fail
                    all_tasks = [relay_task] + [
                        t for at in agent_tasks.values() for t in at.values() if isinstance(t, asyncio.Task)
                    ]
                    done, pending = await asyncio.wait(
                        [t for t in all_tasks if not t.done()],
                        return_when=asyncio.FIRST_COMPLETED,
                    )

                    # Check which agent's watch task completed
                    for aid, at in list(agent_tasks.items()):
                        if at["watch"].done():
                            log(f"Agent {aid} stopped, continuing others...")
                            for t in [at["relay"], at["stderr"], at.get("sender")]:
                                if t and not t.done():
                                    t.cancel()
                            send_queues.pop(aid, None)
                            del agent_tasks[aid]

                    # If relay task stopped or no agents left, stop everything
                    if relay_task.done() or not agent_tasks:
                        if relay_task.done():
                            exc = relay_task.exception()
                            if exc:
                                log(f"Relay task exception: {exc}")
                        break

                for t in pending:
                    t.cancel()

        except asyncio.CancelledError:
            raise
        except Exception as e:
            log(f"Connection error: {e}")

        for agent in agents.values():
            await agent.stop()

        log(f"Reconnecting in {RECONNECT_DELAY}s...")
        await asyncio.sleep(RECONNECT_DELAY)


async def main():
    loop = asyncio.get_running_loop()
    stop = asyncio.Event()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)

    daemon_task = asyncio.create_task(run_daemon())
    await stop.wait()
    print("\nShutting down...")
    daemon_task.cancel()
    try:
        await daemon_task
    except asyncio.CancelledError:
        pass


if __name__ == "__main__":
    asyncio.run(main())
