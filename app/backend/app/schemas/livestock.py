from pydantic import BaseModel, EmailStr, Field
from datetime import date


class CreateLivestockTypeRequest(BaseModel):
    name: str 
    
class LivestockBase(BaseModel):

    name: str = Field(min_length=2, max_length=50)

    prod_start_year: int = Field(ge=1900, le=2200)
    prod_end_year: int = Field(ge=1900, le=2200)
    entry_date: date | None = None
    exit_date: date | None = None
    
    livestock_num: int | None = None
    prod_cost: float | None = None
    revenue: float  | None = None
    profit: float | None = None
    notes: str  | None = None

class CreateLivestockRequest(LivestockBase):
    livestock_type_id: int
    # user_id removed — comes from current_user.id via JWT in the route


class UpdateLivestockRequest(LivestockBase):
    id: int
    livestock_type_id: int
    # user_id removed here too

class GetLivestockResponse(LivestockBase):
    id : int
    user_id : int
    livestock_type_id: int

class GetLivestockTypesResponse(BaseModel):
    id: str
    name: str 
class CreateLivestockTypeRequest(BaseModel):
    name: str
