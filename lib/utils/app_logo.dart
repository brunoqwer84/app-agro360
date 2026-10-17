import 'dart:math';
import 'package:flutter/material.dart';
import 'agro_icons.dart';
import 'cow_head_icon.dart';

/// Logo Agro360 para Splash — animado, com arcos de sincronização girando
/// e o trator central. Mantido para uso opcional em outras telas de loading.
class Agro360LogoSplash extends StatefulWidget {
  final double size;

  const Agro360LogoSplash({
    super.key,
    this.size = 100,
  });

  @override
  State<Agro360LogoSplash> createState() => _Agro360LogoSplashState();
}

class _Agro360LogoSplashState extends State<Agro360LogoSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: child,
              );
            },
            child: SizedBox(
              width: widget.size * 1.6,
              height: widget.size * 1.6,
              child: CustomPaint(
                painter: _SyncArcsPainter(
                  colors: [
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.85),
                    Colors.white.withValues(alpha: 0.85),
                  ],
                  radiusFactor: 0.86,
                  strokeWidth: 3.5,
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(widget.size * 0.18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TractorIcon(
              size: widget.size * 0.6,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo Agro360 — versão estática usada na Splash e na tela de Login.
/// Conecta visualmente as 3 áreas do agro (Trator, Vaca, Lavoura)
/// em um ciclo 360°, com a marca "360" no centro.
class Agro360LogoLogin extends StatelessWidget {
  final double size;

  const Agro360LogoLogin({
    super.key,
    this.size = 100,
  });

  // Ângulos (em graus) dos 3 ícones, 120° entre si, sentido horário
  static const double _angleTrator = 270; // topo
  static const double _angleVaca = 30; // inferior direita
  static const double _angleLavoura = 150; // inferior esquerda

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fundo com gradiente verde
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),

          // Arcos de sincronização conectando as 3 áreas (ciclo 360°)
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _SyncArcsPainter(
                colors: [
                  const Color(0xFFFFB300)
                      .withValues(alpha: 0.95), // trator (âmbar)
                  const Color(0xFF6D4C41)
                      .withValues(alpha: 0.95), // vaca (marrom)
                  const Color(0xFF66BB6A)
                      .withValues(alpha: 0.95), // lavoura (verde)
                ],
                radiusFactor: 0.48,
                strokeWidth: size * 0.024,
              ),
            ),
          ),

          // Três ícones do agro posicionados em círculo (120° entre si)
          _positionedIcon(
            angleDegrees: _angleTrator,
            child: _iconBadge(
              size: size * 0.26,
              child: TractorIcon(
                  size: size * 0.20, color: const Color(0xFFFFB300)),
            ),
          ),
          _positionedIcon(
            angleDegrees: _angleVaca,
            child: _iconBadge(
              size: size * 0.26,
              child: CowHeadIcon(
                  size: size * 0.22, color: const Color(0xFF6D4C41)),
            ),
          ),
          _positionedIcon(
            angleDegrees: _angleLavoura,
            child: _iconBadge(
              size: size * 0.26,
              child:
                  WheatIcon(size: size * 0.20, color: const Color(0xFF66BB6A)),
            ),
          ),

          // Marca "360" central — reforça o nome do app
          _centerMark(size: size),
        ],
      ),
    );
  }

  Widget _positionedIcon({
    required double angleDegrees,
    required Widget child,
  }) {
    final radius = size * 0.32;
    final angleRad = angleDegrees * pi / 180;
    final dx = radius * cos(angleRad);
    final dy = radius * sin(angleRad);
    final iconSize = size * 0.26;

    return Align(
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: child,
        ),
      ),
    );
  }

  Widget _iconBadge({required double size, required Widget child}) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _centerMark({required double size}) {
    return Container(
      width: size * 0.28,
      height: size * 0.28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE8F5E9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agro',
              style: TextStyle(
                fontSize: size * 0.075,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E7D32),
                height: 1.0,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              '360',
              style: TextStyle(
                fontSize: size * 0.085,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1B5E20),
                height: 1.0,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta 3 arcos curvos com ponta de seta, conectando pontos dispostos
/// a 120° entre si — transmite a ideia de sincronização/ciclo 360°
/// entre as três áreas do agro (trator, animal, lavoura).
class _SyncArcsPainter extends CustomPainter {
  final List<Color> colors;
  final double radiusFactor;
  final double strokeWidth;
  final double gapDegrees;

  _SyncArcsPainter({
    required this.colors,
    this.radiusFactor = 0.5,
    this.strokeWidth = 3,
  }) : gapDegrees = 18;

  static const List<double> _startAngles = [270, 30, 150];
  static const double _sweep = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * radiusFactor;

    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final startDeg = _startAngles[i] + gapDegrees;
      final sweepDeg = _sweep - (gapDegrees * 2);

      final startRad = startDeg * pi / 180;
      final sweepRad = sweepDeg * pi / 180;

      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, startRad, sweepRad, false, paint);

      // Seta na ponta do arco (sentido horário)
      final endRad = startRad + sweepRad;
      final tip = Offset(
        center.dx + radius * cos(endRad),
        center.dy + radius * sin(endRad),
      );

      final tangent = Offset(-sin(endRad), cos(endRad));
      final normal = Offset(cos(endRad), sin(endRad));

      final arrowLength = strokeWidth * 3.2;
      final arrowWidth = strokeWidth * 2.4;

      final backPoint = tip - tangent * arrowLength;
      final left = backPoint + normal * (arrowWidth / 2);
      final right = backPoint - normal * (arrowWidth / 2);

      final arrowPaint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close();

      canvas.drawPath(path, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SyncArcsPainter oldDelegate) {
    return oldDelegate.colors != colors ||
        oldDelegate.radiusFactor != radiusFactor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
