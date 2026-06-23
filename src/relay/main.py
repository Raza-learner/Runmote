import sys
from pathlib import Path
from contextlib import asynccontextmanager

# Add src/ to path so both relay and daemon can import common.*
_src = Path(__file__).resolve().parent.parent
if str(_src) not in sys.path:
    sys.path.insert(0, str(_src))

from fastapi import FastAPI  # noqa: E402
import uvicorn  # noqa: E402

try:
    from .config import HOST, PORT
    from .handlers.daemon import router as daemon_router
    from .handlers.app import router as app_router
    from .discovery import RelayDiscovery
except ImportError:
    from config import HOST, PORT
    from handlers.daemon import router as daemon_router
    from handlers.app import router as app_router
    from discovery import RelayDiscovery

_discovery = RelayDiscovery(PORT)


@asynccontextmanager
async def lifespan(app: FastAPI):
    await _discovery.start()
    yield
    await _discovery.stop()


app = FastAPI(lifespan=lifespan)
app.include_router(daemon_router)
app.include_router(app_router)

if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT)
