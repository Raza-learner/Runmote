import sys
from pathlib import Path
from contextlib import asynccontextmanager

# Add src/ to path so both relay and daemon can import common.*
_src = Path(__file__).resolve().parent.parent
if str(_src) not in sys.path:
    sys.path.insert(0, str(_src))

from fastapi import FastAPI  # noqa: E402
from fastapi.middleware.cors import CORSMiddleware  # noqa: E402
from fastapi.responses import JSONResponse  # noqa: E402
import uvicorn  # noqa: E402

try:
    from .config import HOST, PORT, DISABLE_DISCOVERY, ALLOWED_ORIGINS
    from .handlers.daemon import router as daemon_router
    from .handlers.app import router as app_router
    from .discovery import RelayDiscovery
    from . import state
except ImportError:
    from config import HOST, PORT, DISABLE_DISCOVERY, ALLOWED_ORIGINS
    from handlers.daemon import router as daemon_router
    from handlers.app import router as app_router
    from discovery import RelayDiscovery
    import state

_discovery: RelayDiscovery | None = RelayDiscovery(PORT) if not DISABLE_DISCOVERY else None


@asynccontextmanager
async def lifespan(app: FastAPI):
    if _discovery:
        await _discovery.start()
    yield
    if _discovery:
        await _discovery.stop()


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS.split(",") if ALLOWED_ORIGINS != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return JSONResponse({
        "status": "ok",
        "daemons_connected": len(state.daemons),
    })


app.include_router(daemon_router)
app.include_router(app_router)

if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT)
