from sqlmodel import Session, select
from app.models.user import User
from app.schema.user import CreateUserRequest, UserLogin
from app.core.security import hash_password, verify_password


def register_user(session: Session, data: CreateUserRequest) -> User:
    existing_phone = session.exec(
        select(User).where(User.phone_number == data.phone_number)
    ).first()
    if existing_phone:
        raise ValueError("Phone number already registered")

    existing_username = session.exec(
        select(User).where(User.username == data.username)
    ).first()
    if existing_username:
        raise ValueError("Username already taken")

    user = User(
    username=data.username,
    first_name=data.first_name,
    middle_name=data.middle_name,
    last_name=data.last_name,
    phone_number=data.phone_number,
    birth_date=data.birth_date,
    age=data.age,
    gender=data.gender,
    land_area=data.land_area,
    passwd=hash_password(data.passwd),
)
    
    session.add(user)
    session.commit()
    session.refresh(user)
    return user


def authenticate_user(session: Session, data: UserLogin) -> User | None:
    user = session.exec(
        select(User).where(User.phone_number == data.phone_number)
    ).first()
    if not user:
        return None
    if not verify_password(data.passwd, user.passwd):
        return None
    return user