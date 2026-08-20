from fastapi import FastAPI
from .auth import router as auth_router
from .crop import router as crop_router
from .livestock import router as livestock_route


def include_routers(app: FastAPI):

    app.include_router(auth_router)
    app.include_router(crop_router)
    app.include_router(livestock_route)

