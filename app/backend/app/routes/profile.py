from fastapi import APIRouter, Depends ,HTTPException
from sqlmodel import Session
from app.database import get_session
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.user import UpdateUserRequest, GetUserResponse
from app.services import get_user_profile, update_user_profile

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("/", response_model=GetUserResponse)
def get_profile(
    current_user: User = Depends(get_current_user),
):
    try:
        return get_user_profile(current_user)
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
            )

@router.put("/")
def update_profile(
    data: UpdateUserRequest,
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    try:
        update_user_profile(session, current_user, data)
        return {
            "success": True,
            "message": "profile updated successfully",
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
        