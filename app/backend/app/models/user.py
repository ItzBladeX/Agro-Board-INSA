from sqlmodel import SQLModel, Field
from datetime import date

class User(SQLModel, table=True):
    __table_args__ = {'extend_existing': True}
    id : int | None = Field(default=None, primary_key=True)
    username: str
    name: str

    birth_date: date | None = Field(default=None)
    age: int | None = Field(default = None)

    gender: str | None = Field(default = None)

    server_id : str | None = Field(default = None)
    user_id: str | None = Field(default = None)
    
    land_area: float | None = Field(default = None)
    passwd: str
