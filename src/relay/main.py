from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import asyncio

app = FastAPI()

daemon_websocket: WebSocket | None = None
response_queue: asyncio.Queue = asyncio.Queue()


@app.websocket("/daemon")
async def daemon_endpoint(websocket: WebSocket):
    global daemon_websocket
    await websocket.accept()
    daemon_websocket = websocket
    print("Daemon connected!")

    try:
        async for message in websocket.iter_text():
            print(f"daemon → relay: {message}")
            await response_queue.put(message)  # ← put response in queue
    except WebSocketDisconnect:
        daemon_websocket = None
        print("Daemon disconnected!")


@app.websocket("/app")
async def app_endpoint(websocket: WebSocket):
    await websocket.accept()
    print("Client connected!")

    try:
        async for message in websocket.iter_text():
            print(f"client → daemon: {message}")

            if daemon_websocket is None:
                await websocket.send_text('{"error": "daemon not connected"}')
                continue

            # forward to daemon
            await daemon_websocket.send_text(message)

            # wait for response from queue
            response = await response_queue.get()
            print(f"daemon → client: {response}")
            await websocket.send_text(response)

    except WebSocketDisconnect:
        print("Client disconnected!")