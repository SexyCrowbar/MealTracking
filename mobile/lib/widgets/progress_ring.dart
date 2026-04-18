import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    required this.subLabel,
    this.size = 200,
    this.strokeWidth = 14,
    this.color,
    this.centerLabelFontSize = 36,
    this.subLabelFontSize = 13,
    this.subLabelColor = const Color(0xFFB8B8B8),
  });

  final double progress; // 0..1
  final String centerLabel;
  final String subLabel;
  final double size;
  final double strokeWidth;
  final Color? color;
  final double centerLabelFontSize;
  final double subLabelFontSize;
  final Color subLabelColor;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final hasSubLabel = subLabel.isNotEmpty;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              color: c,
              backgroundColor: AppColors.input,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: TextStyle(
                  fontSize: centerLabelFontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMain,
                ),
              ),
              if (hasSubLabel) ...[
                const SizedBox(height: 2),
                Text(
                  subLabel,
                  style: TextStyle(
                    fontSize: subLabelFontSize,
                    color: subLabelColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
