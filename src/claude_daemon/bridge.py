import asyncio
import json
import os
import shutil
import time
from dataclasses import dataclass, field
from typing import Any, Optional

from acp import Client, connect_to_agent
from acp.core import DEFAULT_STDIO_BUFFER_LIMIT_BYTES
from acp.interfaces import Agent as AgentProto
from acp.schema import (
    AllowedOutcome,
    CreateTerminalResponse,
    DeniedOutcome,
    EnvVariable,
    PermissionOption,
    ReadTextFileResponse,
    ReleaseTerminalResponse,
    RequestPermissionResponse,
    KillTerminalResponse,
    ToolCallUpdate,
    WriteTextFileResponse,
)

from acp import update_agent_message_text

from claude_daemon import log


@dataclass
class BridgeConfig:
    command: list[str] = field(default_factory=list)
    name: str = ""
    source: str = ""
    native: bool = False  # True for native claude (no ACP bridge)


_PENDING_PERMISSIONS: dict[str, asyncio.Future] = {}
_auto_approve = False
_permission_timeout = 60


def configure(auto_approve: bool = False, permission_timeout: int = 60):
    global _auto_approve, _permission_timeout
    _auto_approve = auto_approve
    _permission_timeout = permission_timeout


def detect_bridges() -> list[BridgeConfig]:
    bridges = []

    raw = os.environ.get("ACP_BRIDGE_BIN", "")
    if raw:
        bridges.append(BridgeConfig(
            command=raw.split(),
            name=f"custom ({raw})",
            source="env",
        ))
        return bridges

    if shutil.which("claude-code-acp"):
        bridges.append(BridgeConfig(
            command=["claude-code-acp"],
            name="claude-code-acp",
            source="pip install claude-code-acp",
        ))

    if shutil.which("claude-agent-acp"):
        bridges.append(BridgeConfig(
            command=["claude-agent-acp"],
            name="claude-agent-acp",
            source="npm / pre-built binary",
        ))

    # native claude — last resort, uses -p mode (no ACP, basic text)
    if shutil.which("claude"):
        bridges.append(BridgeConfig(
            command=["claude"],
            name="claude (native)",
            source="native claude CLI",
            native=True,
        ))

    return bridges


def resolve_permission(permission_id: str, option_id: str):
    future = _PENDING_PERMISSIONS.pop(permission_id, None)
    if future and not future.done():
        future.set_result(option_id)


