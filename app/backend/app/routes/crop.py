from fastapi import FastAPI, Depends, APIRouter
from app.schemas import CreateCropRequest, UpdateCropRequest, CreateCropTypeRequest

from app.services import create_crop, get_crop, update_crop, del_crop, drop_crops, get_crop_types, create_crop_type, del_crop_type
from app.database import get_session
from sqlmodel import Session

router = APIRouter(
    prefix="/crop",
    tags=["Crop API"]
)

@router.get("/get/{user_id}")
def _Get_crop(user_id: int,  session : Session = Depends(get_session)):

    res = get_crop(session, user_id)
    if res['status']:
        return {"success": True,"message":"Crop Fetched successfully", "data":res['data']}
        
    return {"success": False,"message":"Failed to Fetch Crop"}

@router.get('/crop_types')
def _Get_crop_types(session:Session = Depends(get_session)):
    res = get_crop_types(session)

    if res['status']:
        return {"success": True, "message": "Crop Types Fetched Successfully", "data": res['data']}
    return {'success': False, "message": "Failed to Fetch Crop Types"}

@router.post("/create")
def _Create_crop(new_crop:CreateCropRequest, session : Session = Depends(get_session)):
    res = create_crop(session, new_crop)
    if res['status']:   
        return {"success": True, "message":"Crop Added successfully"}
    
    return {"success": False, "message":"Failed to Add Crop"}


@router.post('/create_type')
def _Create_crop_type(livestock_type: CreateCropTypeRequest,session:Session = Depends(get_session)):
    
    res = create_crop_type(session, livestock_type)

    if res['status']:
        return {"success": True, "message": "Crop Type Created Successfully"}
    
    return {'success': False, "message": "Failed to Create Crop Type", "error": res['error_code']}

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



@router.delete('/del_type/{id}')
def _Del_crop_type(id: int, session:Session = Depends(get_session)):

    res = del_crop_type(session, id)
    if res['status']:
        return {"success": True, "message": "Crop Type Deleted Successfully"}
    
    return {"success": False, "message": "Failed to Delete Crop Type", "error": res['error_code']}





    


