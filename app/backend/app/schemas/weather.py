from pydantic import BaseModel, Field

class GetWeatherResponse(BaseModel):
    temperature: float | None = None
    rainfall: float | None = None
    windspeed: float | None = None
    humidity: float | None = None
    city: str | None = None
    