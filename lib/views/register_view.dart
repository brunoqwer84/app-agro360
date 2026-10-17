import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/first_access_request.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Tela de Primeiro Acesso - cadastro que cria a conta e um novo grupo
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final AuthController controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cpfCnpjController = TextEditingController();
  final TextEditingController _foneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nomeGrupoController = TextEditingController();
  final TextEditingController _cnpjGrupoController = TextEditingController();
  final TextEditingController _nomePropriedadeController =
      TextEditingController();
  final TextEditingController _nomeUsuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmaSenhaController =
      TextEditingController();

  final RxBool _obscureSenha = true.obs;
  final RxBool _obscureConfirmaSenha = true.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put<AuthController>(AuthController(), permanent: true);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _foneController.dispose();
    _emailController.dispose();
    _nomeGrupoController.dispose();
    _cnpjGrupoController.dispose();
    _nomePropriedadeController.dispose();
    _nomeUsuarioController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  void _applyMask(
    TextEditingController field,
    String Function(String) formatter,
  ) {
    final value = field.text;
    final formatted = formatter(value);
    if (formatted == value) return;
    field.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String? _validateOptionalCnpj(String? value) {
    if (value == null || value.isEmpty) return null;
    final numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.length != 14) return 'CNPJ deve ter 14 dígitos';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    controller.clearError();

    final fone = _foneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final cnpjGrupo =
        _cnpjGrupoController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final nomeGrupo = _nomeGrupoController.text.trim();
    final nomePropriedade = _nomePropriedadeController.text.trim();

    final request = FirstAccessRequest(
      nome: _nomeController.text.trim(),
      cpfCnpj: _cpfCnpjController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      fone: fone.isEmpty ? null : fone,
      email: _emailController.text.trim(),
      nomeUsuario: _nomeUsuarioController.text.trim(),
      senha: _senhaController.text,
      nomeGrupo: nomeGrupo.isEmpty ? null : nomeGrupo,
      cnpjGrupo: cnpjGrupo.isEmpty ? null : cnpjGrupo,
      nomePropriedade: nomePropriedade.isEmpty ? null : nomePropriedade,
    );

    final ok = await controller.register(request);
    if (ok) {
      Get.snackbar(
        'Sucesso',
        'Cadastro realizado! Faça login para continuar.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primeiro Acesso')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppBreakpoints.mobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildDadosPessoaisCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildFazendaCard(context),
                  const SizedBox(height: AppSpacing.md),
                  _buildAcessoCard(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildErrorBanner(),
                  const SizedBox(height: AppSpacing.md),
                  _buildSubmitButton(),
                  const SizedBox(height: AppSpacing.md),
                  _buildLoginLink(context),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person_add_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Criar sua conta',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Preencha seus dados para começar. Um novo grupo será criado para você.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return AppCardSectioned(
      header: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _buildDadosPessoaisCard(BuildContext context) {
    return _buildSectionCard(
      context: context,
      icon: Icons.person_outline,
      title: 'Dados pessoais',
      children: [
        AppInput(
          label: 'Nome completo',
          hint: 'Ex: João da Silva',
          controller: _nomeController,
          icon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              CustomValidators.validateRequired(value, 'Nome'),
        ),
        AppInput(
          label: 'CPF / CNPJ',
          hint: 'Apenas números',
          controller: _cpfCnpjController,
          icon: Icons.document_scanner_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) =>
              _applyMask(_cpfCnpjController, Formatters.formatCpfCnpj),
          validator: CustomValidators.validateCpfCnpj,
        ),
        AppInput(
          label: 'Telefone (opcional)',
          hint: '(00) 00000-0000',
          controller: _foneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) =>
              _applyMask(_foneController, Formatters.formatPhone),
          validator: CustomValidators.validatePhone,
        ),
        AppInput(
          label: 'E-mail',
          hint: 'seu@email.com',
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: CustomValidators.validateEmail,
        ),
      ],
    );
  }

  Widget _buildFazendaCard(BuildContext context) {
    return _buildSectionCard(
      context: context,
      icon: Icons.agriculture_outlined,
      title: 'Sua fazenda/empresa',
      children: [
        AppInput(
          label: 'Nome da fazenda/empresa (opcional)',
          hint: 'Se vazio, usaremos seu nome',
          controller: _nomeGrupoController,
          icon: Icons.business_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        AppInput(
          label: 'CNPJ da fazenda/empresa (opcional)',
          hint: 'Apenas números',
          controller: _cnpjGrupoController,
          icon: Icons.apartment_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) =>
              _applyMask(_cnpjGrupoController, Formatters.formatCnpj),
          validator: _validateOptionalCnpj,
        ),
        AppInput(
          label: 'Nome da propriedade (opcional)',
          hint: 'Ex: Sítio Recanto',
          controller: _nomePropriedadeController,
          icon: Icons.home_work_outlined,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildAcessoCard(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return _buildSectionCard(
      context: context,
      icon: Icons.lock_outline,
      title: 'Acesso',
      children: [
        AppInput(
          label: 'Nome de usuário',
          hint: '3 a 20 caracteres',
          controller: _nomeUsuarioController,
          icon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: CustomValidators.validateUsername,
        ),
        Obx(
          () => AppInput(
            label: 'Senha',
            hint: 'Mínimo 6 caracteres',
            controller: _senhaController,
            icon: Icons.lock_outline,
            obscureText: _obscureSenha.value,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSenha.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _obscureSenha.value = !_obscureSenha.value,
            ),
            validator: CustomValidators.validatePassword,
          ),
        ),
        Obx(
          () => AppInput(
            label: 'Confirmar senha',
            hint: 'Repita a senha',
            controller: _confirmaSenhaController,
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmaSenha.value,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmaSenha.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () =>
                  _obscureConfirmaSenha.value = !_obscureConfirmaSenha.value,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Confirme a senha';
              if (value != _senhaController.text) {
                return 'As senhas não conferem';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Obx(() {
      final message = controller.errorMessage.value;
      if (message.isEmpty) return const SizedBox.shrink();
      return AppMessageBanner(
        message: message,
        type: AppMessageType.error,
        onDismiss: controller.clearError,
      );
    });
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => AppButton.primary(
        label: controller.isLoading.value ? 'Cadastrando...' : 'Criar conta',
        onPressed: _submit,
        isLoading: controller.isLoading.value,
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return Center(
      child: TextButton(
        onPressed: () => Get.toNamed(AppRoutes.login),
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
        child: const Text('Já tem conta? Entrar'),
      ),
    );
  }
}
