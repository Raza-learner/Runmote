import json
import time
import uuid
from collections import defaultdict
from fastapi import APIRouter, WebSocket

try:
    from .. import state
    from ..config import RELAY_TOKEN
    from ..pairing import is_code_expired
except ImportError:
    import state
    from config import RELAY_TOKEN
    from pairing import is_code_expired

router = APIRouter()

# Per-IP pairing attempt tracking for rate limiting
_pair_attempts: dict[str, list[float]] = defaultdict(list)
_MAX_PAIR_ATTEMPTS = 5
_PAIR_WINDOW_SEC = 60


def _is_authenticated(client_id: str) -> bool:
    return RELAY_TOKEN is None or client_id in state.app_to_token


async def _send_error(ws: WebSocket, msg_id, code: int, message: str):
    await ws.send_text(json.dumps({
        "jsonrpc": "2.0",
        "id": msg_id,
        "error": {"code": code, "message": message},
    }))


async def _require_auth(ws: WebSocket, client_id: str, msg_id) -> bool:
    if not _is_authenticated(client_id):
        await _send_error(ws, msg_id, -32003, "not authenticated")
        return False
    return True


@router.websocket("/app")
async def app_endpoint(websocket: WebSocket):
    await websocket.accept()
    client_id = str(uuid.uuid4())[:8]
    state.app_clients[client_id] = websocket
    try:
        async for message in websocket.iter_text():

            try:
                data = json.loads(message)
                method = data.get("method", "")
                msg_id = data.get("id")

                if method == "$/ping":
                    await websocket.send_text(json.dumps({
                        "jsonrpc": "2.0",
                        "method": "$/pong",
                    }))
                    continue

                if method == "auth/pair":
                    client_ip = websocket.client.host if hasattr(websocket.client, 'host') else 'unknown'
                    now = time.time()
                    attempts = _pair_attempts[client_ip]
                    attempts[:] = [t for t in attempts if now - t < _PAIR_WINDOW_SEC]
                    if len(attempts) >= _MAX_PAIR_ATTEMPTS:
                        print(f"  → client {client_id} rate limited (IP: {client_ip})", flush=True)
                        await _send_error(websocket, msg_id, -32029, "too many attempts — try again later")
                        continue
                    attempts.append(now)

                    params = data.get("params") or {}
                    code = params.get("code", "").strip().upper()
                    if is_code_expired(code):
                        state.code_to_token.pop(code, None)
                        state.claimed_codes.discard(code)
                        await _send_error(websocket, msg_id, -32002, "pairing code expired — generate a new one")
                        print(f"  → client {client_id} auth failed (expired code)", flush=True)
                        continue
                    token = state.code_to_token.get(code)
                    if token is None:
                        await _send_error(websocket, msg_id, -32002, "invalid pairing code")
                        print(f"  → client {client_id} auth failed (invalid code)", flush=True)
                    else:
                        state.app_to_token[client_id] = token
                        state.claimed_codes.add(code)
                        daemon_id = state.token_to_daemons.get(token)
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {
                                "paired": True,
                                "daemonId": daemon_id,
                            },
                        }))
                        # Send current daemon status immediately after pairing
                        if daemon_id:
                            await websocket.send_text(json.dumps({
                                "jsonrpc": "2.0",
                                "method": "daemon/identified",
                                "params": {"daemonId": daemon_id},
                            }))
                    continue

                if not await _require_auth(websocket, client_id, msg_id):
                    continue

                if method == "daemon/status":
                    connected = state.daemon_websocket is not None
                    token = state.app_to_token.get(client_id)
                    daemon_id = state.token_to_daemons.get(token) if token else state.store.get_daemon_id()
                    await websocket.send_text(json.dumps({
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "result": {
                            "connected": connected,
                            "daemonId": daemon_id,
                        },
                    }))
                    continue

                if method == "session/list":
                    if state.daemon_websocket is not None:
                        await state.daemon_websocket.send_text(message)
                        continue

                    agent_id = (data.get("params") or {}).get("agentId", "")
                    sessions = state.store.list_sessions(agent_id)
                    await websocket.send_text(json.dumps({
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "result": {"sessions": sessions},
                    }))
                    continue

                if method == "session/rename":
                    sid = (data.get("params") or {}).get("sessionId")
                    name = (data.get("params") or {}).get("name", "")
                    if sid and state.store.rename(sid, name):
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {"sessionId": sid, "name": name},
                        }))
                    else:
                        await _send_error(websocket, msg_id, -32000, "session not found")
                    continue

                if method == "session/delete":
                    sid = (data.get("params") or {}).get("sessionId")
                    agent_id = (data.get("params") or {}).get("agentId")
                    if sid:
                        state.store.remove(sid, agent_id=agent_id or "")
                        state.recently_deleted_sessions.add(sid)
                    if state.daemon_websocket is not None and sid:
                        close_params = {"sessionId": sid}
                        if agent_id:
                            close_params["agentId"] = agent_id
                        close_msg = json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "method": "session/close",
                            "params": close_params,
                        })
                        await state.daemon_websocket.send_text(close_msg)
                    else:
                        if sid:
                            await websocket.send_text(json.dumps({
                                "jsonrpc": "2.0",
                                "id": msg_id,
                                "result": {"sessionId": sid, "deleted": True},
                            }))
                        else:
                            await _send_error(websocket, msg_id, -32000, "session not found")
                    continue

            except json.JSONDecodeError:
                print(f"  → client {client_id} sent invalid JSON", flush=True)

            if state.daemon_websocket is None:
                await _send_error(websocket, None, -32004, "daemon not connected")
                continue

            try:
                await state.daemon_websocket.send_text(message)
            except Exception as e:
                print(f"  → failed to forward to daemon: {e}", flush=True)
                await _send_error(websocket, None, -32005, f"daemon error: {e}")

    finally:
        state.app_clients.pop(client_id, None)
        state.app_to_token.pop(client_id, None)
        state.store.remove_client(client_id)
