from fastapi import FastAPI
from app.routes.auth import router as auth_router
from app.routes.profile import router as profile_router   
from app.database import init_db
from app.routes import include_routers

app = FastAPI()
#TODO: ADd auth and profile to include_routers
# Code has dublicate import of auth_router !!!
app.include_router(auth_router) # <<<<<<<<<<TODO
app.include_router(profile_router)   

include_routers(app)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/")
def root(): 
    return { "message": "API is running"}