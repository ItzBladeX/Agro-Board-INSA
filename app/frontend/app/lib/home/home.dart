import 'package:app/home/overview.dart';
import 'package:app/home/weather.dart';
import 'package:flutter/material.dart';
import 'package:app/home/welcome_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final weatherKey = GlobalKey<WeatherSectionState>();
  final overviewKey = GlobalKey<OverviewSectionState>();

  Future<void> _refreshAll() async {
    await Future.wait([
      weatherKey.currentState?.refresh() ?? Future.value(),
      overviewKey.currentState?.refresh() ?? Future.value(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: const Color(0xFF00684A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeBanner(),
              WeatherSection(key: weatherKey),
              const SizedBox(height: 24),
              OverviewSection(key: overviewKey),
            ],
          ),
        ),
      ),
    );
  }
}
