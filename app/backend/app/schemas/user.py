from pydantic import BaseModel, field_validator, Field
from datetime import date
from app.models import UserRole


class BaseUser(BaseModel):
    username: str = Field(min_length=4, max_length=25)
    first_name: str = Field(min_length=1, max_length=60)
    middle_name: str = Field(min_length=1, max_length=60)
    last_name: str = Field(min_length=1, max_length=60)
    phone_number: str | None = None
    birth_date: date | None = None
    age: int | None = Field(default=None, ge=0, le=120)
    gender: str | None = Field(default=None, min_length=1, max_length=1)
    server_id: str | None = None
    user_id: str | None = None
    land_area: float | None = None

    @field_validator("phone_number")
    @classmethod
    def validate_phone_number(cls, value: str | None) -> str | None:
        if value is None:
            return value
        if not value.isdigit():
            raise ValueError("Phone number must contain only digits")
        if len(value) != 10:
            raise ValueError("Phone number must contain 10 digits")
        if not value.startswith(("09", "07")):
            raise ValueError("Phone number must start with 09 or 07")
        return value


class CreateUserRequest(BaseUser):
    phone_number: str   # required on create — overrides BaseUser's optional
    passwd: str


class UpdateUserRequest(BaseUser):
    username: str | None = Field(default=None, min_length=4, max_length=25)
    first_name: str | None = Field(default=None, min_length=1, max_length=60)
    middle_name: str | None = Field(default=None, min_length=1, max_length=60)
    last_name: str | None = Field(default=None, min_length=1, max_length=60)
    passwd: str | None = None


class GetUserResponse(BaseUser):
    id: int
    role: str
    is_active: bool


class UserLogin(BaseModel):
    phone_number: str
    passwd: str