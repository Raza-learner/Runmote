import asyncio
from websockets.asyncio.server import serve

# store the daemon connection when it connects
daemon_websocket = None


async def handler(websocket):
    global daemon_websocket

    # first connection = daemon, second = app/test client
    if daemon_websocket is None:
        daemon_websocket = websocket
        print("Daemon connected!")
        await websocket.wait_closed()
        daemon_websocket = None
        print("Daemon disconnected")
    else:
        print("Client connected!")
        async for message in websocket:
            print(f"client → daemon: {message}")
            if daemon_websocket:
                await daemon_websocket.send(message)
                response = await daemon_websocket.recv()
                print(f"daemon → client: {response}")
                await websocket.send(response)


async def main():
    async with serve(handler, "localhost", 8765) as server:
        print("Relay running on ws://localhost:8765")
        await server.serve_forever()


asyncio.run(main())
