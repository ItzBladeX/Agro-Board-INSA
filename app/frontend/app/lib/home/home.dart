import 'package:flutter/material.dart';
import '../weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final data = await weatherService.getWeather();
    setState(() {
      weatherData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: weatherData == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Temperature: ${weatherData!['temperature']}°C'),
                  Text('Humidity: ${weatherData!['humidity']}%'),
                  Text('Precipitation: ${weatherData!['precipitation']}mm'),
                  Text('Wind Speed: ${weatherData!['windSpeed']} m/s'),
                ],
              ),
      ),
    );
  }
}