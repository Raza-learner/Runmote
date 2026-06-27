import socket
from zeroconf.asyncio import AsyncZeroconf
from zeroconf import ServiceInfo


def _get_ip() -> str:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("10.255.255.255", 1))
        return s.getsockname()[0]
    except Exception:
        return "127.0.0.1"
    finally:
        s.close()


class RelayDiscovery:
    def __init__(self, port: int):
        self._port = port
        self._az: AsyncZeroconf | None = None

    async def start(self):
        ip = _get_ip()
        self._az = AsyncZeroconf()
        info = ServiceInfo(
            "_acp-relay._tcp.local.",
            f"ACP Relay on {ip}._acp-relay._tcp.local.",
            addresses=[socket.inet_aton(ip)],
            port=self._port,
            properties={},
        )
        await self._az.async_register_service(info, allow_name_change=True)
        print(f"mDNS: advertising _acp-relay._tcp on {ip}:{self._port}")

    async def stop(self):
        if self._az is not None:
            await self._az.async_close()
            self._az = None
