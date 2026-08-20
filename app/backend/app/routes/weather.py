from fastapi import FastAPI, Depends, APIRouter
from app.schemas import GetWeatherResponse
from app.services import get_weather

router = APIRouter(
    prefix="/weather",
    tags=["Weather API"]
)

@router.get("/report")
def _Get_weather():
    res = get_weather()

    if res['status']:
        return {"success": True,"message":"Weather Fetched successfully", "data":res['data']}
    return {"success": False, "message": "failed to Fetch Weather Data", "error": res['error_code']}
