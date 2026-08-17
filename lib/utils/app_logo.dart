import 'dart:math';
import 'package:flutter/material.dart';

/// Logo Agro360 para Splash - trator central com animação de arcos 360°
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
          // Arcos girando indicando sincronização 360°
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

          // Trator central
          Container(
            padding: EdgeInsets.all(widget.size * 0.2),
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
            child: Icon(
              Icons.agriculture,
              size: widget.size * 0.55,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo Agro360 para Login - estático, 360° com as 3 áreas do agro
/// (Trator, Vaca, Lavoura) conectadas por arcos de sincronização
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
          // Círculo de fundo com gradiente
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          ),

          // Arcos de sincronização conectando as 3 áreas (ciclo 360°)
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _SyncArcsPainter(
                colors: [
                  Colors.amber.shade600.withValues(alpha: 0.9),
                  Colors.brown.shade400.withValues(alpha: 0.9),
                  Colors.lightGreen.shade600.withValues(alpha: 0.9),
                ],
                radiusFactor: 0.5,
                strokeWidth: size * 0.022,
              ),
            ),
          ),

          // Três áreas do agro posicionadas em círculo (120° entre si)
          _positionedIcon(
            angleDegrees: _angleTrator,
            child: _centerIcon(
              icon: Icons.agriculture,
              color: Colors.amber.shade700,
            ),
          ),
          _positionedIcon(
            angleDegrees: _angleVaca,
            child: _centerIcon(
              emoji: '🐮',
              color: Colors.brown.shade600,
            ),
          ),
          _positionedIcon(
            angleDegrees: _angleLavoura,
            child: _centerIcon(
              icon: Icons.eco,
              color: Colors.lightGreen.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _positionedIcon({
    required double angleDegrees,
    required Widget child,
  }) {
    final radius = size * 0.30;
    final angleRad = angleDegrees * pi / 180;
    final dx = radius * cos(angleRad);
    final dy = radius * sin(angleRad);
    final iconSize = size * 0.22;

    return Positioned(
      left: size / 2 + dx - iconSize / 2,
      top: size / 2 + dy - iconSize / 2,
      child: child,
    );
  }

  Widget _centerIcon({
    IconData? icon,
    String? emoji,
    required Color color,
  }) {
    final iconSize = size * 0.22;
    return Container(
      width: iconSize,
      height: iconSize,
      padding: EdgeInsets.all(iconSize * 0.16),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: emoji != null
            ? FittedBox(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: iconSize * 0.65),
                ),
              )
            : Icon(icon, size: iconSize * 0.7, color: color),
      ),
    );
  }
}

/// Pinta 3 arcos curvos com ponta de seta, conectando pontos dispostos
/// a 120° entre si — transmite a ideia de sincronização/ciclo 360°
/// entre as três áreas do agro (trator, animal, lavoura).
class _SyncArcsPainter extends CustomPainter {
  final List<Color> colors;
  final double radiusFactor; // proporção do raio do arco em relação ao size
  final double strokeWidth;
  final double gapDegrees;

  _SyncArcsPainter({
    required this.colors,
    this.radiusFactor = 0.5,
    this.strokeWidth = 3,
    this.gapDegrees = 18,
  });

  static const List<double> _startAngles = [270, 30, 150]; // topo, inf-dir, inf-esq
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

      // Seta na ponta do arco, na direção do movimento (sentido horário)
      final endRad = startRad + sweepRad;
      final tip = Offset(
        center.dx + radius * cos(endRad),
        center.dy + radius * sin(endRad),
      );

      // Direção tangente (sentido horário) no ponto final do arco
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