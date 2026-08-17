import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/first_access_request.dart';
import '../utils/formatters.dart';
import '../utils/app_colors.dart';

/// Tela de Primeiro Acesso - Design moderno
class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final nomeController = TextEditingController();
    final cpfCnpjController = TextEditingController();
    final foneController = TextEditingController();
    final emailController = TextEditingController();
    final usuarioController = TextEditingController();
    final senhaController = TextEditingController();
    final confirmaSenhaController = TextEditingController();

    final obscurePassword = true.obs;
    final obscureConfirmPassword = true.obs;

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
          child: Column(
            children: [
              // App bar customizada
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const Expanded(
                      child: Text(
                        'Primeiro Acesso',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Ícone + título
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Criar sua conta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Preencha seus dados para começar',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Card com formulário
                      Card(
                        elevation: 12,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Seção: Dados Pessoais
                                _sectionTitle(
                                  icon: Icons.badge,
                                  title: 'Dados Pessoais',
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(height: 12),

                                // Nome completo
                                TextFormField(
                                  controller: nomeController,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Nome completo*',
                                    hint: 'Ex: João da Silva',
                                    icon: Icons.person_outline,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Nome é obrigatório';
                                    }
                                    if (value.trim().length < 3) {
                                      return 'Nome muito curto';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // CPF/CNPJ
                                TextFormField(
                                  controller: cpfCnpjController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'CPF / CNPJ*',
                                    hint: 'Apenas números',
                                    icon: Icons.document_scanner_outlined,
                                  ),
                                  onChanged: (value) {
                                    final formatted =
                                        Formatters.formatCpfCnpj(value);
                                    if (formatted != value) {
                                      cpfCnpjController.value =
                                          TextEditingValue(
                                        text: formatted,
                                        selection: TextSelection.collapsed(
                                          offset: formatted.length,
                                        ),
                                      );
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'CPF/CNPJ é obrigatório';
                                    }
                                    final numbers = value
                                        .replaceAll(RegExp(r'[^0-9]'), '');
                                    if (numbers.length != 11 &&
                                        numbers.length != 14) {
                                      return 'CPF deve ter 11 ou CNPJ 14 dígitos';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Telefone
                                TextFormField(
                                  controller: foneController,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Telefone',
                                    hint: '(00) 00000-0000',
                                    icon: Icons.phone_outlined,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Email
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Email*',
                                    hint: 'seu@email.com',
                                    icon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email é obrigatório';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Email inválido';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Seção: Dados de Acesso
                                _sectionTitle(
                                  icon: Icons.lock_outline,
                                  title: 'Dados de Acesso',
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 12),

                                // Nome de usuário
                                TextFormField(
                                  controller: usuarioController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    label: 'Nome de usuário*',
                                    hint: '3 a 20 caracteres',
                                    icon: Icons.alternate_email,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Usuário é obrigatório';
                                    }
                                    if (value.length < 3) {
                                      return 'Mínimo 3 caracteres';
                                    }
                                    if (value.length > 20) {
                                      return 'Máximo 20 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Senha
                                Obx(() => TextFormField(
                                      controller: senhaController,
                                      obscureText: obscurePassword.value,
                                      textInputAction: TextInputAction.next,
                                      decoration: _inputDecoration(
                                        label: 'Senha*',
                                        hint: 'Mínimo 6 caracteres',
                                        icon: Icons.lock_outline,
                                        suffix: IconButton(
                                          icon: Icon(
                                            obscurePassword.value
                                                ? Icons
                                                    .visibility_off_outlined
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
                                          return 'Senha é obrigatória';
                                        }
                                        if (value.length < 6) {
                                          return 'Mínimo 6 caracteres';
                                        }
                                        return null;
                                      },
                                    )),
                                const SizedBox(height: 12),

                                // Confirmar senha
                                Obx(() => TextFormField(
                                      controller: confirmaSenhaController,
                                      obscureText:
                                          obscureConfirmPassword.value,
                                      textInputAction: TextInputAction.done,
                                      decoration: _inputDecoration(
                                        label: 'Confirmar senha*',
                                        hint: 'Repita a senha',
                                        icon: Icons.lock_outline,
                                        suffix: IconButton(
                                          icon: Icon(
                                            obscureConfirmPassword.value
                                                ? Icons
                                                    .visibility_off_outlined
                                                : Icons.visibility_outlined,
                                          ),
                                          onPressed: () {
                                            obscureConfirmPassword.value =
                                                !obscureConfirmPassword.value;
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Confirme a senha';
                                        }
                                        if (value != senhaController.text) {
                                          return 'As senhas não conferem';
                                        }
                                        return null;
                                      },
                                    )),

                                const SizedBox(height: 16),

                                // Mensagem de erro
                                Obx(() {
                                  if (controller.errorMessage.value
                                      .isNotEmpty) {
                                    return _messageBanner(
                                      message: controller.errorMessage.value,
                                      isError: true,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),

                                // Mensagem de sucesso
                                Obx(() {
                                  if (controller.isSuccess.value) {
                                    return _messageBanner(
                                      message:
                                          'Cadastro realizado! Faça login para continuar.',
                                      isError: false,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),

                                const SizedBox(height: 8),

                                // Botão cadastrar
                                Obx(() => SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : () async {
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  controller.clearError();
                                                  controller.isSuccess.value =
                                                      false;

                                                  final cpfCnpjLimpo =
                                                      cpfCnpjController.text
                                                          .replaceAll(
                                                              RegExp(
                                                                  r'[^0-9]'),
                                                              '');
                                                  final foneLimpo =
                                                      foneController.text
                                                          .replaceAll(
                                                              RegExp(
                                                                  r'[^0-9]'),
                                                              '');

                                                  final request =
                                                      FirstAccessRequest(
                                                    nome: nomeController.text
                                                        .trim(),
                                                    cpfCnpj: cpfCnpjLimpo,
                                                    fone: foneLimpo.isEmpty
                                                        ? null
                                                        : foneLimpo,
                                                    email: emailController.text
                                                        .trim(),
                                                    nomeUsuario:
                                                        usuarioController.text
                                                            .trim(),
                                                    senha: senhaController.text,
                                                  );

                                                  final ok =
                                                      await controller.register(
                                                          request);
                                                  if (ok) {
                                                    await Future.delayed(
                                                        const Duration(
                                                            seconds: 2));
                                                    Get.offAllNamed('/login');
                                                  }
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          elevation: 3,
                                          shadowColor:
                                              AppColors.shadowLight,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: controller.isLoading.value
                                            ? const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Text('Cadastrando...'),
                                                ],
                                              )
                                            : const Text(
                                                'Criar cadastro',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    )),

                                const SizedBox(height: 8),

                                // Já tem conta? Voltar para login
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text(
                                    'Já tem conta? Fazer login',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: color.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
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
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 14,
      ),
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