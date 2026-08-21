from sqlmodel import select, or_, Session
from app.models import Crop, CropType
from app.schemas import CreateCropRequest, GetCropTypesResponse, UpdateCropRequest, GetCropResponse, CreateCropTypeRequest

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
    print("Function Called")

    try:
        with s as session:
            statement = select(Crop).where(Crop.user_id == user_id)
            crops = session.exec(statement).all()
            print("Queried")

            if not crops:
                {"status": False, "error_code": "No Crops Found", "data": None}
        print("Found")
        crops = [GetCropResponse.model_validate(crop.model_dump()) for crop in crops]
        sorted_crops = sorted(crops, key=lambda crop : (crop.prod_start_year, crop.prod_end_year), reverse=True)
        print("Ordered")
        
        return {"status": True, "error_code": None, "data":  sorted_crops}

    except Exception as e:
            print(e)
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
        if not crop_types:
            return {"status": False, "error_code": "No Crop Types", "data": None}

        # data = [GetCropTypesResponse.model_validate(crop_type) for crop_type in crop_types]
        data = {crop_type.name: crop_type.id for crop_type in crop_types}

        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
         return {"status": False, "error_code": e, "data": None}


def create_crop_type(s:Session, crop_type: CreateCropTypeRequest):
    try:
        new_crop_type = CropType.model_validate(crop_type)
        with s as session:

            exists = session.exec(select(CropType).where(CropType.name == new_crop_type.name)).all()
            if exists:
                return {"status": False, "error_code": "Crop Type Already Exists"}
            
            session.add(new_crop_type)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}

def del_crop_type(s:Session, id: int):
    try:
        with s as session:
            crop_type = session.exec(select(CropType).where(CropType.id == id)).first()
            if not crop_type:
                return {"status": False, "error_code": "Crop Type Doesnt Exist"}
            
            session.delete(crop_type)
            session.commit()
            return {"status": True, "error_code": "Crop Type Deleted", "data": None}
        
    except Exception as e:
        return {"status": False, "error_code": e, "data": None}
                    
                        
                            







