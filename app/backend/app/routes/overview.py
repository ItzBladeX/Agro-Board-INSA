from fastapi import Depends, APIRouter
from sqlmodel import Session

from app.services import get_livestock, get_crop
from app.database import get_session
from app.models.user import User
from app.core.dependencies import get_current_user  


router = APIRouter(
    prefix="",
    tags=["Overview API"]
)


@router.get("/overview")
def _Get_overview(
    current_user: User = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    user_id = current_user.id

    crops = get_crop(session, user_id)
    livestocks = get_livestock(session, user_id)

    overview = {
        "crop_total_revenue": 0,
        "crop_total_profit": 0,
        "livestock_total_revenue": 0,
        "livestock_total_profit": 0,
        "total_profit": 0,
        "total_revenue": 0,
        "total_crops": 0,
        "total_livestock": 0,
    }

    print(f"Authenticated User ID: {user_id}")
    print(type(crops))

    if crops["status"]:
        for crop in crops["data"]:
            overview["crop_total_profit"] += crop.profit or 0
            overview["crop_total_revenue"] += crop.revenue or 0
            overview["total_crops"] += 1

    if livestocks["status"]:
        for livestock in livestocks["data"]:
            overview["livestock_total_revenue"] += livestock.revenue or 0
            overview["livestock_total_profit"] += livestock.profit or 0
            overview["total_livestock"] += 1

    overview["total_profit"] = (
        overview["crop_total_profit"]
        + overview["livestock_total_profit"]
    )

    overview["total_revenue"] = (
        overview["crop_total_revenue"]
        + overview["livestock_total_revenue"]
    )

    return {
        "success": True,
        "message": "Overview Fetched successfully",
        "data": overview,
    }