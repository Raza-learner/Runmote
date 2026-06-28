import asyncio
import os
import shutil
from typing import Any, Optional

from acp import (
    PROTOCOL_VERSION,
    Agent,
    run_agent,
)
from acp.interfaces import Client as ClientProto
from acp.schema import (
    AudioContentBlock,
    ClientCapabilities,
    EmbeddedResourceContentBlock,
    HttpMcpServer,
    ImageContentBlock,
    Implementation,
    McpServerStdio,
    ResourceContentBlock,
    SseMcpServer,
    TextContentBlock,
    LoadSessionResponse,
    ListSessionsResponse,
    ForkSessionResponse,
    ResumeSessionResponse,
    CloseSessionResponse,
    SetSessionModeResponse,
    SetSessionConfigOptionResponse,
    AuthenticateResponse,
    NewSessionResponse,
    PromptResponse,
    InitializeResponse,
)

from claude_daemon import log
from claude_daemon.bridge import (
    BridgeClient,
    BridgeConfig,
    NativeClaudeBridge,
    detect_bridges,
    start_bridge,
    stop_bridge,
    configure as configure_bridge,
    resolve_permission,
)


class ClaudeCodeAgent(Agent):
    def __init__(self):
        self._daemon_conn: Optional[ClientProto] = None
        self._bridge_proc: Optional[asyncio.subprocess.Process] = None
        self._bridge_conn: Any = None
        self._bridge_client: Optional[BridgeClient] = None
        self._native_bridge: Optional[NativeClaudeBridge] = None
        self._bridge_config: Optional[BridgeConfig] = None
        self._bridge_stderr_task: Optional[asyncio.Task] = None
        self._is_native: bool = False
        self._cwd: str = os.environ.get("CLAUDE_CWD", os.path.expanduser("~"))

    def on_connect(self, conn: ClientProto) -> None:
        self._daemon_conn = conn
        if self._bridge_client:
            self._bridge_client.set_daemon_conn(conn)
        if self._native_bridge:
            self._native_bridge.set_daemon_conn(conn)
        log.info("Connected to daemon")

    async def initialize(
        self,
        protocol_version: int,
        client_capabilities: Optional[ClientCapabilities] = None,
        client_info: Optional[Implementation] = None,
        **kwargs: Any,
    ) -> InitializeResponse:
        bridges = detect_bridges()
        if not bridges:
            msg = (
                "No ACP bridge found. Install one of:\n"
                "  pip install claude-code-acp\n"
                "  npm install -g @agentclientprotocol/claude-agent-acp\n"
                "  (or install the 'claude' CLI binary)"
            )
            log.error(msg)
            raise RuntimeError(msg)

        last_error = None
        for cfg in bridges:
            if cfg.native:
                log.info(f"Using native claude bridge: {cfg.name}", source=cfg.source)
                self._bridge_config = cfg
                self._is_native = True
                self._native_bridge = NativeClaudeBridge(self._daemon_conn)
                return await self._native_bridge.initialize(
                    protocol_version=PROTOCOL_VERSION,
                    client_capabilities=client_capabilities,
                    client_info=client_info,
                )

            try:
                self._bridge_config = cfg
                self._bridge_proc, self._bridge_conn, self._bridge_client, self._bridge_stderr_task = await start_bridge(cfg, self._cwd)
                log.info(f"Using bridge: {cfg.name}", source=cfg.source)

                init_resp = await self._bridge_conn.initialize(
                    protocol_version=PROTOCOL_VERSION,
                    client_capabilities=client_capabilities,
                    client_info=client_info,
                )
                return InitializeResponse(
                    protocol_version=init_resp.protocol_version,
                )
            except Exception as e:
                last_error = e
                log.warn(f"Bridge '{cfg.name}' failed: {e}")
                if self._bridge_proc:
                    await stop_bridge(self._bridge_proc)
                self._bridge_proc = None
                self._bridge_conn = None
                self._bridge_client = None
                self._bridge_stderr_task = None
                continue

        # If no bridges at all and native claude exists, use it
        if shutil.which("claude"):
            log.info("Falling back to native claude")
            self._is_native = True
            self._native_bridge = NativeClaudeBridge(self._daemon_conn)
            return await self._native_bridge.initialize(
                protocol_version=PROTOCOL_VERSION,
                client_capabilities=client_capabilities,
                client_info=client_info,
            )

        msg = f"All bridges failed. Last error: {last_error}"
        log.error(msg)
        raise RuntimeError(msg)

    def _get_bridge(self):
        return self._native_bridge if self._is_native else self._bridge_conn

    async def new_session(
        self,
        cwd: str,
        additional_directories: Optional[list[str]] = None,
        mcp_servers: Optional[list[HttpMcpServer | SseMcpServer | McpServerStdio]] = None,
        **kwargs: Any,
    ) -> NewSessionResponse:
        bridge = self._get_bridge()
        if not bridge:
            raise RuntimeError("Bridge not initialized")
        if self._is_native:
            return await self._native_bridge.new_session(cwd=cwd)
        return await bridge.new_session(
            cwd=cwd,
            additional_directories=additional_directories,
            mcp_servers=mcp_servers,
        )

    async def prompt(
        self,
        prompt: list[
            TextContentBlock
            | ImageContentBlock
            | AudioContentBlock
            | ResourceContentBlock
            | EmbeddedResourceContentBlock
        ],
        session_id: str,
        **kwargs: Any,
    ) -> PromptResponse:
        bridge = self._get_bridge()
        if not bridge:
            raise RuntimeError("Bridge not initialized")
        if self._is_native:
            return await self._native_bridge.prompt(prompt=prompt, session_id=session_id)
        return await bridge.prompt(
            prompt=prompt,
            session_id=session_id,
            message_id=kwargs.get("message_id"),
        )

    async def cancel(self, session_id: str, **kwargs: Any) -> None:
        if self._is_native:
            await self._native_bridge.cancel(session_id=session_id)
            return
        if self._bridge_conn:
            try:
                await self._bridge_conn.cancel(session_id=session_id)
            except Exception as e:
                log.warn("Cancel failed", session_id=session_id[:16], error=str(e))

    async def close_session(self, session_id: str, **kwargs: Any) -> Optional[CloseSessionResponse]:
        if self._is_native:
            await self._native_bridge.close_session(session_id=session_id)
            return CloseSessionResponse()
        if self._bridge_conn:
            try:
                return await self._bridge_conn.close_session(session_id=session_id)
            except Exception as e:
                log.warn("close_session failed", session_id=session_id[:16], error=str(e))
        return None

    async def load_session(
        self,
        cwd: str,
        session_id: str,
        additional_directories: Optional[list[str]] = None,
        mcp_servers: Optional[list[HttpMcpServer | SseMcpServer | McpServerStdio]] = None,
        **kwargs: Any,
    ) -> Optional[LoadSessionResponse]:
        if self._is_native:
            return await self._native_bridge.load_session(session_id=session_id, cwd=cwd)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.load_session(
                    cwd=cwd,
                    session_id=session_id,
                    additional_directories=additional_directories,
                    mcp_servers=mcp_servers,
                )
            except Exception as e:
                log.warn("load_session failed", session_id=session_id[:16], error=str(e))
        return None

    async def list_sessions(
        self,
        cursor: Optional[str] = None,
        cwd: Optional[str] = None,
        **kwargs: Any,
    ) -> ListSessionsResponse:
        if self._is_native:
            return await self._native_bridge.list_sessions()
        if self._bridge_conn:
            try:
                return await self._bridge_conn.list_sessions(cursor=cursor, cwd=cwd)
            except Exception as e:
                log.warn("list_sessions failed", error=str(e))
        return ListSessionsResponse(sessions=[])

    async def fork_session(
        self,
        cwd: str,
        session_id: str,
        additional_directories: Optional[list[str]] = None,
        mcp_servers: Optional[list[HttpMcpServer | SseMcpServer | McpServerStdio]] = None,
        **kwargs: Any,
    ) -> ForkSessionResponse:
        if self._is_native:
            return await self._native_bridge.fork_session(**kwargs)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.fork_session(
                    cwd=cwd,
                    session_id=session_id,
                    additional_directories=additional_directories,
                    mcp_servers=mcp_servers,
                )
            except Exception as e:
                log.warn("fork_session failed", session_id=session_id[:16], error=str(e))
        raise RuntimeError("Bridge not initialized")

    async def resume_session(
        self,
        cwd: str,
        session_id: str,
        additional_directories: Optional[list[str]] = None,
        mcp_servers: Optional[list[HttpMcpServer | SseMcpServer | McpServerStdio]] = None,
        **kwargs: Any,
    ) -> ResumeSessionResponse:
        if self._is_native:
            return await self._native_bridge.resume_session(**kwargs)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.resume_session(
                    cwd=cwd,
                    session_id=session_id,
                    additional_directories=additional_directories,
                    mcp_servers=mcp_servers,
                )
            except Exception as e:
                log.warn("resume_session failed", session_id=session_id[:16], error=str(e))
        raise RuntimeError("Bridge not initialized")

    async def set_session_mode(self, mode_id: str, session_id: str, **kwargs: Any) -> Optional[SetSessionModeResponse]:
        if self._is_native:
            return await self._native_bridge.set_session_mode(**kwargs)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.set_session_mode(mode_id=mode_id, session_id=session_id)
            except Exception as e:
                log.warn("set_session_mode failed", session_id=session_id[:16], error=str(e))
        return None

    async def set_config_option(self, config_id: str, session_id: str, value: str | bool, **kwargs: Any) -> Optional[SetSessionConfigOptionResponse]:
        if self._is_native:
            return await self._native_bridge.set_config_option(**kwargs)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.set_config_option(config_id=config_id, session_id=session_id, value=value)
            except Exception as e:
                log.warn("set_config_option failed", session_id=session_id[:16], error=str(e))
        return None

    async def authenticate(self, method_id: str, **kwargs: Any) -> Optional[AuthenticateResponse]:
        if self._is_native:
            return await self._native_bridge.authenticate(**kwargs)
        if self._bridge_conn:
            try:
                return await self._bridge_conn.authenticate(method_id=method_id)
            except Exception as e:
                log.warn("authenticate failed", method_id=method_id, error=str(e))
        return None

    async def ext_method(self, method: str, params: dict[str, Any]) -> dict[str, Any]:
        log.debug("ext_method", method=method)
        if method == "permission/response":
            permission_id = params.get("permissionId", "")
            option_id = params.get("optionId", "")
            if permission_id and option_id:
                resolve_permission(permission_id, option_id)
                return {"ok": True}
        return {}

    async def ext_notification(self, method: str, params: dict[str, Any]) -> None:
        log.debug("ext_notification", method=method)
        if method == "permission/response":
            permission_id = params.get("permissionId", "")
            option_id = params.get("optionId", "")
            if permission_id and option_id:
                resolve_permission(permission_id, option_id)

    async def shutdown_bridge(self):
        if self._is_native and self._native_bridge:
            await self._native_bridge.close()
            self._native_bridge = None
            return
        if self._bridge_stderr_task and not self._bridge_stderr_task.done():
            self._bridge_stderr_task.cancel()
            try:
                await self._bridge_stderr_task
            except (asyncio.CancelledError, Exception):
                pass
            self._bridge_stderr_task = None
        if self._bridge_conn:
            try:
                await self._bridge_conn.close()
            except Exception:
                pass
            self._bridge_conn = None
        if self._bridge_proc:
            await stop_bridge(self._bridge_proc)
            self._bridge_proc = None


