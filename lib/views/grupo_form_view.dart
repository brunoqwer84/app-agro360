import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/grupo_controller.dart';
import '../models/grupo.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Formulário de Grupo/Empresa (criar/editar)
class GrupoFormView extends StatefulWidget {
  const GrupoFormView({super.key});

  @override
  State<GrupoFormView> createState() => _GrupoFormViewState();
}

class _GrupoFormViewState extends State<GrupoFormView> {
  final _formKey = GlobalKey<FormState>();
  late final Grupo? _grupo;
  late final GrupoController _controller;
  late final TextEditingController _nomeController;
  late final TextEditingController _cnpjController;
  late bool _ativo;

  bool get _isEdit => _grupo != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<GrupoController>();
    _grupo = Get.arguments as Grupo?;
    _nomeController = TextEditingController(text: _grupo?.nome ?? '');
    _cnpjController = TextEditingController(text: _grupo?.cnpj ?? '');
    _ativo = _grupo?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  void _onCnpjChanged(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 14) {
      final formatted = Formatters.formatCnpj(digits);
      _cnpjController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final cnpjDigits = _cnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');

    final grupo = Grupo(
      idGrupo: _isEdit ? _grupo!.idGrupo : 0,
      nome: _nomeController.text.trim(),
      cnpj: cnpjDigits.isEmpty ? null : cnpjDigits,
      ativo: _ativo,
    );

    if (_isEdit) {
      await _controller.updateGrupo(_grupo!.idGrupo, grupo);
    } else {
      final ok = await _controller.create(grupo);
      if (ok) {
        _nomeController.clear();
        _cnpjController.clear();
        setState(() => _ativo = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Editar Grupo' : 'Novo Grupo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: AppCard(
                  padding: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              _isEdit
                                  ? Icons.edit_outlined
                                  : Icons.business_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit ? 'Editar Grupo' : 'Novo Grupo',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _isEdit
                                      ? 'Atualize os dados da empresa/grupo'
                                      : 'Cadastre um novo grupo ou cooperativa',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Nome
                      AppInput(
                        label: 'Nome do grupo/empresa *',
                        hint: 'Ex: Agropecuária Santa Maria Ltda',
                        controller: _nomeController,
                        icon: Icons.business,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nome é obrigatório';
                          }
                          if (value.trim().length < 2) {
                            return 'Nome muito curto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // CNPJ
                      AppInput(
                        label: 'CNPJ (opcional)',
                        hint: '00.000.000/0000-00',
                        controller: _cnpjController,
                        icon: Icons.badge,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: _onCnpjChanged,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final digits =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length != 14) {
                            return 'CNPJ deve ter 14 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Switch ativo
                      SwitchListTile(
                        title: const Text('Grupo ativo'),
                        subtitle: Text(
                          _ativo ? 'Disponível para uso' : 'Desativado',
                        ),
                        value: _ativo,
                        onChanged: (value) => setState(() => _ativo = value),
                        activeThumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primaryContainer,
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Botões
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Obx(
                            () => AppButton.primary(
                              label: _isEdit ? 'Atualizar' : 'Criar',
                              onPressed: _controller.isLoading.value
                                  ? null
                                  : _salvar,
                              isLoading: _controller.isLoading.value,
                              size: AppButtonSize.large,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton.outline(
                            label: 'Cancelar',
                            onPressed: Get.back,
                            size: AppButtonSize.large,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
