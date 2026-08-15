import 'dart:math' as math;

import 'package:flutter/material.dart';

import './models/crop_model.dart';

class CropChart extends StatelessWidget {
  const CropChart({super.key, required this.crops});

  final List<CropRecord> crops;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crop yield trends',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Expected vs actual yield (kg/ha)'),
          const SizedBox(height: 8),
          Row(
            children: const [
              _Legend(color: Colors.green, label: 'Expected'),
              SizedBox(width: 12),
              _Legend(color: Colors.amber, label: 'Actual'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _YieldTrendPainter(crops),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _YieldTrendPainter extends CustomPainter {
  _YieldTrendPainter(this.crops);

  final List<CropRecord> crops;

  @override
  void paint(Canvas canvas, Size size) {
    if (crops.isEmpty) return;

    final expectedValues = crops
        .map((crop) => crop.expectedYieldKgPerHa.toDouble())
        .toList();
    final actualValues = crops
        .map((crop) => crop.actualYieldKgPerHa.toDouble())
        .toList();
    final allValues = [...expectedValues, ...actualValues];
    final maxValue = _roundedMaximum(
      allValues.reduce((first, second) => math.max(first, second)),
    );

    const left = 56.0, top = 18.0, right = 16.0, bottom = 60.0;
    final plot = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );

    final gridPaint = Paint()..color = Colors.grey.withValues(alpha: 0.3);
    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 1.2;
    final expectedPaint = Paint()
      ..color = Colors.green.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final actualPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var tick = 0; tick <= 4; tick++) {
      final y = plot.bottom - plot.height * tick / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final value = (maxValue * (4 - tick) / 4).round();
      _drawText(
        canvas,
        value.toString(),
        Offset(0, y - 8),
        width: left - 10,
        align: TextAlign.right,
      );
    }

    canvas.drawLine(plot.bottomLeft, plot.topLeft, axisPaint);
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axisPaint);

    final points = <Offset>[];
    for (var index = 0; index < crops.length; index++) {
      final x = crops.length == 1
          ? plot.center.dx
          : plot.left + plot.width * index / (crops.length - 1);
      points.add(Offset(x, plot.bottom));
    }

    final expectedPoints = <Offset>[];
    final actualPoints = <Offset>[];
    for (var index = 0; index < crops.length; index++) {
      final x = crops.length == 1
          ? plot.center.dx
          : plot.left + plot.width * index / (crops.length - 1);
      final expectedY =
          plot.bottom - (expectedValues[index] / maxValue) * plot.height;
      final actualY =
          plot.bottom - (actualValues[index] / maxValue) * plot.height;
      expectedPoints.add(Offset(x, expectedY));
      actualPoints.add(Offset(x, actualY));
    }

    if (expectedPoints.length > 1) {
      final path = Path()
        ..moveTo(expectedPoints.first.dx, expectedPoints.first.dy);
      for (final point in expectedPoints.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, expectedPaint);
    }

    if (actualPoints.length > 1) {
      final path = Path()..moveTo(actualPoints.first.dx, actualPoints.first.dy);
      for (final point in actualPoints.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, actualPaint);
    }

    for (var index = 0; index < expectedPoints.length; index++) {
      final expectedPoint = expectedPoints[index];
      final actualPoint = actualPoints[index];
      canvas.drawCircle(
        expectedPoint,
        4,
        Paint()..color = Colors.green.shade700,
      );
      canvas.drawCircle(actualPoint, 4, Paint()..color = Colors.amber.shade700);

      _drawText(
        canvas,
        expectedValues[index].round().toString(),
        Offset(expectedPoint.dx - 18, expectedPoint.dy - 22),
        width: 44,
        align: TextAlign.center,
        color: Colors.green.shade800,
        weight: FontWeight.w600,
      );
      _drawText(
        canvas,
        actualValues[index].round().toString(),
        Offset(actualPoint.dx - 18, actualPoint.dy - 22),
        width: 44,
        align: TextAlign.center,
        color: Colors.amber.shade900,
        weight: FontWeight.w600,
      );

      final label = crops[index].name;
      _drawText(
        canvas,
        label,
        Offset(points[index].dx - 32, plot.bottom + 10),
        width: 64,
        align: TextAlign.center,
      );
    }

    _drawText(
      canvas,
      'Yield (kg/ha)',
      const Offset(6, 0),
      width: 54,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      'Crop',
      Offset(plot.center.dx - 22, size.height - 28),
      width: 44,
      align: TextAlign.center,
    );
  }

  double _roundedMaximum(double value) {
    final step = value <= 100
        ? 20.0
        : value <= 1000
        ? 100.0
        : 500.0;
    return math.max(step, (value / step).ceil() * step).toDouble();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double width,
    TextAlign align = TextAlign.left,
    Color color = Colors.black87,
    FontWeight weight = FontWeight.normal,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _YieldTrendPainter oldDelegate) =>
      oldDelegate.crops != crops;
}
