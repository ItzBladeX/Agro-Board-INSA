import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/core/api_endpoints.dart';

class WeatherSection extends StatefulWidget {
  const WeatherSection({super.key});

  @override
  State<WeatherSection> createState() => WeatherSectionState();
}

class WeatherSectionState extends State<WeatherSection> {

  Future<void> refresh() => _loadWeather();
  Map<String, dynamic> weatherData = {
    "temperature": "-",
    "rainfall": "-",
    "windspeed": "-",
    "city": "-",
    "humidity": "-",
  };


  bool isLoading = true;
  String statusMessage = "Loading weather...";

  // MongoDB Leaf-inspired colors
  static const Color leafGreen = Color(0xFF00684A);
  static const Color softGreen = Color(0xFFE3FCF7);
  static const Color darkText = Color(0xFF001E2B);

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      isLoading = true;
      statusMessage = "Calling endpoint...";
    });

    final result = await fetchWeatherData();

    setState(() {
      weatherData = result['data'] as Map<String, dynamic>;
      statusMessage = result['message'] as String;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status
        // Text(
        //   statusMessage,
        //   style: TextStyle(
        //     color: statusMessage.contains("Error") ||
        //             statusMessage.contains("failed")
        //         ? Colors.red.shade700
        //         : leafGreen,
        //     fontWeight: FontWeight.w500,
        //     fontSize: 13,
        //   ),
        // ),
        const SizedBox(height: 12),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: leafGreen),
            ),
          )
        else
          _WeatherContent(weatherData: weatherData),

        const SizedBox(height: 16),

        // Better refresh button
        // Align(
        //   alignment: Alignment.centerRight,
        //   child: TextButton.icon(
        //     onPressed: isLoading ? null : _loadWeather,
        //     style: TextButton.styleFrom(
        //       foregroundColor: leafGreen,
        //       backgroundColor: softGreen,
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //     icon: const Icon(Icons.refresh, size: 18),
        //     label: const Text(
        //       "Refresh",
        //       style: TextStyle(fontWeight: FontWeight.w600),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

Future<Map<String, dynamic>> fetchWeatherData() async {
  Map<String, dynamic> weatherData = {
    "temperature": "-",
    "rainfall": "-",
    "windspeed": "-",
    "city": "-",
    "humidity": "-",
  };

  String message = "Unknown status";

  try {
    print("→ Hitting endpoint: ${ApiEndpoints.getWeather}");
    final res = await http.get(Uri.parse(ApiEndpoints.getWeather));

    print("← Status code: ${res.statusCode}");
    print("← Body: ${res.body}");

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body) as Map<String, dynamic>;

      if (decoded['success'] == true && decoded['data'] != null) {
        weatherData = decoded['data'] as Map<String, dynamic>;
        message = "Success (${res.statusCode})";
      } else {
        message =
            "Backend error: ${decoded['error_code'] ?? decoded['message'] ?? 'unknown'}";
        print(message);
      }
    } else {
      message = "Server error: ${res.statusCode}";
      print(message);
    }
  } catch (e) {
    message = "Network error: $e";
    print(message);
  }

  return {
    "data": weatherData,
    "message": message,
  };
}

class _WeatherContent extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const _WeatherContent({required this.weatherData});

  static const Color leafGreen = Color(0xFF00684A);
  static const Color darkText = Color(0xFF001E2B);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "${weatherData['city']}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 16),

        WeatherCard(
          data: "${weatherData['temperature']} °C",
          icon: const Icon(Icons.wb_sunny_outlined, size: 36, color: leafGreen),
          text: "Temperature",
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: WeatherCard(
                data: "${weatherData['rainfall']} mm",
                icon: const Icon(Icons.wb_cloudy, size: 28, color: leafGreen),
                text: "Rainfall",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherCard(
                data: "${weatherData['windspeed']} m/s",
                icon: const Icon(Icons.air, size: 28, color: leafGreen),
                text: "Wind",
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: WeatherCard(
                data: "${weatherData['humidity']} %",
                icon: const Icon(Icons.opacity, size: 28, color: leafGreen),
                text: "Humidity",
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class WeatherCard extends StatelessWidget {
  final String data;
  final Icon icon;
  final String text;

  const WeatherCard({
    super.key,
    required this.data,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9FBFA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              data,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF001E2B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}