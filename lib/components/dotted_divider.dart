import 'package:flutter/material.dart';

class DottedDivider extends StatelessWidget {
  const DottedDivider({
    super.key,
    this.height = 1,
    this.dotWidth = 4,
    this.gap = 4,
    this.color,
    this.thickness = 1,
  });

  final double height;
  final double dotWidth;
  final double gap;
  final Color? color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).dividerColor;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _DottedDividerPainter(
          color: c,
          dotWidth: dotWidth,
          gap: gap,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _DottedDividerPainter extends CustomPainter {
  _DottedDividerPainter({
    required this.color,
    required this.dotWidth,
    required this.gap,
    required this.thickness,
  });

  final Color color;
  final double dotWidth;
  final double gap;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
          Offset(x, y), Offset((x + dotWidth).clamp(0, size.width), y), paint);
      x += dotWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedDividerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dotWidth != dotWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.thickness != thickness;
  }
}
