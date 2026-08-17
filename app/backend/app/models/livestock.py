from sqlmodel import SQLModel, Field, JSON
from app.models.user import User
from datetime import date

class Livestock(SQLModel, table = True):
    __table_args__ = {'extend_existing': True}
    id: int | None = Field(default=None, primary_key=True)
    user_id : int = Field(foreign_key= 'user.id')
    livestock_type_id: int = Field(foreign_key= 'croptype.id')

    name: str

    prod_start_year: int 
    prod_end_year: int
    entry_date: date | None
    exit_date: date | None
    
    livestock_num: int | None 
    prod_cost: float | None
    revenue: float | None
    profit: float | None
    notes: str | None


class LivestockType(SQLModel, table = True):
    __table_args__ = {'extend_existing': True}
    id : int | None = Field(default=None, primary_key=True)
    name: str = Field(unique = True, index = True)
    
