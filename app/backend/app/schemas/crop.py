from pydantic import BaseModel, Field
from datetime import date

class CreateCropTypeRequest(BaseModel):
    name: str
    growth_month: int = Field(ge=0)

class CropBase(BaseModel):

    name: str = Field(min_length=2, max_length=50)
    
    prod_start_year: int = Field(ge=1900, le=2200)
    prod_end_year: int = Field(ge=1900, le=2200)
    planted_date: date | None = None
    harvest_date: date | None = None

    crop_yield: float | None = None
    prod_cost: float | None = None
    revenue: float | None = None
    profit: float | None = None

    notes: str | None = None

class CreateCropRequest(CropBase):
    user_id: int 
    crop_type_id: int

class UpdateCropRequest(CropBase):
    id: int
    user_id: int 
    crop_type_id: int

class GetCropResponse(CropBase):
    id: int
