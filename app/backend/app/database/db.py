from sqlmodel import SQLModel, Session, create_engine
from app.models import User, Crop, Livestock
from app.core import settings


engine = create_engine(settings.sqlite_url) 

def init_db():

    SQLModel.metadata.create_all(engine)

def get_session():
    return Session(engine)