import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_logo.dart';
import '../utils/app_colors.dart';
import '../theme/app_theme.dart';

/// Tela Splash - tela inicial de carregamento
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _progressController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textOpacity;

  /// Progresso da barra (0.0 a 1.0). É recriado a cada fase e NUNCA regride.
  Animation<double>? _progressAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOut)),
    );

    _startAnimation();
  }

  /// Sequência de fases: logo -> título -> verificação de login -> completo.
  /// A barra avança a cada fase e só chega a 100% quando há resultado,
  /// ao contrário de um repeat(reverse) que enche e volta.
  Future<void> _startAnimation() async {
    // Fase 1: logo (barra avança em paralelo)
    unawaited(_runProgress(0.35, const Duration(milliseconds: 900)));
    await _logoController.forward();

    // Fase 2: título
    unawaited(_runProgress(0.65, const Duration(milliseconds: 500)));
    await _textController.forward();

    // Fase 3: verificação de autenticação (avanço lento até quase o fim,
    // esperando a resposta; se demorar, a barra fica em 90%)
    unawaited(_runProgress(0.9, const Duration(milliseconds: 2500)));
    final isAuthenticated = await _checkAuth();

    // Fase 4: completa e navega
    await _runProgress(1.0, const Duration(milliseconds: 250));
    if (!mounted) return;
    if (isAuthenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Avança a barra do valor atual até [target], sem nunca regredir.
  ///
  /// Chamadas intermediárias são fire-and-forget (unawaited): ao serem
  /// retargetadas, o TickerFuture anterior nunca completa, por isso
  /// apenas a última chamada deve ser aguardada.
  Future<void> _runProgress(double target, Duration duration) {
    final begin = _progressAnimation?.value ?? 0.0;
    _progressAnimation = _progressController.drive(
      Tween<double>(begin: begin, end: target)
          .chain(CurveTween(curve: Curves.easeOut)),
    );
    _progressController.duration = duration;
    return _progressController.forward(from: 0);
  }

  /// Verifica se há sessão salva (token válido).
  Future<bool> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return false;
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put<AuthController>(AuthController(), permanent: true);
    await authController.checkAuthStatus();
    return authController.isAuthenticated.value;
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const Agro360LogoLogin(size: 140),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Título animado
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            'Agro360',
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Gerenciamento Agropecuário',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Progress indicator animado
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.round),
                          child: LinearProgressIndicator(
                            value: _progressAnimation?.value ?? 0.0,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Carregando...',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
