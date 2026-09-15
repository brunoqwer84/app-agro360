import 'dart:math';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Ícone de trator estilizado — silhueta simples e reconhecível.
class TractorIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TractorIcon({
    super.key,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TractorPainter(color: color),
    );
  }
}

class _TractorPainter extends CustomPainter {
  final Color color;

  _TractorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = color;
    final darkPaint = Paint()..color = color.withValues(alpha: 0.75);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // === CABINE (estrutura superior com janelas) ===
    final cabinPath = Path()
      ..moveTo(w * 0.30, h * 0.50)
      ..lineTo(w * 0.30, h * 0.18)
      ..lineTo(w * 0.42, h * 0.12)
      ..lineTo(w * 0.78, h * 0.12)
      ..lineTo(w * 0.78, h * 0.50)
      ..close();
    canvas.drawPath(cabinPath, bodyPaint);
    canvas.drawPath(cabinPath, strokePaint);

    // Janela da cabine
    final windowPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final windowPath = Path()
      ..moveTo(w * 0.36, h * 0.46)
      ..lineTo(w * 0.36, h * 0.22)
      ..lineTo(w * 0.44, h * 0.18)
      ..lineTo(w * 0.74, h * 0.18)
      ..lineTo(w * 0.74, h * 0.46)
      ..close();
    canvas.drawPath(windowPath, windowPaint);

    // Pilar central da cabine
    canvas.drawLine(
      Offset(w * 0.55, h * 0.18),
      Offset(w * 0.55, h * 0.46),
      strokePaint,
    );

    // === CORPO / CAPÔ (parte frontal mais baixa) ===
    final hoodPath = Path()
      ..moveTo(w * 0.78, h * 0.40)
      ..lineTo(w * 0.92, h * 0.40)
      ..lineTo(w * 0.92, h * 0.55)
      ..lineTo(w * 0.78, h * 0.55)
      ..close();
    canvas.drawPath(hoodPath, bodyPaint);
    canvas.drawPath(hoodPath, strokePaint);

    // Farol frontal
    final lightPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(Offset(w * 0.92, h * 0.47), w * 0.025, lightPaint);
    canvas.drawCircle(Offset(w * 0.92, h * 0.47), w * 0.025, strokePaint);

    // === CHAMINÉ (escape) ===
    final chimneyPath = Path()
      ..moveTo(w * 0.82, h * 0.40)
      ..lineTo(w * 0.82, h * 0.20)
      ..lineTo(w * 0.86, h * 0.20)
      ..lineTo(w * 0.86, h * 0.40)
      ..close();
    canvas.drawPath(chimneyPath, darkPaint);

    // === CHASSI / BASE (une cabine ao solo) ===
    final chassisPath = Path()
      ..moveTo(w * 0.20, h * 0.55)
      ..lineTo(w * 0.92, h * 0.55)
      ..lineTo(w * 0.92, h * 0.62)
      ..lineTo(w * 0.20, h * 0.62)
      ..close();
    canvas.drawPath(chassisPath, darkPaint);

    // === RODA TRASEIRA GRANDE ===
    final rearRadius = h * 0.22;
    final rearCenter = Offset(w * 0.32, h * 0.78);
    canvas.drawCircle(rearCenter, rearRadius, darkPaint);
    canvas.drawCircle(rearCenter, rearRadius * 0.55, bodyPaint);
    canvas.drawCircle(rearCenter, rearRadius * 0.20, darkPaint);

    // Raios da roda traseira
    final spokePaint = Paint()
      ..color = darkPaint.color
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      canvas.drawLine(
        Offset(
          rearCenter.dx + rearRadius * 0.25 * cos(angle),
          rearCenter.dy + rearRadius * 0.25 * sin(angle),
        ),
        Offset(
          rearCenter.dx + rearRadius * 0.85 * cos(angle),
          rearCenter.dy + rearRadius * 0.85 * sin(angle),
        ),
        spokePaint,
      );
    }

    // === RODA DIANTEIRA PEQUENA ===
    final frontRadius = h * 0.13;
    final frontCenter = Offset(w * 0.78, h * 0.78);
    canvas.drawCircle(frontCenter, frontRadius, darkPaint);
    canvas.drawCircle(frontCenter, frontRadius * 0.55, bodyPaint);
    canvas.drawCircle(frontCenter, frontRadius * 0.20, darkPaint);

    // Raios da roda dianteira
    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 + 45) * pi / 180;
      canvas.drawLine(
        Offset(
          frontCenter.dx + frontRadius * 0.30 * cos(angle),
          frontCenter.dy + frontRadius * 0.30 * sin(angle),
        ),
        Offset(
          frontCenter.dx + frontRadius * 0.85 * cos(angle),
          frontCenter.dy + frontRadius * 0.85 * sin(angle),
        ),
        spokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ícone de lavoura — feixe de espigas de trigo/milho.
/// Representa plantação/colheita (área agrícola do agro).
class WheatIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WheatIcon({
    super.key,
    this.size = 40,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WheatPainter(color: color),
    );
  }
}

class _WheatPainter extends CustomPainter {
  final Color color;

  _WheatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = color;
    final lightPaint = Paint()..color = color.withValues(alpha: 0.55);
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // 5 hastes em leque (-40°, -20°, 0°, +20°, +40°), partindo da base.
    final angles = [-40.0, -20.0, 0.0, 20.0, 40.0];
    final xs = [0.28, 0.38, 0.50, 0.62, 0.72];

    for (var i = 0; i < angles.length; i++) {
      final angleDeg = angles[i];
      final angleRad = angleDeg * pi / 180;
      final baseX = w * xs[i];
      final baseY = h * 0.95;
      final stalkLen = h * 0.78;

      final tipX = baseX + stalkLen * sin(angleRad);
      final tipY = baseY - stalkLen * cos(angleRad);

      // Haste (caule)
      canvas.drawLine(Offset(baseX, baseY), Offset(tipX, tipY), strokePaint);

      // Espiga (cabeça do grão) - oval alongado na ponta
      final headW = w * 0.085;
      final headH = h * 0.18;

      canvas.save();
      canvas.translate(tipX, tipY);
      canvas.rotate(angleRad);

      // Corpo da espiga
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: headW,
          height: headH,
        ),
        bodyPaint,
      );

      // Grãos (linhas horizontais que sugerem os grãos na espiga)
      final grainPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round;

      for (var g = 0; g < 4; g++) {
        final gy = -headH / 2 + (g + 1) * (headH / 5);
        canvas.drawLine(
          Offset(-headW / 2 + headW * 0.15, gy),
          Offset(headW / 2 - headW * 0.15, gy),
          grainPaint,
        );
      }

      // Arista (filamento fino saindo do topo da espiga)
      canvas.drawLine(
        Offset.zero,
        Offset(w * 0.10 * sin(angleRad), -h * 0.10),
        strokePaint,
      );

      canvas.restore();
    }

    // Folha à esquerda na base (detalhe de vegetação)
    final leafPath = Path()
      ..moveTo(w * 0.10, h * 0.90)
      ..quadraticBezierTo(w * 0.20, h * 0.80, w * 0.30, h * 0.92)
      ..close();
    canvas.drawPath(leafPath, lightPaint);

    // Folha à direita na base
    final leafPath2 = Path()
      ..moveTo(w * 0.90, h * 0.90)
      ..quadraticBezierTo(w * 0.80, h * 0.80, w * 0.70, h * 0.92)
      ..close();
    canvas.drawPath(leafPath2, lightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
