from fastapi import FastAPI, Depends, APIRouter

from app.services import  get_livestock, get_crop
from app.database import get_session
from sqlmodel import Session

router = APIRouter(
    prefix="",
    tags=["Overview API"]
)

@router.get("/overview/{user_id}")
def _Get_overview(user_id: int,session: Session = Depends(get_session)):
    # try:
        crops = get_crop(session, user_id)
        livestocks = get_livestock(session, user_id)
        overview = {
            "crop_total_revenue": 0,
            "crop_total_profit": 0,
            "livestock_total_revenue": 0,
            "livestock_total_profit": 0,
            "total_profit" : 0,
            "total_revenue": 0,
            "total_crops": 0,
            "total_livestock": 0,
        }
        print(type(crops))
        if crops['status']:
            for crop in crops['data']:
                
                overview["crop_total_profit"] += crop.profit
                overview["crop_total_revenue"] += crop.revenue
                overview['total_crops'] += 1
        if livestocks['status']:
            for livestock in livestocks['data']:
                overview["livestock_total_revenue"] += livestock.revenue
                overview['livestock_total_profit'] += livestock.profit
                overview['total_livestock'] += 1

        overview['total_profit'] = overview['crop_total_profit'] + overview['livestock_total_profit']
        
        overview['total_revenue'] = overview['crop_total_revenue'] + overview['livestock_total_revenue']

        return {"success": True,"message":"Overview Fetched successfully", "data":overview}

    # except:
    #     return {"success": False,"message":"Overview Falied", "data":None}