class BridgeClient(Client):
    def __init__(self, daemon_conn: Optional[AgentProto] = None):
        self._daemon_conn = daemon_conn

    def set_daemon_conn(self, daemon_conn: AgentProto):
        self._daemon_conn = daemon_conn

    async def session_update(self, session_id: str, update: Any, **kwargs: Any) -> None:
        log.debug("session_update", session_id=session_id[:16], type=type(update).__name__)
        if self._daemon_conn:
            try:
                await self._daemon_conn.ext_notification("session/update", {
                    "sessionId": session_id,
                    "update": update,
                })
            except Exception as e:
                log.warn("Failed to forward session_update", error=str(e))

    async def request_permission(
        self,
        options: list[PermissionOption],
        session_id: str,
        tool_call: ToolCallUpdate,
        **kwargs: Any,
    ) -> RequestPermissionResponse:
        if _auto_approve:
            for opt in options:
                if opt.kind in {"allow_once", "allow_always"}:
                    return RequestPermissionResponse(
                        outcome=AllowedOutcome(option_id=opt.option_id, outcome="selected")
                    )
            if options:
                return RequestPermissionResponse(
                    outcome=AllowedOutcome(option_id=options[0].option_id, outcome="selected")
                )
            return RequestPermissionResponse(outcome=DeniedOutcome(outcome="cancelled"))

        permission_id = f"perm_{id(options)}"
        future = asyncio.get_event_loop().create_future()
        _PENDING_PERMISSIONS[permission_id] = future

        log.info("Permission requested", session_id=session_id[:16], tool=tool_call.title, pid=permission_id)

        if self._daemon_conn:
            try:
                await self._daemon_conn.ext_notification("session/request_permission", {
                    "sessionId": session_id,
                    "permissionId": permission_id,
                    "options": [
                        {"optionId": o.option_id, "name": o.name, "kind": o.kind}
                        for o in options
                    ],
                    "toolCall": {
                        "toolCallId": tool_call.tool_call_id,
                        "title": tool_call.title,
                    },
                })
            except Exception as e:
                log.warn("Failed to forward permission request", error=str(e))

        try:
            chosen = await asyncio.wait_for(future, timeout=_permission_timeout)
            return RequestPermissionResponse(
                outcome=AllowedOutcome(option_id=chosen, outcome="selected")
            )
        except asyncio.TimeoutError:
            log.warn("Permission timeout, denying", permission_id=permission_id)
            return RequestPermissionResponse(outcome=DeniedOutcome(outcome="cancelled"))
        except Exception as e:
            log.warn("Permission error, denying", permission_id=permission_id, error=str(e))
            return RequestPermissionResponse(outcome=DeniedOutcome(outcome="cancelled"))

    async def read_text_file(self, path: str, session_id: str, limit: Optional[int] = None, line: Optional[int] = None, **kwargs: Any) -> ReadTextFileResponse:
        log.debug("read_text_file", path=path, session_id=session_id[:16])
        return ReadTextFileResponse(content="")

    async def write_text_file(self, content: str, path: str, session_id: str, **kwargs: Any) -> Optional[WriteTextFileResponse]:
        log.debug("write_text_file", path=path, session_id=session_id[:16])
        return WriteTextFileResponse()

    async def create_terminal(self, command: str, session_id: str, args: Optional[list[str]] = None, cwd: Optional[str] = None, env: Optional[list[EnvVariable]] = None, output_byte_limit: Optional[int] = None, **kwargs: Any) -> CreateTerminalResponse:
        log.debug("create_terminal", command=command, session_id=session_id[:16])
        return CreateTerminalResponse(terminal_id="")

    async def terminal_output(self, session_id: str, terminal_id: str, **kwargs: Any) -> Any:
        log.debug("terminal_output", terminal_id=terminal_id, session_id=session_id[:16])
        return type("Resp", (), {"content": ""})()

    async def release_terminal(self, session_id: str, terminal_id: str, **kwargs: Any) -> Optional[ReleaseTerminalResponse]:
        log.debug("release_terminal", terminal_id=terminal_id, session_id=session_id[:16])
        return None

    async def wait_for_terminal_exit(self, session_id: str, terminal_id: str, **kwargs: Any) -> Any:
        log.debug("wait_for_terminal_exit", terminal_id=terminal_id, session_id=session_id[:16])
        return type("Resp", (), {"exit_code": 0})()

    async def kill_terminal(self, session_id: str, terminal_id: str, **kwargs: Any) -> Optional[KillTerminalResponse]:
        log.debug("kill_terminal", terminal_id=terminal_id, session_id=session_id[:16])
        return None

    async def ext_method(self, method: str, params: dict[str, Any]) -> dict[str, Any]:
        return {}

    async def ext_notification(self, method: str, params: dict[str, Any]) -> None:
        log.debug("ext_notification", method=method)

    def on_connect(self, conn: AgentProto) -> None:
        pass


@dataclass
class SessionData:
    acp_session_id: str
    cwd: str
    claude_session_id: str = ""
    model: str = ""
    messages: list[dict] = field(default_factory=list)
    created_at: float = 0.0


