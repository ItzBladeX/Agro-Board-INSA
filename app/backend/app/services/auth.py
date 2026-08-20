from app.database import get_session
from app.models import User
from app.schemas import CreateUserRequest
from sqlmodel import select

def create_user(new_user:CreateUserRequest):
    try:
        user = User.model_validate(new_user)
        with get_session() as session:
            
            session.add(user)
            session.commit()

            session.refresh(user)

            return {"status":True, "error_code": None, "data": user}
        
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}

def auth_user(username, passwd):
    try:
        with get_session() as session:
            statement = select(User).where(User.username == username, User.passwd == passwd)
            user = session.exec(statement).first()
            if not user:
                return {"status":False, "error_code": "User Not Found", "data": None}
            
            return {"status":True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}

def reset_password(id, passwd, new_passwd):
    try:
        with get_session() as session:
            statement = select(User).where(User.id == id, User.passwd == passwd)
            user = session.exec(statement).one()

            user.passwd = new_passwd
            session.add(user)
            session.commit()

            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
    
        return {"status": False, "error_code": e, "data": None}

def check_username(username):
    try:
        with get_session() as session:
            statement = select(User).where(User.username == username)
            user = session.exec(statement).first()

            if not user:
                return {"status": False, "error_code": "User Not Found", "data": None}
            
            return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}