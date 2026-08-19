from pydantic import BaseModel, Field
from datetime import date

class BaseUser(BaseModel):

    username: str = Field(min_length = 4, max_length = 25)   
    first_name: str = Field(min_length = 1, max_length = 60)
    middle_name: str = Field(min_length = 1, max_length = 60)
    last_name: str = Field(min_length = 1, max_length = 60)

    phone_number: str

    birth_date: date| None = None
    age: int | None = Field(default=None, ge=0, le=120)

    gender: str | None = Field(min_length = 1, max_length = 1, default = None)

    server_id : str| None = None
    user_id: str| None = None
    
    land_area: float| None = None


class CreateUserRequest(BaseUser):
    passwd: str

class UpdateUserRequest(BaseUser):
    passwd: str

class GetUserResponse(BaseUser):
    id: int

    # passwd: str

