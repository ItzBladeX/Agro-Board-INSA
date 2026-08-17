from pydantic import BaseModel, Field
from datetime import date

class BaseUser(BaseModel):

    username: str = Field(min_length = 4, max_length = 25)   
    first_name: str = Field(min_length = 1, max_length = 60)
    middle_name: str = Field(min_length = 1, max_length = 60)
    last_name: str = Field(min_length = 1, max_length = 60)

    email: str

    birth_date: date| None = None
    age: int = Field(ge=0, le=120)

    gender: str = Field(min_length = 3, max_length = 3, default = None)

    server_id : str| None = None
    user_id: str| None = None
    
    land_area: float| None = None


class CreateUserRequest(BaseUser):
    passwd: str

class UpdateUserRequest(BaseUser):
    pass

class GetUserResponse(BaseUser):
    id: int

    # passwd: str