class NativeClaudeBridge:
    def __init__(self, daemon_conn: Optional[AgentProto] = None):
        self._daemon_conn = daemon_conn
        self._proc: Optional[asyncio.subprocess.Process] = None
        self._sessions: dict[str, SessionData] = {}

    def set_daemon_conn(self, daemon_conn: AgentProto):
        self._daemon_conn = daemon_conn

    async def initialize(self, protocol_version: int = 1, **kwargs) -> Any:
        from acp.schema import InitializeResponse
        return InitializeResponse(protocol_version=protocol_version)

    async def new_session(self, cwd: str = "", **kwargs) -> Any:
        from uuid import uuid4
        from acp.schema import NewSessionResponse
        acp_id = uuid4().hex
        self._sessions[acp_id] = SessionData(
            acp_session_id=acp_id,
            cwd=cwd or os.environ.get("CLAUDE_CWD", os.path.expanduser("~")),
            created_at=time.time(),
        )
        return NewSessionResponse(session_id=acp_id)

    async def close(self):
        await self._stop_claude()

    async def _run_claude(self, args: list[str], timeout: int = 300) -> tuple[bytes, bytes, int]:
        self._proc = await asyncio.create_subprocess_exec(
            "claude", *args,
            stdin=asyncio.subprocess.DEVNULL,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )
        try:
            stdout_data, stderr_data = await asyncio.wait_for(
                self._proc.communicate(), timeout=timeout,
            )
            return stdout_data or b"", stderr_data or b"", self._proc.returncode or 0
        except asyncio.TimeoutError:
            self._proc.kill()
            await self._proc.wait()
            return b"", b"", -1
        finally:
            self._proc = None

    async def _run_claude_stream(
        self, args: list[str], session_id: str, timeout: int = 300,
    ) -> tuple[str, str, str]:
        """Run claude with stream-json output, forwarding chunks to the daemon."""
        log.info("Running claude (stream)", session_id=session_id[:16])

        self._proc = await asyncio.create_subprocess_exec(
            "claude", *args,
            stdin=asyncio.subprocess.DEVNULL,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE,
        )

        result_text = ""
        claude_session_id = ""
        final_model = ""

        stdout_lines: list[str] = []
        stderr_buf = b""

        try:
            while True:
                line = await asyncio.wait_for(
                    self._proc.stdout.readline(), timeout=timeout,
                )
                if not line:
                    break
                raw = line.decode(errors="replace").strip()
                if not raw:
                    continue
                stdout_lines.append(raw)
                try:
                    data = json.loads(raw)
                except json.JSONDecodeError:
                    continue

                evt = data.get("type", "")

                if evt == "system":
                    sub = data.get("subtype", "")
                    if sub == "init":
                        claude_session_id = data.get("session_id", "") or data.get("sessionId", "") or ""
                        final_model = data.get("model", "") or ""

                elif evt == "text":
                    text = data.get("text", "")
                    if text:
                        result_text += text
                        if self._daemon_conn:
                            chunk = update_agent_message_text(text)
                            try:
                                await self._daemon_conn.session_update(
                                    session_id=session_id, update=chunk,
                                )
                            except Exception:
                                pass

                elif evt == "assistant":
                    msg = data.get("message") or {}
                    content = msg.get("content") or []
                    error = data.get("error", "")
                    is_auth_error = error == "authentication_failed"
                    for block in content:
                        if isinstance(block, dict):
                            btype = block.get("type", "")
                            if btype == "text":
                                text = block.get("text", "")
                                if text and not is_auth_error:
                                    result_text += text
                                    if self._daemon_conn:
                                        chunk = update_agent_message_text(text)
                                        try:
                                            await self._daemon_conn.session_update(
                                                session_id=session_id, update=chunk,
                                            )
                                        except Exception:
                                            pass
                            elif btype == "tool_use":
                                name = block.get("name", "")
                                inp = block.get("input", {})
                                tid = block.get("id", "") or block.get("tool_use_id", "") or ""
                                if not tid:
                                    import uuid
                                    tid = uuid.uuid4().hex[:12]
                                if self._daemon_conn:
                                    try:
                                        await self._daemon_conn.ext_notification("session/update", {
                                            "sessionId": session_id,
                                            "update": {
                                                "sessionUpdate": "tool_call",
                                                "toolCallId": tid,
                                                "title": name,
                                                "content": [{"type": "text", "text": json.dumps(inp) if isinstance(inp, dict) else str(inp)}],
                                            },
                                        })
                                    except Exception:
                                        pass

                elif evt == "tool_result":
                    tid = data.get("tool_use_id", "")
                    content = data.get("content", [])
                    out_text = ""
                    for block in content if isinstance(content, list) else [content]:
                        if isinstance(block, dict):
                            out_text += block.get("text", "") or block.get("content", "") or ""
                        else:
                            out_text += str(block)
                    if self._daemon_conn:
                        try:
                            await self._daemon_conn.ext_notification("session/update", {
                                "sessionId": session_id,
                                "update": {
                                    "sessionUpdate": "tool_call_update",
                                    "toolCallId": tid,
                                    "status": "completed",
                                    "content": [{"type": "text", "text": out_text}],
                                },
                            })
                        except Exception:
                            pass

                elif evt == "result":
                    claude_session_id = data.get("session_id", "") or data.get("sessionId", "") or claude_session_id
                    if data.get("is_error"):
                        err_result = data.get("result", "") or ""
                        if "not logged in" in err_result.lower():
                            result_text = ""
                            claude_session_id = ""
                    break

        except asyncio.TimeoutError:
            log.warn("claude stream timed out", session_id=session_id[:16])
        except asyncio.CancelledError:
            self._proc.kill()
            raise
        finally:
            remaining_stdout, stderr_buf = await self._proc.communicate()
            if stderr_buf:
                for line in stderr_buf.decode(errors="replace").split("\n"):
                    if line.strip():
                        log.info("claude stderr: " + line.strip(), session_id=session_id[:16])
            self._proc = None

        if claude_session_id:
            session = self._sessions.get(session_id)
            if session:
                session.claude_session_id = claude_session_id
                if final_model:
                    session.model = final_model

        return result_text, claude_session_id, final_model

    async def prompt(self, prompt: list, session_id: str, **kwargs) -> Any:
        from acp.schema import PromptResponse

        text_parts = []
        for block in prompt:
            if isinstance(block, dict):
                text_parts.append(block.get("text", ""))
            else:
                text_parts.append(getattr(block, "text", ""))
        prompt_text = "\n".join(text_parts)

        session = self._sessions.get(session_id)

        # Build claude args — stream-json with verbose for full event stream
        base = ["-p", prompt_text, "--output-format", "stream-json", "--verbose"]
        if self._daemon_conn:
            base.append("--include-partial-messages")
        args = list(base)
        if session and session.claude_session_id:
            args = ["-c", "--session", session.claude_session_id] + base

        result_text, claude_session_id, final_model = await self._run_claude_stream(args, session_id)

        # If stream-json produced no useful output (empty/error), use json as fallback
        if not result_text and not claude_session_id:
            log.info("stream-json empty, falling back to json", session_id=session_id[:16])
            base2 = ["-p", prompt_text, "--output-format", "json"]
            args2 = list(base2)
            if session and session.claude_session_id:
                args2 = ["-c", "--session", session.claude_session_id] + base2
            stdout_data, stderr_data, _ = await self._run_claude(args2)
            raw = stdout_data.decode(errors="replace").strip()
            if raw:
                try:
                    data = json.loads(raw)
                except json.JSONDecodeError:
                    data = None
                if data and data.get("type") == "result":
                    claude_session_id = data.get("session_id", "") or data.get("sessionId", "") or ""
                    if session and claude_session_id:
                        session.claude_session_id = claude_session_id
                    if data.get("is_error"):
                        err_result = data.get("result", "") or ""
                        if "not logged in" in err_result.lower():
                            msg = "⚠️ Claude Code requires login.\n\nPlease run  claude /login  in your terminal, then restart the connection."
                            result_text = msg
                            if self._daemon_conn:
                                chunk = update_agent_message_text(msg)
                                try:
                                    await self._daemon_conn.session_update(
                                        session_id=session_id, update=chunk,
                                    )
                                except Exception:
                                    pass
                        else:
                            result_text = err_result
                    else:
                        result_text = data.get("result", "") or result_text

        if result_text and session:
            session.messages.append({
                "role": "user",
                "content": prompt_text,
                "createdAt": int(time.time() * 1000),
            })
            session.messages.append({
                "role": "assistant",
                "content": result_text,
                "createdAt": int(time.time() * 1000),
            })

        if not result_text:
            msg = "⚠️ Claude Code is not responding.\n\nPossible causes:\n  • Not logged in — run  claude /login  in your terminal\n  • CLI not installed correctly\n\nCheck the daemon logs for details."
            result_text = msg
            if self._daemon_conn:
                chunk = update_agent_message_text(msg)
                try:
                    await self._daemon_conn.session_update(
                        session_id=session_id, update=chunk,
                    )
                except Exception:
                    pass

        log.info("claude prompt finished", session_id=session_id[:16])
        return PromptResponse(stop_reason="end_turn")

    async def load_session(self, session_id: str, **kwargs) -> Any:
        from acp.schema import LoadSessionResponse
        session = self._sessions.get(session_id)
        if not session:
            return LoadSessionResponse(messages=[])
        return LoadSessionResponse(messages=session.messages)

    async def list_sessions(self, **kwargs) -> Any:
        from acp.schema import ListSessionsResponse, SessionInfo
        import datetime
        sessions_list = [
            SessionInfo(
                session_id=s.acp_session_id,
                cwd=s.cwd,
                updated_at=datetime.datetime.fromtimestamp(s.created_at or time.time(), tz=datetime.timezone.utc).isoformat(),
            )
            for s in self._sessions.values()
        ]
        return ListSessionsResponse(sessions=sessions_list)

    async def cancel(self, session_id: str = "", **kwargs):
        await self._stop_claude()

    async def close_session(self, session_id: str = "", **kwargs):
        from acp.schema import CloseSessionResponse
        self._sessions.pop(session_id, None)
        await self._stop_claude()
        return CloseSessionResponse()

    async def _stop_claude(self):
        if self._proc and self._proc.returncode is None:
            log.info("Stopping claude process", pid=self._proc.pid)
            self._proc.terminate()
            try:
                await asyncio.wait_for(self._proc.wait(), timeout=5)
            except asyncio.TimeoutError:
                self._proc.kill()
                await self._proc.wait()
            self._proc = None

    async def fork_session(self, **kwargs) -> Any:
        raise RuntimeError("not supported in native mode")

    async def resume_session(self, **kwargs) -> Any:
        raise RuntimeError("not supported in native mode")

    async def set_session_mode(self, **kwargs) -> Any:
        return None

    async def set_config_option(self, config_id: str, value: str, session_id: str, **kwargs) -> Any:
        return None

    async def authenticate(self, **kwargs) -> Any:
        return None


