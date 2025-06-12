import 'package:flutter/material.dart';

/// child 주위를 지정한 굵기로 '안쪽'에만 테두리를 그려준다.
class InsetBorder extends StatelessWidget {
  const InsetBorder({
    super.key,
    required this.color,
    required this.width,
    required this.radius,
    required this.child,
    this.backgroundColor = Colors.transparent,
  });

  final Color color;
  final double width;
  final double radius;
  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InsetBorderPainter(color, width, radius),
      child: Container(
        padding: EdgeInsets.all(width), // stroke-width 만큼 내부 여백 확보
        color: backgroundColor,
        child: child,
      ),
    );
  }
}

class _InsetBorderPainter extends CustomPainter {
  const _InsetBorderPainter(this.color, this.strokeWidth, this.radius);

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas c, Size s) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & s,
      Radius.circular(radius),
    ).deflate(strokeWidth); // ← 안쪽으로만 굵기 만큼 축소
    final Paint paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
    c.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _InsetBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius;
}
