from pydantic import BaseModel, Field

class GetWeatherResponse(BaseModel):
    temperature: float
    rainfall: float
    windspeed: float
    city: str
    