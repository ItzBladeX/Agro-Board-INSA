from pydantic import BaseModel, field_validator, Field
from datetime import date
from app.models import UserRole



class UserLogin(BaseModel):
    phone_number: str
    passwd: str

#admin-part
class AdminUserView(BaseModel):
    id: int
    username: str
    first_name: str
    middle_name: str
    last_name: str
    phone_number: str
    role: UserRole
    is_active: bool


class UserRoleUpdate(BaseModel):
    role: UserRole
