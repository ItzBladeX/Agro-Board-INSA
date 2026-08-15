import 'dart:math' as math;

import 'package:flutter/material.dart';

import './models/livestock_model.dart';

class LivestockChart extends StatelessWidget {
  const LivestockChart({super.key, required this.livestock});

  final List<LivestockRecord> livestock;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Livestock output trends',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Daily output and feed demand by species'),
          const SizedBox(height: 8),
          Row(
            children: [
              const _Legend(color: Colors.orange, label: 'Output'),
              const SizedBox(width: 12),
              const _Legend(color: Colors.blue, label: 'Feed'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: CustomPaint(
              painter: _OutputTrendPainter(livestock),
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

class _OutputTrendPainter extends CustomPainter {
  _OutputTrendPainter(this.livestock);

  final List<LivestockRecord> livestock;

  @override
  void paint(Canvas canvas, Size size) {
    if (livestock.isEmpty) return;

    final outputValues = livestock
        .map((record) => record.outputLitersPerDay.toDouble())
        .toList();
    final feedValues = livestock
        .map((record) => record.feedKgPerDay.toDouble())
        .toList();
    final allValues = [...outputValues, ...feedValues];
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
    final outputPaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final feedPaint = Paint()
      ..color = Colors.blue.shade700
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

    final xPoints = <Offset>[];
    final outputPoints = <Offset>[];
    final feedPoints = <Offset>[];

    for (var index = 0; index < livestock.length; index++) {
      final x = livestock.length == 1
          ? plot.center.dx
          : plot.left + plot.width * index / (livestock.length - 1);
      xPoints.add(Offset(x, plot.bottom));
      outputPoints.add(
        Offset(x, plot.bottom - (outputValues[index] / maxValue) * plot.height),
      );
      feedPoints.add(
        Offset(x, plot.bottom - (feedValues[index] / maxValue) * plot.height),
      );
    }

    if (outputPoints.length > 1) {
      final path = Path()..moveTo(outputPoints.first.dx, outputPoints.first.dy);
      for (final point in outputPoints.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, outputPaint);
    }

    if (feedPoints.length > 1) {
      final path = Path()..moveTo(feedPoints.first.dx, feedPoints.first.dy);
      for (final point in feedPoints.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, feedPaint);
    }

    for (var index = 0; index < outputPoints.length; index++) {
      final outputPoint = outputPoints[index];
      final feedPoint = feedPoints[index];
      canvas.drawCircle(
        outputPoint,
        4,
        Paint()..color = Colors.orange.shade700,
      );
      canvas.drawCircle(feedPoint, 4, Paint()..color = Colors.blue.shade700);

      _drawText(
        canvas,
        outputValues[index].toStringAsFixed(1),
        Offset(outputPoint.dx - 18, outputPoint.dy - 22),
        width: 36,
        align: TextAlign.center,
        color: Colors.orange.shade900,
        weight: FontWeight.w600,
      );
      _drawText(
        canvas,
        feedValues[index].toStringAsFixed(1),
        Offset(feedPoint.dx - 18, feedPoint.dy - 22),
        width: 36,
        align: TextAlign.center,
        color: Colors.blue.shade900,
        weight: FontWeight.w600,
      );

      final label = livestock[index].species;
      _drawText(
        canvas,
        label,
        Offset(xPoints[index].dx - 26, plot.bottom + 10),
        width: 52,
        align: TextAlign.center,
      );
    }

    _drawText(
      canvas,
      'Value',
      const Offset(10, 0),
      width: 34,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      'Species',
      Offset(plot.center.dx - 24, size.height - 28),
      width: 48,
      align: TextAlign.center,
    );
  }

  double _roundedMaximum(double value) {
    final step = value <= 20
        ? 5.0
        : value <= 100
        ? 20.0
        : 100.0;
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
  bool shouldRepaint(covariant _OutputTrendPainter oldDelegate) =>
      oldDelegate.livestock != livestock;
}
