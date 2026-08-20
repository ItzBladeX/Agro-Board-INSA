from sqlmodel import select
from app.database import get_session
from app.models import User
from app.schemas import GetUserResponse, UpdateUserRequest


def get_user(id):
    try:
        with get_session() as session:
            statement = select(User).where(User.id == id)
            user = session.exec(statement).first()

        return {"status": True, "error_code": None, "data": GetUserResponse.model_validate(user)}
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

def update_user(update_user: UpdateUserRequest):

    try:
        updated_user = User.model_validate(update_user)
        id = updated_user.id
        with get_session() as session:
            statement = select(User).where(User.id == id, User.passwd == update_user.passwd)
            user = session.exec(statement).first()
            if not user:
                return {"status": False, "error_code": None, "data": None}
            
            session.merge(updated_user)
            session.commit()

            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:

        return {"status": False, "error_code": e, "data": None}
        
def link_to_server(id, server_id, server_passwd):
    # if not all([user.id, user.name ,user.age, user.gender, user.land_area, server_id, server_passwd]) :
    #     return False
    pass

def del_user(id, passwd):
    try:
        with get_session() as session:
            statement = select(User).where(User.id == id, User.passwd == passwd)
            user = session.exec(statement).first()

            session.delete(user)
            session.commit()
        
        return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

    
