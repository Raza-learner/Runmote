import asyncio
import json
import signal
import sys
from config import RELAY_URL, AGENT_COMMAND, DAEMON_ID, RECONNECT_DELAY
from websockets.asyncio.client import connect


def log(msg: str):
    print(msg, flush=True)


async def run_daemon():
    proc = None
    while True:
        try:
            async with connect(RELAY_URL) as websocket:
                log("Connected to relay!")

                # Identify to the relay so sessions are tagged
                identify = json.dumps({
                    "jsonrpc": "2.0",
                    "method": "daemon/identify",
                    "params": {"daemonId": DAEMON_ID},
                })
                await websocket.send(identify)
                log(f"→ sent identify: {DAEMON_ID}")
                proc = await asyncio.create_subprocess_exec(
                    *AGENT_COMMAND,
                    stdin=asyncio.subprocess.PIPE,
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )

                async def relay_to_agent():
                    async for message in websocket:
                        log(f"relay → agent: {message}")
                        proc.stdin.write(message.encode() + b"\n")
                        await proc.stdin.drain()

                async def agent_to_relay():
                    async for line in proc.stdout:
                        message = line.decode().strip()
                        if message:
                            log(f"agent → relay: {message}")
                            await websocket.send(message)

                async def log_stderr():
                    async for line in proc.stderr:
                        if line:
                            print(f"agent stderr: {line.decode().strip()}", file=sys.stderr, flush=True)

                async def watch_agent():
                    await proc.wait()
                    log(f"Agent exited with code {proc.returncode}")

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
            log(f"Connection error: {e}")

        # kill stale agent before reconnecting
        if proc is not None and proc.returncode is None:
            log("Killing stale agent process...")
            proc.terminate()
            try:
                await asyncio.wait_for(proc.wait(), timeout=5)
            except asyncio.TimeoutError:
                proc.kill()
                await proc.wait()
            proc = None

        log(f"Reconnecting in {RECONNECT_DELAY}s...")
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

