import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/raca_controller.dart';
import '../models/raca.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Formulário de Raça (criar/editar)
class RacaFormView extends StatefulWidget {
  const RacaFormView({super.key});

  @override
  State<RacaFormView> createState() => _RacaFormViewState();
}

class _RacaFormViewState extends State<RacaFormView> {
  final _formKey = GlobalKey<FormState>();
  late final Raca? _raca;
  late final RacaController _controller;
  late final TextEditingController _descricaoController;

  bool get _isEdit => _raca != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<RacaController>();
    _raca = Get.arguments as Raca?;
    _descricaoController = TextEditingController(text: _raca?.descricao ?? '');
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final raca = Raca(
      idRaca: _isEdit ? _raca!.idRaca : 0,
      descricao: _descricaoController.text.trim(),
    );

    if (_isEdit) {
      await _controller.updateRaca(_raca!.idRaca, raca);
    } else {
      final ok = await _controller.create(raca);
      if (ok) _descricaoController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Editar Raça' : 'Nova Raça',
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
                              _isEdit ? Icons.edit_outlined : Icons.pets_outlined,
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
                                  _isEdit ? 'Editar Raça' : 'Nova Raça',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _isEdit
                                      ? 'Atualize a descrição da raça'
                                      : 'Cadastre uma nova raça de animal',
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

                      // Input
                      AppInput(
                        label: 'Descrição da raça *',
                        hint: 'Ex: Nelore, Angus, Girolando, Holandês',
                        controller: _descricaoController,
                        icon: Icons.pets,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Descrição é obrigatória';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Botões
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Obx(
                            () => AppButton.primary(
                              label: _isEdit ? 'Atualizar' : 'Criar',
                              onPressed:
                                  _controller.isLoading.value ? null : _salvar,
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
