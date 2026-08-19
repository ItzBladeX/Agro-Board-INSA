from fastapi import FastAPI, Depends, APIRouter
from app.schemas import CreateCropRequest, GetCropResponse, UpdateCropRequest
from app.services import create_crop, get_crop, update_crop, del_crop, drop_crops
from app.database import get_session
from sqlmodel import Session

router = APIRouter(
    prefix="/crop",
    tags=["CropAPI"]
)


@router.post("/create")
def _Create_crop(new_crop:CreateCropRequest, session : Session = Depends(get_session)):
    res = create_crop(session, new_crop)
    if res['status']:   
        return {"success": True, "message":"Crop Added successfully"}
    
    return {"success": False, "message":"Failed to Add Crop"}

@router.get("/get/{user_id}")
def _Get_crop(user_id: int,  session : Session = Depends(get_session)):
    
    res = get_crop(session, user_id)
    if res['status']:
        return {"success": True,"message":"Crop Fetched successfully", "data":res['data']}
        
    return {"success": False,"message":"Failed to Fetch Crop"}


@router.patch("/update")
def _Update_crop(new_crop: UpdateCropRequest,  session : Session = Depends(get_session)):
    res = update_crop(session, new_crop)
    if res['status']:
        return {"success": True, "message":"Crop Updated successfully"}
    return {"success": False,"message":"Failed to Update Crop"}

@router.delete("/delete/{user_id}/{crop_id}")
def _Del_crop(user_id: int, crop_id: int,  session : Session = Depends(get_session)):
    res = del_crop(session,user_id, crop_id)

    if res['status']:
        return {"success": True, "message":"Crop Deleted successfully"}
    return {"success": False,"message":"Failed to Delete Crop"}

@router.delete("/drop/{user_id}")
def _Drop_crops(user_id: int,  session : Session = Depends(get_session)):
    res = drop_crops(session,user_id)

    if res['status']:
        return {"success": True, "message":"Crop Dropped successfully"}
    return {"success": False,"message":"Failed to Drop Crop"}



    


