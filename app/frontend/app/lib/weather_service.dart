import "package:http/http.dart" as http;
import "dart:convert";

class WeatherService {
  Future<Map<String, dynamic>> getWeather() async {
    final response = await http.get(
      Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=8.9806&longitude=38.7578&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
      ),
    );
    final data = jsonDecode(response.body);

    final humidity = data['current']['relative_humidity_2m'];
    final temperature = data['current']['temperature_2m'];
    final precipitation = data['current']['precipitation'];
    final windSpeed = data['current']['wind_speed_10m'];

    return {
      'humidity': humidity,
      'temperature': temperature,
      'precipitation': precipitation,
      'windSpeed': windSpeed,
    }; 
  }
}
