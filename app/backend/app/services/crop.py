from sqlmodel import select, or_, Session
from app.models import Crop, CropType
from app.schemas import CreateCropRequest, GetCropTypesResponse, UpdateCropRequest

def create_crop(s:Session, crop:CreateCropRequest):

    try:
        new_crop = Crop.model_validate(crop)
        with s as session:

            session.add(new_crop)
            session.commit()
            
        return {"status":True, "error_code": None, "data": None}
    
    except Exception as e:
        return {"status":False, "error_code": e, "data": None}


def get_crop(s: Session,user_id):

    try:
        # conditions = []
        # if user_id:
        #     conditions.append(Crop.user_id == user_id)
        # if crop_id:
        #     conditions.append(Crop.id == crop_id)
        with s as session:
            statement = select(Crop).where(Crop.user_id == user_id)
            crops = session.exec(statement).all()

            if not crops:
                {"status": False, "error_code": e, "data": None}

        sorted_crops = sorted(crops, key=lambda crop : (crop.prod_start_year, crop.prod_end_year), reverse=True)
        
        return {"status": True, "error_code": None, "data":  sorted_crops}

    except Exception as e:
            return {"status": False, "error_code": e, "data": None}


def update_crop(s:Session,update_crop: UpdateCropRequest):
    try:
        new_crop = Crop.model_validate(update_crop)
        with s as session:

            session.merge(new_crop)
            session.commit()

        return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}
        
def del_crop(s:Session,user_id,crop_id,):
    try:
        with s as session:
            statement = select(Crop).where(Crop.id == crop_id, Crop.user_id == user_id)

            crop = session.exec(statement).first()
            
            session.delete(crop)
            session.commit()

            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}


def drop_crops(s:Session,user_id:int):
    try:
        with s as session:
            crops = session.exec(select(Crop).where(Crop.user_id == user_id)).all()
            for crop in crops:
                session.delete(crop)

            session.commit()

            return {"status": True, "error_code": None, "data":None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data":None}

def get_crop_types(s:Session):
    try:
        with s as session:
            crop_types = session.exec(select(CropType)).all()

        data = [GetCropTypesResponse.model_validate(crop_type) for crop_type in crop_types]
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
         return {"status": False, "error_code": e, "data": None}
