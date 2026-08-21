import geocoder, requests
from app.schemas import GetWeatherResponse
# from cache3 import LazyCache

# cache = LazyCache()
# @cache.memoize(timeout = 1800)
def get_weather():
    raw = fetch_weather()
    if raw is None:
        return {"status": False, "error_code": "[API Timed Out]", "data": None}
    
    return {"status": True, "error_code": None, "data": perse_weather(raw)}

def fetch_weather():
    print("Before")
    try:
        lat, lon = geocoder.ip('me').latlng
        url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m"

        
        print("Your approximate location (latitude, longitude):", lat, lon)
        response = requests.get(url, timeout=10)
        print("After")
        data = response.json()
        return data
    
    except Exception as e:
        print(f"Error fetching weather: {e}")
        return None
    
def perse_weather(raw):
    geo = geocoder.ip('me')
    data = {
        "temperature" : round(raw["current"]["temperature_2m"],2),
        "rainfall" : round(raw["current"]['precipitation'],2),
        "windspeed" : round(raw["current"]["wind_speed_10m"],2),
        "city" : geo.city if geo else None,
        "humidity": round(raw['current']['relative_humidity_2m'],2)
        }
    
    return GetWeatherResponse.model_validate(data)
    



