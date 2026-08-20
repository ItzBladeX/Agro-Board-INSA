import 'package:app/home/overview.dart';
import 'package:app/home/weather.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Keep the keys if you still want them
  final weatherKey = GlobalKey<WeatherSectionState>();
  final overviewKey = GlobalKey<OverviewSectionState>();

  bool _isRefreshing = false;

  Future<void> _refreshAll() async {
    if (_isRefreshing) return;          // prevent double-tap spam
    setState(() => _isRefreshing = true);

    try {
      await Future.wait([
        weatherKey.currentState?.refresh() ?? Future.value(),
        overviewKey.currentState?.refresh() ?? Future.value(),
      ]);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WeatherSection(key: weatherKey),
            const SizedBox(height: 24),
            OverviewSection(key: overviewKey),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isRefreshing ? null : _refreshAll,
        backgroundColor: const Color(0xFF00684A), // MongoDB Leaf green
        foregroundColor: Colors.white,
        child: _isRefreshing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}