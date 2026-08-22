from fastapi import FastAPI, Depends, APIRouter
from app.schemas import CreateLivestockRequest, UpdateLivestockRequest, CreateLivestockTypeRequest
from app.services import create_livestock, get_livestock, update_livestock, del_livestock, drop_livestock, get_livestock_types, create_livestock_type, del_livestock_type
from app.database import get_session
from app.core.dependencies import get_current_user
from app.models.user import User
from sqlmodel import Session

router = APIRouter(
    prefix="/livestock",
    tags=["Livestock API"]
)

@router.get("/get")
def _Get_livestock(current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = get_livestock(session, current_user.id)
    if res['status']:
        return {"success": True, "message": "Livestock Fetched successfully", "data": res['data']}
    return {"success": False, "message": "Failed to Fetch Livestock", "error": res['error_code']}

@router.get('/livestock_types')
def _Get_livestock_types(session: Session = Depends(get_session)):
    res = get_livestock_types(session)
    if res['status']:
        return {"success": True, "message": "Crop Types Fetched Successfully", "data": res['data']}
    return {'success': False, "message": "Failed to Fetch Crop Types", "error": res['error_code']}

@router.post("/create")
def _Create_livestock(new_livestock: CreateLivestockRequest, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = create_livestock(session, new_livestock, current_user.id)
    if res['status']:
        return {"success": True, "message": "Livestock Added successfully"}
    return {"success": False, "message": "Failed to Add Livestock", "error": res['error_code']}

@router.post('/create_type')
def _Create_livestock_type(livestock_type: CreateLivestockTypeRequest, session: Session = Depends(get_session)):
    res = create_livestock_type(session, livestock_type)
    if res['status']:
        return {"success": True, "message": "Livestock Type Created Successfully"}
    return {'success': False, "message": "Failed to Create Livestock Type", "error": res['error_code']}

@router.patch("/update")
def _Update_livestock(new_livestock: UpdateLivestockRequest, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = update_livestock(session, new_livestock, current_user.id)
    if res['status']:
        return {"success": True, "message": "Livestock Updated successfully"}
    return {"success": False, "message": "Failed to Update Livestock", "error": res['error_code']}

@router.delete("/delete/{livestock_id}")
def _Del_livestock(livestock_id: int, current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = del_livestock(session, current_user.id, livestock_id)
    if res['status']:
        return {"success": True, "message": "Livestock Deleted successfully"}
    return {"success": False, "message": "Failed to Delete Livestock", "error": res['error_code']}

@router.delete("/drop")
def _Drop_livestock(current_user: User = Depends(get_current_user), session: Session = Depends(get_session)):
    res = drop_livestock(session, current_user.id)
    if res['status']:
        return {"success": True, "message": "Livestock Dropped successfully"}
    return {"success": False, "message": "Failed to Drop Livestock", "error": res['error_code']}

@router.delete('/del_type/{id}')
def _Del_livestock_type(id: int, session: Session = Depends(get_session)):
    res = del_livestock_type(session, id)
    if res['status']:
        return {"success": True, "message": "Livestock Type Deleted Successfully"}
    return {"success": False, "message": "Failed to Delete Livestock Type", "error": res['error_code']}