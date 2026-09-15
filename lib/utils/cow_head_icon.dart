import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ícone de cabeça de vaca estilizado e amigável.
/// Renderizado com formas preenchidas (não contorno) para visual mais polido.
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
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = color;
    final whitePaint = Paint()..color = Colors.white;
    final blackPaint = Paint()..color = const Color(0xFF1A1A1A);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // === ORELHAS (preenchidas com cor principal) ===
    final leftEar = Path()
      ..moveTo(w * 0.30, h * 0.30)
      ..lineTo(w * 0.10, h * 0.08)
      ..lineTo(w * 0.34, h * 0.18)
      ..close();
    canvas.drawPath(leftEar, bodyPaint);

    final rightEar = Path()
      ..moveTo(w * 0.70, h * 0.30)
      ..lineTo(w * 0.90, h * 0.08)
      ..lineTo(w * 0.66, h * 0.18)
      ..close();
    canvas.drawPath(rightEar, bodyPaint);

    // === ROSTO (retângulo arredondado branco) ===
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.22, w * 0.64, h * 0.66),
      Radius.circular(w * 0.20),
    );
    canvas.drawRRect(faceRect, whitePaint);
    canvas.drawRRect(faceRect, strokePaint);

    // === PINTAS características (manchas escuras no corpo) ===
    canvas.drawOval(
      Rect.fromLTWH(w * 0.20, h * 0.30, w * 0.14, h * 0.10),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.64, h * 0.36, w * 0.14, h * 0.10),
      bodyPaint,
    );

    // === OLHOS (pontos pretos) ===
    final eyeW = w * 0.08;
    final eyeH = h * 0.09;
    final eyeY = h * 0.46;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.33 - eyeW / 2, eyeY - eyeH / 2, eyeW, eyeH),
      blackPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.67 - eyeW / 2, eyeY - eyeH / 2, eyeW, eyeH),
      blackPaint,
    );

    // brilho nos olhos
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.34, eyeY - h * 0.01), w * 0.012, highlightPaint);
    canvas.drawCircle(Offset(w * 0.68, eyeY - h * 0.01), w * 0.012, highlightPaint);

    // === FOCINHO (rosado) ===
    final muzzleFill = Paint()..color = const Color(0xFFFFB3C1);
    final muzzleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.62, w * 0.36, h * 0.20),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(muzzleRect, muzzleFill);
    canvas.drawRRect(muzzleRect, strokePaint);

    // === NARINAS (pequenos pontos pretos) ===
    final nostrilW = w * 0.035;
    final nostrilH = h * 0.05;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.43 - nostrilW / 2, h * 0.70 - nostrilH / 2, nostrilW, nostrilH),
      blackPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.57 - nostrilW / 2, h * 0.70 - nostrilH / 2, nostrilW, nostrilH),
      blackPaint,
    );

    // === BOCA (sorriso suave) ===
    final mouthPath = Path()
      ..moveTo(w * 0.43, h * 0.86)
      ..quadraticBezierTo(w * 0.50, h * 0.92, w * 0.57, h * 0.86);
    canvas.drawPath(mouthPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
