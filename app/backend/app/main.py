from fastapi import FastAPI

from app.database import init_db
from app.routes import include_routers

app = FastAPI()

include_routers(app)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def root(): 
    return { "message": "API is running"}