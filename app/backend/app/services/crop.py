from sqlmodel import select, or_
from app.models import Crop, CropType
from sqlmodel import Session
from app.schemas import CreateCropRequest, UpdateCropRequest, GetCropTypesResponse, GetCropResponse, CreateCropTypeRequest


def create_crop(s: Session, crop: CreateCropRequest, user_id: int):
    try:
        data = crop.model_dump()
        data["user_id"] = user_id
        new_crop = Crop.model_validate(data)
        with s as session:
            session.add(new_crop)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def get_crop(s: Session, user_id):
    try:
        with s as session:
            statement = select(Crop).where(Crop.user_id == user_id)
            crops = session.exec(statement).all()

        crops = [GetCropResponse.model_validate(c.model_dump()) for c in crops]
        ordered_crops = sorted(crops, key=lambda c: (c.prod_start_year, c.prod_end_year), reverse=True)
        return {"status": True, "error_code": None, "data": ordered_crops}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def update_crop(s: Session, update_data: UpdateCropRequest, user_id: int):
    try:
        with s as session:
            existing = session.exec(
                select(Crop).where(
                    Crop.id == update_data.id,
                    Crop.user_id == user_id,
                )
            ).first()

            if not existing:
                return {"status": False, "error_code": "Crop not found or not owned by user", "data": None}

            update_fields = update_data.model_dump(exclude_unset=True, exclude={"id", "user_id"})
            for key, value in update_fields.items():
                setattr(existing, key, value)

            session.add(existing)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def del_crop(s: Session, user_id, crop_id):
    try:
        with s as session:
            statement = select(Crop).where(Crop.id == crop_id, Crop.user_id == user_id)
            crop = session.exec(statement).first()

            if not crop:
                return {"status": False, "error_code": "Crop not found or not owned by user", "data": None}

            session.delete(crop)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def drop_crops(s: Session, user_id):
    try:
        with s as session:
            crops = session.exec(select(Crop).where(Crop.user_id == user_id)).all()
            for crop in crops:
                session.delete(crop)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def get_crop_types(s: Session):
    try:
        with s as session:
            crop_types = session.exec(select(CropType)).all()
        if not crop_types:
            return {"status": False, "error_code": "No Crop Types", "data": None}

        data = {ct.name: ct.id for ct in crop_types}
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def create_crop_type(s: Session, crop_type: CreateCropTypeRequest):
    try:
        new_crop_type = CropType.model_validate(crop_type)
        with s as session:
            exists = session.exec(select(CropType).where(CropType.name == new_crop_type.name)).all()
            if exists:
                return {"status": False, "error_code": "Crop Type Already Exists", "data": None}
            session.add(new_crop_type)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def del_crop_type(s: Session, id: int):
    try:
        with s as session:
            crop_type = session.exec(select(CropType).where(CropType.id == id)).first()
            if not crop_type:
                return {"status": False, "error_code": "Crop Type Doesnt Exist", "data": None}
            session.delete(crop_type)
            session.commit()
            return {"status": True, "error_code": "Crop Type Deleted", "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}