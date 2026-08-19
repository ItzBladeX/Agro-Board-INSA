from pydantic import BaseModel, field_validator, Field
from datetime import date


class BaseUser(BaseModel):

    username: str = Field(min_length = 4, max_length = 25)   
    first_name: str = Field(min_length = 1, max_length = 60)
    middle_name: str = Field(min_length = 1, max_length = 60)
    last_name: str = Field(min_length = 1, max_length = 60)

    birth_date: date| None = None
    age: int | None = Field(default=None, ge=0, le=120)

    gender: str | None = Field(min_length = 1, max_length = 1, default = None)

    server_id : str| None = None
    user_id: str| None = None
    
    land_area: float| None = None

class CreateUserRequest(BaseUser):
    passwd: str
    phone_number: str

    #phone number validation
    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str):
        pass
        if not value.isdigit():
            raise ValueError("Phone number must contain only digits")
        if len(value) != 10:
            raise ValueError("Phone number must contain 10 digits")
        if not value.startswith(("09", "07")):
            raise ValueError("Phone number must start with 09 or 07")
        return value

class UpdateUserRequest(BaseUser):
    passwd: str
    phone_number: str

class GetUserResponse(BaseModel):
    id: int
    username: str
    phone_number: str

class UserLogin(BaseModel):
    phone_number: str
    passwd: str