async def _log_stderr(proc: asyncio.subprocess.Process):
    if not proc.stderr:
        return
    try:
        async for line in proc.stderr:
            text = line.decode(errors="replace").rstrip()
            if text:
                log.debug(f"[bridge-stderr] {text}")
    except Exception:
        pass


async def start_bridge(config: BridgeConfig, cwd: str) -> tuple[asyncio.subprocess.Process, Any, BridgeClient, asyncio.Task]:
    log.info(f"Starting bridge: {config.name}", command=" ".join(config.command), cwd=cwd)

    proc = await asyncio.create_subprocess_exec(
        *config.command,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
        cwd=cwd,
        limit=DEFAULT_STDIO_BUFFER_LIMIT_BYTES,
    )

    log.info("Bridge process started", pid=proc.pid)

    stderr_task = asyncio.create_task(_log_stderr(proc))

    bridge_client = BridgeClient()
    conn = connect_to_agent(bridge_client, proc.stdin, proc.stdout)
    bridge_client.on_connect(conn)

    return proc, conn, bridge_client, stderr_task


async def stop_bridge(proc: asyncio.subprocess.Process) -> None:
    if proc.returncode is not None:
        return
    log.info("Stopping bridge process", pid=proc.pid)
    proc.terminate()
    try:
        await asyncio.wait_for(proc.wait(), timeout=5)
    except asyncio.TimeoutError:
        proc.kill()
        await proc.wait()
