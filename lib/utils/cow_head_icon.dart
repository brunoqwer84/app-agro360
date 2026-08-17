import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ícone de cabeça de vaca rústico, sem preenchimento de cor
class CowHeadIcon extends StatelessWidget {
  final double size;
  final Color color;

  const CowHeadIcon({
    super.key,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CowHeadPainter(color: color),
    );
  }
}

class _CowHeadPainter extends CustomPainter {
  final Color color;

  _CowHeadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final faceWidth = w * 0.55;
    final faceHeight = h * 0.5;
    final faceLeft = cx - faceWidth / 2;
    final faceTop = cy - faceHeight * 0.3;

    // Preenchimento do rosto
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(faceLeft, faceTop, faceWidth, faceHeight),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(faceRect, fillPaint);
    canvas.drawRRect(faceRect, paint);

    // Chifres
    final hornLength = size.width * 0.18;
    final hornWidth = size.width * 0.08;

    final pathLeftHorn = Path()
      ..moveTo(faceLeft + faceWidth * 0.2, faceTop)
      ..lineTo(faceLeft + faceWidth * 0.2 - hornWidth, faceTop - hornLength)
      ..lineTo(faceLeft + faceWidth * 0.2 + hornWidth * 1.5, faceTop)
      ..close();
    canvas.drawPath(pathLeftHorn, paint);

    final pathRightHorn = Path()
      ..moveTo(faceLeft + faceWidth * 0.8, faceTop)
      ..lineTo(faceLeft + faceWidth * 0.8 + hornWidth, faceTop - hornLength)
      ..lineTo(faceLeft + faceWidth * 0.8 - hornWidth * 1.5, faceTop)
      ..close();
    canvas.drawPath(pathRightHorn, paint);

    // Orelhas
    final earSize = size.width * 0.15;
    canvas.drawOval(
      Rect.fromLTWH(
        faceLeft - earSize * 0.8,
        faceTop + faceHeight * 0.25,
        earSize,
        earSize * 0.7,
      ),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
        faceLeft + faceWidth - earSize * 0.2,
        faceTop + faceHeight * 0.25,
        earSize,
        earSize * 0.7,
      ),
      paint,
    );

    // Olhos
    final eyeRadius = size.width * 0.04;
    final eyeY = faceTop + faceHeight * 0.35;
    canvas.drawCircle(Offset(faceLeft + faceWidth * 0.3, eyeY), eyeRadius, paint);
    canvas.drawCircle(Offset(faceLeft + faceWidth * 0.7, eyeY), eyeRadius, paint);

    // Nariz / focinho
    final noseWidth = size.width * 0.18;
    final noseHeight = size.width * 0.12;
    final noseY = faceTop + faceHeight * 0.65;
    canvas.drawOval(
      Rect.fromLTWH(
        cx - noseWidth / 2,
        noseY - noseHeight / 2,
        noseWidth,
        noseHeight,
      ),
      paint,
    );

    // Boca / sorriso
    final smilePath = Path()
      ..moveTo(cx - noseWidth * 0.5, noseY + noseHeight * 0.7)
      ..quadraticBezierTo(
        cx,
        noseY + noseHeight * 1.6,
        cx + noseWidth * 0.5,
        noseY + noseHeight * 0.7,
      );
    canvas.drawPath(smilePath, paint);

    // Pintas rusticas (leves)
    final spotPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(faceLeft + faceWidth * 0.25, faceTop + faceHeight * 0.5),
      size.width * 0.05,
      spotPaint,
    );
    canvas.drawCircle(
      Offset(faceLeft + faceWidth * 0.7, faceTop + faceHeight * 0.4),
      size.width * 0.06,
      spotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}