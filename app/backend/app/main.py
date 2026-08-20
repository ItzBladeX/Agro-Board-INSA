from fastapi import FastAPI
from app.routes.auth import router as auth_router
from app.routes.admin import router as admin_router
from app.database import init_db
from app.routes import include_routers

app = FastAPI()
app.include_router(auth_router)
app.include_router(admin_router)
include_routers(app)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def root(): 
    return { "message": "API is running"}