from fastapi import APIRouter, Depends, HTTPException, status
from sqlmodel import Session
from app.schemas import CreateUserRequest ,UserLogin, GetUserResponse
from app.services import register_user, authenticate_user, get_user
from app.core.security import create_access_token
from app.core.dependencies import get_current_user
from app.models.user import User
from app.database import get_session


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post("/register")
def register(data: CreateUserRequest, session: Session = Depends(get_session)):
    try:
         register_user(session, data)
         return {
             "success":True,
              "phone_number": data.phone_number,
             "message":"user registered successfully"
         }

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post("/login")
def login(
    data: UserLogin,
    session: Session = Depends(get_session)
):
    user = authenticate_user(session, data)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid phone_number or password"
        )

    token = create_access_token({
        "sub": str(user.id)
    })

    return {
        "success":True,
        "message": "logged in successfully",
        "access_token": token,
        "token_type": "bearer"
    }


