
from sqlmodel import select, or_
from app.models import Livestock, LivestockType
from app.database import get_session
from collections import defaultdict
from app.schemas import CreateLivestockRequest, UpdateLivestockRequest, GetLivestockResponse, GetLivestockTypesResponse

def create_livestock(livestock:CreateLivestockRequest):
    try:
        new_livestock = Livestock.model_validate(livestock)
        with get_session() as session:
            session.add(new_livestock)
            session.commit()
            
        return {"status":True, "error_code": None, "data": None}
    
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}

def get_livestock(user_id, livestock_id=None):

    try:
        conditions = []
        if user_id:
            conditions.append(Livestock.user_id == user_id)
        if livestock_id:
            conditions.append(Livestock.id == livestock_id)
        with get_session() as session:
            statement = select(Livestock).where(*conditions)
            livestock = session.exec(statement).all()

        ordered_livestock = sorted(livestock, key=lambda livestock: (livestock.prod_start_year, livestock.prod_end_year), reverse=True)
        
        return {"status": True, "error_code": None, "data": [GetLivestockResponse.model_validate(livestock) for livestock in ordered_livestock]}

    except Exception as e:
            return {"status": False, "error_code": e, "data": None}
       

def update_livestock(update_livestock:UpdateLivestockRequest):
    try:
        new_livestock = Livestock.model_validate(update_livestock)
        with get_session() as session:

            session.merge(new_livestock)
            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}
    
def del_livestock(livestock_id, user_id,):
    try:
        with get_session() as session:
            statement = select(Livestock).where(Livestock.id == livestock_id, Livestock.user_id == user_id)

            crop = session.exec(statement).first()
            
            session.delete(crop)
            session.commit()

        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

def drop_livestock(user_id):
    try:
        with get_session() as session:
            livestocks = session.exec(select(Livestock).where(Livestock.user_id == user_id)).all()
            for livestock in livestocks:
                session.delete(livestock)

            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}

def get_livestock_types():
    try:
        with get_session() as session:
            livestock_types = session.exec(select(LivestockType)).all()
        data = [GetLivestockTypesResponse.model_validate(livestock_type) for livestock_type in livestock_types]
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
         return {"status": False, "error_code": e, "data": None}
