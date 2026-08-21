from sqlmodel import Session, select
from app.models import User, UserRole


def list_all_users(session: Session):
    return session.exec(select(User)).all()


def get_user_by_id(session: Session, user_id: int):
    user = session.get(User, user_id)
    if not user:
        raise ValueError("User not found")
    return user


def block_user(session: Session, user_id: int,current_admin: User):
    if user_id == current_admin.id:
        raise ValueError("You cannot block your own account")
    user = get_user_by_id(session, user_id)
    user.is_active = False
    session.add(user)
    session.commit()
    session.refresh(user)
    session.close()
    return user


def unblock_user(session: Session, user_id: int):
    user = get_user_by_id(session, user_id)
    if user.is_active:
        raise ValueError("User is not blocked")
    user.is_active = True
    session.add(user)
    session.commit()
    session.refresh(user)
    session.close()
    return user


def update_user_role(session: Session, user_id: int, role: UserRole):
    user = get_user_by_id(session, user_id)
    user.role = role
    session.add(user)
    session.commit()
    session.refresh(user)
    session.close()
    return user


def delete_user(session: Session, user_id: int,current_admin:User):
    if user_id == current_admin.id:
        raise ValueError("You cannot delete your own account")
    user = get_user_by_id(session, user_id)
    session.delete(user)
    session.commit()
    session.close()