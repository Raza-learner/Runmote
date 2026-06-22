import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

try:
    from .. import state
except ImportError:
    import state

router = APIRouter()


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

                if method == "daemon/identify":
                    daemon_id = (data.get("params") or {}).get("daemonId", "unknown")
                    state.store.set_daemon_id(daemon_id)
                    print(f"  → daemon identified as {daemon_id}")
                    continue

                result = data.get("result")
                if isinstance(result, dict) and "sessionId" in result:
                    state.store.register(result["sessionId"])
                    print(f"  → registered session {result['sessionId'][:20]}...")

                error = data.get("error")
                if isinstance(error, dict):
                    sid = (error.get("data") or {}).get("sessionId")
                    if sid:
                        state.store.remove(sid)
                        print(f"  → removed session {sid[:20]}...")
            except json.JSONDecodeError:
                pass

            for client_id, client in list(state.app_clients.items()):
                try:
                    await client.send_text(message)
                except Exception:
                    state.app_clients.pop(client_id, None)

    except WebSocketDisconnect:
        state.daemon_websocket = None
        print("Daemon disconnected!")
