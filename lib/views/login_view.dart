import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_logo.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Tela de Login - UX/UI moderna com novo conceito 360
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthController controller;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final obscurePassword = true.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put<AuthController>(AuthController(), permanent: true);
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.accent
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo com animação de entrada
                    _AnimatedLogo(),
                    const SizedBox(height: AppSpacing.md),

                    // Título
                    Text(
                      'Agro360',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Visão completa do seu agro',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // Card do formulário
                    _LoginCard(
                      formKey: formKey,
                      usernameController: usernameController,
                      passwordController: passwordController,
                      obscurePassword: obscurePassword,
                      controller: controller,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Primeiro acesso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Primeiro acesso?',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.register),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Criar conta',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Versão
                    Text(
                      'v1.0.0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: const Agro360LogoLogin(size: 120),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.controller,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final RxBool obscurePassword;
  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 30.0, end: 0.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(opacity: 1 - (value / 30), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow,
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Text(
                  'Bem-vindo de volta',
                  style: textTheme.headlineMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Faça login para continuar',
                  style: textTheme.bodyMedium
                      .copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Username
                AppInput(
                  label: 'Usuário',
                  hint: 'seu.usuario',
                  controller: usernameController,
                  icon: Icons.alternate_email,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Digite o nome de usuário';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Senha com toggle
                Obx(() => AppInput(
                      label: 'Senha',
                      hint: '••••••',
                      controller: passwordController,
                      icon: Icons.lock_outline,
                      obscureText: obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            obscurePassword.value = !obscurePassword.value,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a senha';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    )),
                const SizedBox(height: AppSpacing.md),

                // Mensagens (erro/sucesso)
                Obx(() {
                  if (controller.errorMessage.value.isNotEmpty) {
                    return AppMessageBanner(
                      message: controller.errorMessage.value,
                      type: AppMessageType.error,
                      onDismiss: controller.clearError,
                    );
                  }
                  if (controller.isSuccess.value) {
                    return const AppMessageBanner(
                      message: 'Login realizado!',
                      type: AppMessageType.success,
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: AppSpacing.lg),

                // Botão Login
                Obx(() => AppButton.primary(
                      label:
                          controller.isLoading.value ? 'Entrando...' : 'Entrar',
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (formKey.currentState!.validate()) {
                                controller.clearError();
                                await controller.login(
                                  usernameController.text.trim(),
                                  passwordController.text,
                                );
                              }
                            },
                      isLoading: controller.isLoading.value,
                      size: AppButtonSize.large,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
