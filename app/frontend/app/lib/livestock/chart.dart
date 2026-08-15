import 'dart:math' as math;

import 'package:flutter/material.dart';

import './models/livestock_model.dart';

class LivestockChart extends StatelessWidget {
  const LivestockChart({super.key, required this.livestock});

  final List<LivestockRecord> livestock;

  @override
  Widget build(BuildContext context) {
    final outputs = livestock
        .map((animal) => animal.outputLitersPerDay)
        .toList();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Livestock output trends',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: CustomPaint(
                painter: _OutputTrendPainter(outputs),
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputTrendPainter extends CustomPainter {
  _OutputTrendPainter(this.outputs);

  final List<double> outputs;

  @override
  void paint(Canvas canvas, Size size) {
    if (outputs.isEmpty) return;

    final line = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final point = Paint()..color = Colors.orange;

    final grid = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1;

    const inset = 20.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    // Draw grid lines
    for (var i = 0; i <= 4; i++) {
      final y = rect.top + rect.height * i / 4;
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), grid);
    }

    // Calculate scale
    final min = outputs.reduce((a, b) => math.min(a, b).toDouble());
    final max = outputs.reduce((a, b) => math.max(a, b).toDouble());
    final range = math.max(max - min, 0.1).toDouble();

    // Calculate points
    final points = <Offset>[
      for (var i = 0; i < outputs.length; i++)
        Offset(
          outputs.length == 1
              ? rect.center.dx
              : rect.left + rect.width * i / (outputs.length - 1),
          rect.bottom - (outputs[i] - min) / range * rect.height,
        ),
    ];

    // Draw line
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final value in points.skip(1)) {
        path.lineTo(value.dx, value.dy);
      }
      canvas.drawPath(path, line);
    }

    // Draw points
    for (final value in points) {
      canvas.drawCircle(value, 4, point);
    }
  }

  @override
  bool shouldRepaint(covariant _OutputTrendPainter oldDelegate) =>
      oldDelegate.outputs != outputs;
}
