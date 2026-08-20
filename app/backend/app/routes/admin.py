from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.database import get_session
from app.core.dependencies import get_current_admin
from app.models.user import User
from app.schemas.user import AdminUserView, UserRoleUpdate
from app.services import admin_service

router = APIRouter(prefix="/admin", tags=["admin"])


@router.get("/users", response_model=list[AdminUserView])
def get_all_users(
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin),
):
    return admin_service.list_all_users(session)


@router.patch("/users/{user_id}/block")
def block_user(
    user_id: int,
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin),
):
    try:
        admin_service.block_user(session, user_id,admin)
        return {"success": True, "message": "User blocked successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.patch("/users/{user_id}/unblock")
def unblock_user(
    user_id: int,
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin),
):
    try:
        admin_service.unblock_user(session, user_id)
        return {"success": True, "message": "User unblocked successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.patch("/users/{user_id}/role")
def change_user_role(
    user_id: int,
    data: UserRoleUpdate,
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin),
):
    try:
        admin_service.update_user_role(session, user_id, data.role)
        return {"success": True, "message": "User role updated successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.delete("/users/{user_id}")
def remove_user(
    user_id: int,
    session: Session = Depends(get_session),
    admin: User = Depends(get_current_admin),
):
    try:
        admin_service.delete_user(session, user_id,admin)
        return {"success": True, "message": "User deleted successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))