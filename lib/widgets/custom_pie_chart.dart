import 'dart:math';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CustomPieChart extends StatefulWidget {
  final Map<CategoryModel, double> data;
  final String currency;

  const CustomPieChart({
    super.key,
    required this.data,
    required this.currency,
  });

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CustomPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation on data change
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.data.values.fold(0.0, (sum, val) => sum + val);

    if (total == 0) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: Theme.of(context).disabledColor.withOpacity(0.4)),
            const SizedBox(height: 8),
            Text(
              'Sin gastos registrados este mes',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      );
    }

    // Sort categories by amount descending
    final sortedEntries = widget.data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chart
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(160, 160),
                    painter: _DonutChartPainter(
                      data: sortedEntries,
                      total: total,
                      animationValue: _animation.value,
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                  );
                },
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: sortedEntries.take(4).map((entry) {
                    final percentage = (entry.value / total) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      key: ValueKey(entry.key.id),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: entry.key.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (sortedEntries.length > 4) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: sortedEntries.skip(4).map((entry) {
                final percentage = (entry.value / total) * 100;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: entry.key.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key.name} (${percentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<MapEntry<CategoryModel, double>> data;
  final double total;
  final double animationValue;
  final Color backgroundColor;

  _DonutChartPainter({
    required this.data,
    required this.total,
    required this.animationValue,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = radius * 0.35;
    final drawRadius = radius - strokeWidth / 2;

    double startAngle = -pi / 2;

    for (var entry in data) {
      final sweepAngle = (entry.value / total) * 2 * pi * animationValue;

      final paint = Paint()
        ..color = entry.key.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..isAntiAlias = true;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Thin separation lines between slices
      final separatorPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      if (data.length > 1 && animationValue > 0.95) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: drawRadius),
          startAngle,
          0.02, // narrow divider
          false,
          separatorPaint,
        );
      }

      startAngle += (entry.value / total) * 2 * pi;
    }

    // Inner shadow circle (subtle boundary line inside the donut)
    final innerBorderPaint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, drawRadius - strokeWidth / 2, innerBorderPaint);
    canvas.drawCircle(center, drawRadius + strokeWidth / 2, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.data != data ||
        oldDelegate.total != total ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
