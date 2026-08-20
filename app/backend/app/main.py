from fastapi import FastAPI
from app.routes import include_routers
from app.database import init_db

app = FastAPI()
include_routers(app)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def root(): 
    return { "message": "API is running"}