import json
import uuid
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

try:
    from .. import state
except ImportError:
    import state

router = APIRouter()


@router.websocket("/app")
async def app_endpoint(websocket: WebSocket):
    await websocket.accept()
    client_id = str(uuid.uuid4())[:8]
    state.app_clients[client_id] = websocket
    print(f"Client {client_id} connected!")

    try:
        async for message in websocket.iter_text():
            print(f"client → daemon: {message[:120]}")

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

                if method == "session/list":
                    await websocket.send_text(json.dumps({
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "result": {"sessions": state.store.list_sessions()},
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
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "error": {"code": -32000, "message": "session not found"},
                        }))
                    continue

                if method == "session/delete":
                    sid = (data.get("params") or {}).get("sessionId")
                    if sid and state.store.get(sid):
                        state.store.remove(sid)
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {"sessionId": sid, "deleted": True},
                        }))
                    else:
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "error": {"code": -32000, "message": "session not found"},
                        }))
                    continue

            except json.JSONDecodeError:
                pass

            if state.daemon_websocket is None:
                await websocket.send_text('{"error": "daemon not connected"}')
                continue

            await state.daemon_websocket.send_text(message)

    except WebSocketDisconnect:
        state.app_clients.pop(client_id, None)
        state.store.remove_client(client_id)
        print(f"Client {client_id} disconnected!")
