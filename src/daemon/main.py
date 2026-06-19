import asyncio
import signal
import sys
from config import RELAY_URL, AGENT_COMMAND, RECONNECT_DELAY
from websockets.asyncio.client import connect


async def run_daemon():
    while True:
        try:
            async with connect(RELAY_URL) as websocket:
                print("Connected to relay!")
                proc = await asyncio.create_subprocess_exec(
                    *AGENT_COMMAND,
                    stdin=asyncio.subprocess.PIPE,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )

                async def relay_to_agent():
                    async for message in websocket:
                        print(f"relay → agent: {message}")
                        proc.stdin.write(message.encode() + b"\n")
                        await proc.stdin.drain()

                async def agent_to_relay():
                    async for line in proc.stdout:
                        message = line.decode().strip()
                        if message:
                            print(f"agent → relay: {message}")
                            await websocket.send(message)

                async def log_stderr():
                    async for line in proc.stderr:
                        if line:
                            print(f"agent stderr: {line.decode().strip()}", file=sys.stderr)

                async def watch_agent():
                    await proc.wait()
                    print(f"Agent exited with code {proc.returncode}")

                tasks = [
                    asyncio.create_task(coro())
                    for coro in (relay_to_agent, agent_to_relay, log_stderr, watch_agent)
                ]
                done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
                for task in pending:
                    task.cancel()

        except asyncio.CancelledError:
            raise
        except Exception as e:
            print(f"Connection error: {e}")

        print(f"Reconnecting in {RECONNECT_DELAY}s...")
        await asyncio.sleep(RECONNECT_DELAY)


async def main():
    loop = asyncio.get_running_loop()
    stop = asyncio.Event()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, stop.set)

    daemon_task = asyncio.create_task(run_daemon())
    await stop.wait()
    print("\nShutting down...")
    daemon_task.cancel()
    try:
        await daemon_task
    except asyncio.CancelledError:
        pass


if __name__ == "__main__":
    asyncio.run(main())

