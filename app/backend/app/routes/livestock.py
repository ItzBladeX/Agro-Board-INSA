from fastapi import FastAPI, Depends, APIRouter
from app.schemas import CreateLivestockRequest, UpdateLivestockRequest
from app.services import create_livestock, get_livestock, update_livestock, del_livestock, drop_livestock
from app.database import get_session
from sqlmodel import Session

router = APIRouter(
    prefix="/livestock",
    tags=["Livestock API"]
)


@router.post("/create")
def _Create_livestock(new_livestock:CreateLivestockRequest, session : Session = Depends(get_session)):
    res = create_livestock(session, new_livestock)
    if res['status']:   
        return {"success": True, "message":"Livestock Added successfully"}
    
    return {"success": False, "message":"Failed to Add Livestock"}

@router.get("/get/{user_id}")
def _Get_livestock(user_id: int,  session : Session = Depends(get_session)):
    
    res = get_livestock(session, user_id)
    if res['status']:
        return {"success": True,"message":"Livestock Fetched successfully", "data":res['data']}
        
    return {"success": False,"message":"Failed to Fetch Livestock"}


@router.patch("/update")
def _Update_livestock(new_livestock: UpdateLivestockRequest,  session : Session = Depends(get_session)):
    res = update_livestock(session, new_livestock)
    if res['status']:
        return {"success": True, "message":"Livestock Updated successfully"}
    return {"success": False,"message":"Failed to Update Livestock"}

@router.delete("/delete/{user_id}/{crop_id}")
def _Del_livestock(user_id: int, livestock_id: int,  session : Session = Depends(get_session)):
    res = del_livestock(session, user_id, livestock_id)

    if res['status']:
        return {"success": True, "message":"Livestock Deleted successfully"}
    return {"success": False,"message":"Failed to Delete Livestock"}

@router.delete("/drop/{user_id}")
def _Drop_livestock(user_id: int,  session : Session = Depends(get_session)):
    res = drop_livestock(session,user_id)

    if res['status']:
        return {"success": True, "message":"Livestock Dropped successfully"}
    return {"success": False,"message":"Failed to Drop Livestock"}



    


