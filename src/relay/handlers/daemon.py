import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

try:
    from .. import state
    from ..config import RELAY_TOKEN
    from ..pairing import generate_pairing_code
except ImportError:
    import state
    from config import RELAY_TOKEN
    from pairing import generate_pairing_code

router = APIRouter()


def _is_paired(client_id: str) -> bool:
    return RELAY_TOKEN is None or client_id in state.app_to_token


def _paired_clients():
    """Yield (client_id, websocket) for authenticated clients (or all when auth is off)."""
    for cid, ws in list(state.app_clients.items()):
        if RELAY_TOKEN is None or cid in state.app_to_token:
            yield cid, ws


@router.websocket("/daemon")
async def daemon_endpoint(websocket: WebSocket):
    await websocket.accept()
    state.daemon_websocket = websocket
    print("Daemon connected!")

    try:
        async for message in websocket.iter_text():
            print(f"daemon → relay: {message[:120]}")

            try:
                data = json.loads(message)
                method = data.get("method", "")
                msg_id = data.get("id")

                if method == "daemon/identify":
                    params = data.get("params") or {}
                    daemon_id = params.get("daemonId", "unknown")
                    token = params.get("token") or ""

                    if RELAY_TOKEN is not None and token != RELAY_TOKEN:
                        print(f"  → daemon token rejected (got '{token}')")
                        if msg_id:
                            await websocket.send_text(json.dumps({
                                "jsonrpc": "2.0",
                                "id": msg_id,
                                "error": {"code": -32001, "message": "invalid token"},
                            }))
                        await websocket.close()
                        return

                    pairing_code = generate_pairing_code()
                    state.token_to_daemons[token] = daemon_id
                    state.code_to_token[pairing_code] = token
                    state.store.set_daemon_id(daemon_id)
                    print(f"  → daemon identified as {daemon_id}")
                    print(f"  → pairing code: {pairing_code}")

                    if msg_id:
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {"pairingCode": pairing_code},
                        }))

                    forward = {
                        "jsonrpc": "2.0",
                        "method": "daemon/identified",
                        "params": {"daemonId": daemon_id},
                    }
                    for cid, client in _paired_clients():
                        try:
                            await client.send_text(json.dumps(forward))
                        except Exception:
                            state.app_clients.pop(cid, None)
                    continue

                result = data.get("result")
                if isinstance(result, dict):
                    if "sessionId" in result:
                        state.store.register(result["sessionId"])
                        print(f"  → registered session {result['sessionId'][:20]}...")
                    if "sessions" in result:
                        sessions = result["sessions"]
                        if isinstance(sessions, list):
                            for s in sessions:
                                if isinstance(s, dict):
                                    sid = s.get("sessionId", "")
                                    if sid:
                                        state.store.register(
                                            sid,
                                            client_id=s.get("clientId", ""),
                                            name=s.get("name", ""),
                                        )
                            print(f"  → synced {len(sessions)} sessions from opencode")

                error = data.get("error")
                if isinstance(error, dict):
                    sid = (error.get("data") or {}).get("sessionId")
                    if sid:
                        state.store.remove(sid)
                        print(f"  → removed session {sid[:20]}...")
            except json.JSONDecodeError:
                pass

            for cid, client in _paired_clients():
                try:
                    await client.send_text(message)
                except Exception:
                    state.app_clients.pop(cid, None)

    except WebSocketDisconnect:
        state.daemon_websocket = None
        state.store.clear_daemon_id()
        print("Daemon disconnected!")
        forward = {
            "jsonrpc": "2.0",
            "method": "daemon/disconnected",
            "params": {},
        }
        for cid, client in _paired_clients():
            try:
                await client.send_text(json.dumps(forward))
            except Exception:
                state.app_clients.pop(cid, None)
