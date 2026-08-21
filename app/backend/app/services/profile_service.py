# services/profile_service.py
from sqlmodel import Session, select
from app.models.user import User
from app.schemas.user import UpdateUserRequest
from app.core.security import hash_password


def get_user_profile(current_user):
    return current_user


def update_user_profile(
    session: Session,
    user: User,
    data: UpdateUserRequest,
):
    update_data = data.dict(exclude_unset=True)

    if not update_data:
        raise ValueError("No fields provided to update")

    if "phone_number" in update_data:
        new_phone = update_data["phone_number"]

        if new_phone != user.phone_number:
            existing = session.exec(
                select(User).where(
                    User.phone_number == new_phone,
                    User.id != user.id,
                )
            ).first()

            if existing:
                raise ValueError("Phone number is already in use")

    if "passwd" in update_data:
        raw_password = update_data.pop("passwd")
        user.passwd = hash_password(raw_password)

    for key, value in update_data.items():
        setattr(user, key, value)

    session.add(user)
    session.commit()
    session.refresh(user)
    session.close()

    return user