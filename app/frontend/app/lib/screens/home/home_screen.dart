import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().user;

    return Scaffold(
      appBar: AppBar(title: const Text("Agro-Board")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${user?.firstName ?? ''}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Total registered land: ${user?.landArea ?? 0} hectares",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // placeholder for crop/livestock summary cards, built later
            const Expanded(
              child: Center(child: Text("Crop and livestock summaries coming soon")),
            ),
          ],
        ),
      ),
    );
  }
}