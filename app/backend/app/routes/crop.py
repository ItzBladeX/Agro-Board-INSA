from fastapi import FastAPI, Depends, APIRouter
from app.schemas import CreateCropRequest, UpdateCropRequest, CreateCropTypeRequest
from app.services import create_crop, get_crop, update_crop, del_crop, drop_crops, get_crop_types, create_crop_type, del_crop_type
from app.database import get_session
from app.core.dependencies import get_current_user
from app.models.user import User
from sqlmodel import Session

router = APIRouter(prefix="/crop", tags=["Crop API"])

@router.get("/get")
def _Get_crop(current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = get_crop(session, current_user.id)
    if res['status']:
        return {"success": True, "message": "Crop Fetched successfully", "data": res['data']}
    return {"success": False, "message": "Failed to Fetch Crop"}

@router.get('/crop_types')
def _Get_crop_types(session: Session = Depends(get_session)):
    res = get_crop_types(session)
    if res['status']:
        return {"success": True, "message": "Crop Types Fetched Successfully", "data": res['data']}
    return {'success': False, "message": "Failed to Fetch Crop Types"}

@router.post("/create")
def _Create_crop(new_crop: CreateCropRequest, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = create_crop(session, new_crop, current_user.id)
    if res['status']:
        return {"success": True, "message": "Crop Added successfully"}
    return {"success": False, "message": "Failed to Add Crop"}

@router.post('/create_type')
def _Create_crop_type(crop_type: CreateCropTypeRequest, session: Session = Depends(get_session)):
    res = create_crop_type(session, crop_type)
    if res['status']:
        return {"success": True, "message": "Crop Type Created Successfully"}
    return {'success': False, "message": "Failed to Create Crop Type", "error": res['error_code']}

@router.patch("/update")
def _Update_crop(new_crop: UpdateCropRequest, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = update_crop(session, new_crop, current_user.id)
    if res['status']:
        return {"success": True, "message": "Crop Updated successfully"}
    return {"success": False, "message": "Failed to Update Crop"}

@router.delete("/delete/{crop_id}")
def _Del_crop(crop_id: int, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = del_crop(session, current_user.id, crop_id)
    if res['status']:
        return {"success": True, "message": "Crop Deleted successfully"}
    return {"success": False, "message": "Failed to Delete Crop"}

@router.delete("/drop")
def _Drop_crops(current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = drop_crops(session, current_user.id)
    if res['status']:
        return {"success": True, "message": "Crop Dropped successfully"}
    return {"success": False, "message": "Failed to Drop Crop"}

@router.delete('/del_type/{id}')
def _Del_crop_type(id: int, session: Session = Depends(get_session)):
    res = del_crop_type(session, id)
    if res['status']:
        return {"success": True, "message": "Crop Type Deleted Successfully"}
    return {"success": False, "message": "Failed to Delete Crop Type", "error": res['error_code']}