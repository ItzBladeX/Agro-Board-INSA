from fastapi import FastAPI
from app.routes.auth import router as auth_router
from app.routes.profile import router as profile_router   
from app.database import init_db

app = FastAPI()
app.include_router(auth_router)
app.include_router(profile_router)   

@app.on_event("startup")
def on_startup():
    init_db()


@app.get("/")
def root():
    return {
        "message": "API is running"
    }