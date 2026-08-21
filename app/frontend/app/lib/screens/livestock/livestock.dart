import 'package:flutter/material.dart';

class LivestockScreen extends StatelessWidget {
  const LivestockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Livestock"),
      ),
      body: const Center(
        child: Text(
          "Livestock Management",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}