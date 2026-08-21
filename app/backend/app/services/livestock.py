
from sqlmodel import select, or_
from app.models import Livestock, LivestockType

from sqlmodel import Session
from app.schemas import CreateLivestockRequest, UpdateLivestockRequest,GetLivestockTypesResponse, GetLivestockResponse, CreateLivestockTypeRequest

def create_livestock(s:Session,livestock:CreateLivestockRequest):
    try:
        new_livestock = Livestock.model_validate(livestock)
        with s as session:
            session.add(new_livestock)
            session.commit()
            
        return {"status":True, "error_code": None, "data": None}
    
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}

def get_livestock(s:Session, user_id):

    try:
        with s as session:
            statement = select(Livestock).where(Livestock.user_id == user_id)
            livestocks = session.exec(statement).all()
            if not livestocks:
                {"status": False, "error_code": "No Livestocks Found", "data": None}

        livestocks = [GetLivestockResponse.model_validate(livestock.model_dump()) for livestock in livestocks]
        ordered_livestock = sorted(livestocks, key=lambda livestock: (livestock.prod_start_year, livestock.prod_end_year), reverse=True)
        
        return {"status": True, "error_code": None, "data": ordered_livestock}

    except Exception as e:
            return {"status": False, "error_code": e, "data": None}
       

def update_livestock(s:Session, update_livestock:UpdateLivestockRequest):
    try:
        new_livestock = Livestock.model_validate(update_livestock)
        with s as session:

            session.merge(new_livestock)
            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}
    
def del_livestock(s:Session, user_id,livestock_id):
    try:
        with s as session:
            statement = select(Livestock).where(Livestock.id == livestock_id, Livestock.user_id == user_id)

            crop = session.exec(statement).first()
            
            session.delete(crop)
            session.commit()

        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

def drop_livestock(s:Session,user_id):
    try:
        with s as session:
            livestocks = session.exec(select(Livestock).where(Livestock.user_id == user_id)).all()
            for livestock in livestocks:
                session.delete(livestock)

            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}

def get_livestock_types(s:Session):
    try:
        with s as session:
            livestock_types = session.exec(select(LivestockType)).all()
        if not data:
            return {"status": False, "error_code": "No Livestock Types", "data": None}
        
        data = [GetLivestockTypesResponse.model_validate(livestock_type) for livestock_type in livestock_types]
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
         return {"status": False, "error_code": e, "data": None}

def create_livestock_type(s:Session, livestock_type: CreateLivestockTypeRequest):
    try:
        new_livestock_type = LivestockType.model_validate(livestock_type)
        with s as session:

            exists = session.exec(select(LivestockType).where(LivestockType.name == new_livestock_type.name)).all()
            if exists:
                return {"status": False, "error_code": "Livestock Type Already Exists"}
            
            session.add(new_livestock_type)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

def del_livestock_type(s:Session, id: int):
    try:
        with s as session:
            livestock_type = session.exec(select(LivestockType).where(LivestockType.id == id)).first()
            if not livestock_type:
                return {"status": False, "error_code": "Livestock Type Doesnt Exist"}
            
            session.delete(livestock_type)
            session.commit()
            return {"status": True, "error_code": "Livestock Type Deleted", "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}