# test_client.py
import asyncio
from websockets.asyncio.client import connect


async def main():
    async with connect("ws://localhost:8000/app") as ws:
        # ACP initialize message
        msg = '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":1}}'
        print(f"sending: {msg}")
        await ws.send(msg)
        response = await ws.recv()
        print(f"response: {response}")


asyncio.run(main())
