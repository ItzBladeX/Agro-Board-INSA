from sqlmodel import select, or_
from app.models import Crop, CropType
from app.database import get_session

from app.schemas import CreateCropRequest,UpdateCropRequest, GetCropResponse, GetCropTypesResponse

def create_crop(crop:CreateCropRequest):

    try:
        new_crop = Crop.model_validate(crop)
        with get_session() as session:

            session.add(new_crop)
            session.commit()
            
        return {"status":True, "error_code": None, "data": None}
    
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}


def get_crop(user_id, crop_id=None):

    try:
        conditions = []
        if user_id:
            conditions.append(Crop.user_id == user_id)
        if crop_id:
            conditions.append(Crop.id == crop_id)
        with get_session() as session:
            statement = select(Crop).where(*conditions)
            crops = session.exec(statement).all()

        sorted_crops = sorted(crops, key=lambda crop : (crop.prod_start_year, crop.prod_end_year), reverse=True)
        
        return {"status": True, "error_code": None, "data": [GetCropResponse.model_validate(crop) for crop in sorted_crops]}

    except Exception as e:
            return {"status": False, "error_code": e, "data": None}


def update_crop(update_crop: UpdateCropRequest):
    try:
        new_crop = Crop.model_validate(update_crop)
        with get_session() as session:

            session.merge(new_crop)
           
            session.commit()

        return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}
        
def del_crop(crop_id, user_id,):
    try:
        with get_session() as session:
            statement = select(Crop).where(Crop.id == crop_id, Crop.user_id == user_id)

            crop = session.exec(statement).first()
            
            session.delete(crop)
            session.commit()

            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}


def drop_crops(user_id):
    try:
        with get_session() as session:
            crops = session.exec(select(Crop).where(Crop.user_id == user_id)).all()
            for crop in crops:
                session.delete(crop)

            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}

def get_crop_types():
    try:
        with get_session() as session:
            crop_types = session.exec(select(CropType)).all()

        data = [GetCropTypesResponse.model_validate(crop_type) for crop_type in crop_types]
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
         return {"status": False, "error_code": e, "data": None}
