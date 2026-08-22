from sqlmodel import select, or_
from app.models import Livestock, LivestockType
from sqlmodel import Session
from app.schemas import CreateLivestockRequest, UpdateLivestockRequest, GetLivestockTypesResponse, GetLivestockResponse, CreateLivestockTypeRequest


def create_livestock(s: Session, livestock: CreateLivestockRequest, user_id: int):
    try:
        data = livestock.model_dump()
        data["user_id"] = user_id  # server sets ownership, not the client
        new_livestock = Livestock.model_validate(data)
        with s as session:
            session.add(new_livestock)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def get_livestock(s: Session, user_id):
    try:
        with s as session:
            statement = select(Livestock).where(Livestock.user_id == user_id)
            livestocks = session.exec(statement).all()

        livestocks = [GetLivestockResponse.model_validate(l.model_dump()) for l in livestocks]
        ordered_livestock = sorted(livestocks, key=lambda l: (l.prod_start_year, l.prod_end_year), reverse=True)
        return {"status": True, "error_code": None, "data": ordered_livestock}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def update_livestock(s: Session, update_data: UpdateLivestockRequest, user_id: int):
    try:
        with s as session:
            existing = session.exec(
                select(Livestock).where(
                    Livestock.id == update_data.id,
                    Livestock.user_id == user_id,  # ownership check
                )
            ).first()

            if not existing:
                return {"status": False, "error_code": "Livestock not found or not owned by user", "data": None}

            update_fields = update_data.model_dump(exclude_unset=True, exclude={"id", "user_id"})
            for key, value in update_fields.items():
                setattr(existing, key, value)

            session.add(existing)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def del_livestock(s: Session, user_id, livestock_id):
    try:
        with s as session:
            statement = select(Livestock).where(Livestock.id == livestock_id, Livestock.user_id == user_id)
            livestock = session.exec(statement).first()

            if not livestock:
                return {"status": False, "error_code": "Livestock not found or not owned by user", "data": None}

            session.delete(livestock)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def drop_livestock(s: Session, user_id):
    try:
        with s as session:
            livestocks = session.exec(select(Livestock).where(Livestock.user_id == user_id)).all()
            for livestock in livestocks:
                session.delete(livestock)
            session.commit()
        return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def get_livestock_types(s: Session):
    try:
        with s as session:
            livestock_types = session.exec(select(LivestockType)).all()
        if not livestock_types:
            return {"status": False, "error_code": "No Livestock Types", "data": None}

        data = {lt.name: lt.id for lt in livestock_types}
        return {"status": True, "error_code": None, "data": data}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def create_livestock_type(s: Session, livestock_type: CreateLivestockTypeRequest):
    try:
        new_livestock_type = LivestockType.model_validate(livestock_type)
        with s as session:
            exists = session.exec(select(LivestockType).where(LivestockType.name == new_livestock_type.name)).all()
            if exists:
                return {"status": False, "error_code": "Livestock Type Already Exists", "data": None}
            session.add(new_livestock_type)
            session.commit()
            return {"status": True, "error_code": None, "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}


def del_livestock_type(s: Session, id: int):
    try:
        with s as session:
            livestock_type = session.exec(select(LivestockType).where(LivestockType.id == id)).first()
            if not livestock_type:
                return {"status": False, "error_code": "Livestock Type Doesnt Exist", "data": None}
            session.delete(livestock_type)
            session.commit()
            return {"status": True, "error_code": "Livestock Type Deleted", "data": None}
    except Exception as e:
        return {"status": False, "error_code": str(e), "data": None}