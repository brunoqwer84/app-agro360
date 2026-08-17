import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/app_logo.dart';
import '../utils/app_colors.dart';

/// Tela de Login - UX/UI moderna com novo conceito 360
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final obscurePassword = true.obs;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary, AppColors.accent],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo com animação
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: const Agro360LogoLogin(size: 120),
                  ),
                  const SizedBox(height: 12),

                  // Título
                  const Text(
                    'Agro360',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visão completa do seu agro',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Card moderno
                  TweenAnimationBuilder<double>(
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
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Cabeçalho
                              const Text(
                                'Bem-vindo de volta',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Faça login para continuar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Username
                              TextFormField(
                                controller: usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  label: 'Usuário',
                                  hint: 'seu.usuario',
                                  icon: Icons.alternate_email,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Digite o nome de usuário';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Senha com toggle
                              Obx(() => TextFormField(
                                    controller: passwordController,
                                    obscureText: obscurePassword.value,
                                    textInputAction: TextInputAction.done,
                                    decoration: _inputDecoration(
                                      label: 'Senha',
                                      hint: '••••••',
                                      icon: Icons.lock_outline,
                                      suffix: IconButton(
                                        icon: Icon(
                                          obscurePassword.value
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        onPressed: () {
                                          obscurePassword.value =
                                              !obscurePassword.value;
                                        },
                                      ),
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
                              const SizedBox(height: 12),

                              // Mensagens (erro/sucesso)
                              Obx(() {
                                if (controller.errorMessage.value.isNotEmpty) {
                                  return _messageBanner(
                                    message: controller.errorMessage.value,
                                    isError: true,
                                  );
                                }
                                if (controller.isSuccess.value) {
                                  return _messageBanner(
                                    message: 'Login realizado!',
                                    isError: false,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              const SizedBox(height: 16),

                              // Botão Login
                              Obx(() => SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: controller.isLoading.value
                                          ? null
                                          : () async {
                                              if (formKey.currentState!
                                                  .validate()) {
                                                controller.clearError();
                                                await controller.login(
                                                  usernameController.text.trim(),
                                                  passwordController.text,
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 3,
                                        shadowColor: AppColors.shadowLight,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: controller.isLoading.value
                                          ? const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child: CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2.5,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text('Entrando...'),
                                              ],
                                            )
                                          : const Text(
                                              'Entrar',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primeiro acesso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Primeiro acesso?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Versão
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }

  Widget _messageBanner({
    required String message,
    required bool isError,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.errorLight.withValues(alpha: 0.1)
            : AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError ? AppColors.error : AppColors.success,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? AppColors.error : AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.error : AppColors.success,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}