async def async_main(debug: bool = False, auto_approve: bool = False, permission_timeout: int = 60):
    log.configure(debug=debug)
    configure_bridge(auto_approve=auto_approve, permission_timeout=permission_timeout)

    agent = ClaudeCodeAgent()
    try:
        await run_agent(agent, use_unstable_protocol=True)
    finally:
        await agent.shutdown_bridge()


def main():
    import signal

    debug = os.environ.get("DEBUG", "").lower() in ("1", "true", "yes")
    auto_approve = os.environ.get("ACP_AUTO_APPROVE", "").lower() in ("1", "true", "yes")
    permission_timeout = int(os.environ.get("ACP_PERMISSION_TIMEOUT", "60"))

    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    shutdown = asyncio.Event()

    for sig in (signal.SIGINT, signal.SIGTERM):
        try:
            loop.add_signal_handler(sig, shutdown.set)
        except (NotImplementedError, ValueError):
            pass

    async def run_until_shutdown():
        main_task = asyncio.create_task(async_main(
            debug=debug,
            auto_approve=auto_approve,
            permission_timeout=permission_timeout,
        ))
        await shutdown.wait()
        main_task.cancel()
        try:
            await main_task
        except asyncio.CancelledError:
            pass

    try:
        loop.run_until_complete(run_until_shutdown())
    except KeyboardInterrupt:
        pass
    finally:
        loop.close()
