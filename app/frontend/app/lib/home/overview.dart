import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OverviewSection extends StatefulWidget {
  const OverviewSection({super.key});

  @override
  State<OverviewSection> createState() => OverviewSectionState();
}

class OverviewSectionState extends State<OverviewSection> {
  static const int userId = 1;

  Future<void> refresh() => _loadOverview();

  Map<String, dynamic> overviewData = {
    "crop_total_revenue": "-",
    "crop_total_profit": "-",
    "livestock_total_revenue": "-",
    "livestock_total_profit": "-",
    "total_profit": "-",
    "total_revenue": "-",
    "total_crops": "-",
    "total_livestock": "-",
  };

  bool isLoading = true;
  String statusMessage = "Loading overview...";

  static const Color leafGreen = Color(0xFF00684A);
  static const Color darkText = Color(0xFF001E2B);

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      isLoading = true;
      statusMessage = "Calling endpoint...";
    });

    final result = await fetchOverview(userId);

    if (!mounted) return;

    setState(() {
      overviewData =
          result['data'] as Map<String, dynamic>;

      statusMessage =
          result['message'] as String;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),

        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(
                color: leafGreen,
              ),
            ),
          )
        else
          _OverviewContent(
            data: overviewData,
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}

Future<Map<String, dynamic>> fetchOverview(
  int userId,
) async {
  Map<String, dynamic> overviewData = {
    "crop_total_revenue": "-",
    "crop_total_profit": "-",
    "livestock_total_revenue": "-",
    "livestock_total_profit": "-",
    "total_profit": "-",
    "total_revenue": "-",
    "total_crops": "-",
    "total_livestock": "-",
  };

  String message = "Unknown status";

  try {
    final url =
        "http://127.0.0.1:8000/overview/$userId";

    print("→ Hitting endpoint: $url");

    final res = await http.get(
      Uri.parse(url),
    );

    print("← Status code: ${res.statusCode}");
    print("← Body: ${res.body}");

    if (res.statusCode == 200) {
      final decoded =
          jsonDecode(res.body) as Map<String, dynamic>;

      if (decoded['success'] == true &&
          decoded['data'] != null) {
        overviewData =
            decoded['data'] as Map<String, dynamic>;

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
    "data": overviewData,
    "message": message,
  };
}

class _OverviewContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const _OverviewContent({
    required this.data,
  });

  static const Color leafGreen = Color(0xFF00684A);
  static const Color darkText = Color(0xFF001E2B);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Economics",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Total Revenue",
                value:
                    "${NumberFormat.compact().format(data['total_revenue'])} ETB",
                icon: Icons.trending_up,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _StatCard(
                title: "Total Profit",
                value:
                    "${NumberFormat.compact().format(data['total_profit'])} ETB",
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          "Crop",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Revenue",
                value:
                    "${NumberFormat.compact().format(data['crop_total_revenue'])} ETB",
                icon: Icons.trending_up,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _StatCard(
                title: "Profit",
                value:
                    "${NumberFormat.compact().format(data['crop_total_profit'])} ETB",
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _StatCard(
          title: "Total Crops",
          value:
              "${NumberFormat.compact().format(data['total_crops'])}",
          icon: Icons.grass,
        ),

        const SizedBox(height: 20),

        const Text(
          "Livestock",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: "Revenue",
                value:
                    "${NumberFormat.compact().format(data['livestock_total_revenue'])} ETB",
                icon: Icons.trending_up,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: _StatCard(
                title: "Profit",
                value:
                    "${NumberFormat.compact().format(data['livestock_total_profit'])} ETB",
                icon: Icons.attach_money,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        _StatCard(
          title: "Total Livestock",
          value:
              "${NumberFormat.compact().format(data['total_livestock'])}",
          icon: Icons.pets,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  static const Color leafGreen = Color(0xFF00684A);
  static const Color darkText = Color(0xFF001E2B);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF9FBFA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: leafGreen,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}