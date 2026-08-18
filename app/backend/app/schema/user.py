from pydantic import BaseModel, field_validator, Field
from datetime import date


class BaseUser(BaseModel):

    username: str = Field(min_length=4, max_length=25)
    first_name: str = Field(min_length=1, max_length=60)
    middle_name: str = Field(min_length=1, max_length=60)
    last_name: str = Field(min_length=1, max_length=60)
    phone_number: str = Field(unique=True)
    birth_date: date | None = None
    age: int = Field(ge=0, le=120)
    gender: str = Field(min_length=3, max_length=3, default=None)
    server_id: str | None = None
    user_id: str | None = None
    land_area: float | None = None


class CreateUserRequest(BaseModel):
    username: str = Field(min_length=4, max_length=25)
    first_name: str = Field(min_length=1, max_length=60)
    middle_name: str = Field(min_length=1, max_length=60)
    last_name: str = Field(min_length=1, max_length=60)
    phone_number: str
    passwd: str
    birth_date: date | None = None
    age: int | None = Field(default=None, ge=0, le=120)
    gender: str | None = Field(default=None, min_length=1, max_length=3)
    land_area: float | None = None

    # phone number validation
    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str) -> str:
        if not value.isdigit():
            raise ValueError("Phone number must contain only digits")
        if len(value) != 10:
            raise ValueError("Phone number must contain 10 digits")
        if not value.startswith(("09", "07")):
            raise ValueError("Phone number must start with 09")

        return value


class UpdateUserRequest(BaseModel):
    pass


class GetUserResponse(BaseModel):
    id: int
    username: str
    phone_number: str


# passwd: str


class UserLogin(BaseModel):
    phone_number: str
    passwd: str
