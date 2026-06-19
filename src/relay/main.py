from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import asyncio
import json
import uvicorn
from config import HOST, PORT

app = FastAPI()

daemon_websocket: WebSocket | None = None
app_clients: set[WebSocket] = set()


@app.websocket("/daemon")
async def daemon_endpoint(websocket: WebSocket):
    global daemon_websocket
    await websocket.accept()
    daemon_websocket = websocket
    print("Daemon connected!")

    try:
        async for message in websocket.iter_text():
            print(f"daemon → relay: {message[:120]}")
            # broadcast to all app clients
            for client in list(app_clients):
                try:
                    await client.send_text(message)
                except Exception:
                    app_clients.discard(client)
    except WebSocketDisconnect:
        daemon_websocket = None
        print("Daemon disconnected!")


@app.websocket("/app")
async def app_endpoint(websocket: WebSocket):
    await websocket.accept()
    app_clients.add(websocket)
    print("Client connected!")

    try:
        async for message in websocket.iter_text():
            print(f"client → daemon: {message[:120]}")

            if daemon_websocket is None:
                await websocket.send_text('{"error": "daemon not connected"}')
                continue

            await daemon_websocket.send_text(message)
    except WebSocketDisconnect:
        app_clients.discard(websocket)
        print("Client disconnected!")


if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT)
