from pydantic import BaseModel, Field

class GetWeatherResponse(BaseModel):
    temperature: float
    humidity: float
    precipitation: float
    windspeed: float
    station: str
    