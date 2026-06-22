from fastapi import FastAPI
import uvicorn

try:
    from .config import HOST, PORT
    from .handlers.daemon import router as daemon_router
    from .handlers.app import router as app_router
except ImportError:
    from config import HOST, PORT
    from handlers.daemon import router as daemon_router
    from handlers.app import router as app_router

app = FastAPI()
app.include_router(daemon_router)
app.include_router(app_router)

if __name__ == "__main__":
    uvicorn.run(app, host=HOST, port=PORT)
