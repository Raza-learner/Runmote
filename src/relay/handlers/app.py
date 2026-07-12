import json
import time
import uuid
from collections import defaultdict
from fastapi import APIRouter, WebSocket

try:
    from .. import state
    from ..pairing import is_code_expired
except ImportError:
    import state
    from pairing import is_code_expired

router = APIRouter()

_PAIR_ATTEMPTS: dict[str, list[float]] = defaultdict(list)
_MAX_PAIR_ATTEMPTS = 5
_PAIR_WINDOW_SEC = 60


async def _send_error(ws: WebSocket, msg_id, code: int, message: str):
    await ws.send_text(json.dumps({
        "jsonrpc": "2.0",
        "id": msg_id,
        "error": {"code": code, "message": message},
    }))


def _get_daemon_ws(client_id: str) -> WebSocket | None:
    session = state.get_daemon_for_app(client_id)
    return session.websocket if session else None


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

                    params = data.get("params") or {}
                    code = params.get("code", "").strip().upper()
                    if is_code_expired(code):
                        state.code_to_daemon.pop(code, None)
                        state.claimed_codes.discard(code)
                        await _send_error(websocket, msg_id, -32002, "pairing code expired — generate a new one")
                        print(f"  → client {client_id} auth failed (expired code)", flush=True)
                        continue

                    attempts = _PAIR_ATTEMPTS[client_ip]
                    attempts[:] = [t for t in attempts if now - t < _PAIR_WINDOW_SEC]
                    if len(attempts) >= _MAX_PAIR_ATTEMPTS:
                        print(f"  → client {client_id} rate limited (IP: {client_ip})", flush=True)
                        await _send_error(websocket, msg_id, -32029, "too many attempts — try again later")
                        continue
                    attempts.append(now)

                    daemon_session = state.get_daemon_by_code(code)
                    if daemon_session is None:
                        await _send_error(websocket, msg_id, -32002, "invalid pairing code")
                        print(f"  → client {client_id} auth failed (invalid code)", flush=True)
                    else:
                        state.app_to_daemon[client_id] = daemon_session.daemon_id
                        daemon_session.paired_apps.add(client_id)
                        state.claimed_codes.add(code)
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {
                                "paired": True,
                                "daemonId": daemon_session.daemon_id,
                                "token": daemon_session.token,
                            },
                        }))
                        if daemon_session.daemon_id:
                            await websocket.send_text(json.dumps({
                                "jsonrpc": "2.0",
                                "method": "daemon/identified",
                                "params": {"daemonId": daemon_session.daemon_id},
                            }))
                        await daemon_session.websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "method": "pairing/complete",
                            "params": {"clientId": client_id},
                        }))
                        state.daemon_ever_paired.add(daemon_session.daemon_id)
                    continue

                if method == "auth/token":
                    params = data.get("params") or {}
                    token = params.get("token", "").strip()
                    daemon_id = state.get_daemon_id_by_token(token)
                    if daemon_id is not None:
                        state.app_to_daemon[client_id] = daemon_id
                        active = state.daemons.get(daemon_id)
                        if active:
                            active.paired_apps.add(client_id)
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {
                                "authenticated": True,
                                "daemonId": daemon_id,
                                "daemonConnected": active is not None,
                            },
                        }))
                    else:
                        await _send_error(websocket, msg_id, -32002, "invalid token")
                    continue

                daemon_ws = _get_daemon_ws(client_id)
                if daemon_ws is None:
                    await _send_error(websocket, msg_id, -32004, "daemon not connected")
                    continue

                if method == "daemon/status":
                    session = state.get_daemon_for_app(client_id)
                    await websocket.send_text(json.dumps({
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "result": {
                            "connected": session is not None,
                            "daemonId": session.daemon_id if session else state.store.get_daemon_id(),
                        },
                    }))
                    continue

                if method == "session/list":
                    await daemon_ws.send_text(message)
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
                    if sid:
                        close_params = {"sessionId": sid}
                        if agent_id:
                            close_params["agentId"] = agent_id
                        close_msg = json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "method": "session/close",
                            "params": close_params,
                        })
                        await daemon_ws.send_text(close_msg)
                    continue

            except json.JSONDecodeError:
                print(f"  → client {client_id} sent invalid JSON", flush=True)

            daemon_ws = _get_daemon_ws(client_id)
            if daemon_ws is None:
                await _send_error(websocket, None, -32004, "daemon not connected")
                continue

            try:
                await daemon_ws.send_text(message)
            except Exception as e:
                print(f"  → failed to forward to daemon: {e}", flush=True)
                await _send_error(websocket, None, -32005, f"daemon error: {e}")

    finally:
        state.app_clients.pop(client_id, None)
        did = state.app_to_daemon.pop(client_id, None)
        if did and did in state.daemons:
            state.daemons[did].paired_apps.discard(client_id)
        state.store.remove_client(client_id)
