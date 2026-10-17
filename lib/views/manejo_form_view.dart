import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../models/manejo.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Formulário de Manejo (criar/editar)
class ManejoFormView extends StatefulWidget {
  const ManejoFormView({super.key});

  @override
  State<ManejoFormView> createState() => _ManejoFormViewState();
}

class _ManejoFormViewState extends State<ManejoFormView> {
  final _formKey = GlobalKey<FormState>();

  late final ManejoController _controller;
  late final PropriedadeController _propriedadeController;
  late final TextEditingController _observacaoController;
  late final TextEditingController _dataController;

  final _idPropriedade = Rxn<int>();

  late DateTime _data;

  Manejo? _args;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ManejoController>();
    _propriedadeController = Get.find<PropriedadeController>();
    _args = Get.arguments as Manejo?;
    _isEdit = _args != null;

    _data = _args?.data ?? DateTime.now();
    _dataController = TextEditingController(text: Formatters.formatDate(_data));
    _observacaoController =
        TextEditingController(text: _args?.observacao ?? '');

    final idPropriedade = _args?.idPropriedade ?? 0;
    _idPropriedade.value = idPropriedade > 0 ? idPropriedade : null;
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selectData() async {
    final now = DateTime.now();
    final initialDate = _data.isBefore(now) ? _data : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    _data = picked;
    _dataController.text = Formatters.formatDate(picked);
  }

  Future<void> _submit() async {
    if (_propriedadeController.properties.isEmpty) {
      Get.snackbar(
        'Atenção',
        'Cadastre uma propriedade primeiro',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final propriedadeSelecionada = _propriedadeController.properties
        .firstWhereOrNull((p) => p.idPropriedade == _idPropriedade.value);

    if (propriedadeSelecionada == null) {
      Get.snackbar(
        'Atenção',
        'Selecione uma opção válida',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final observacao = _observacaoController.text.trim();

    final manejo = Manejo(
      idManejo: _isEdit ? _args!.idManejo : 0,
      propriedade: propriedadeSelecionada,
      data: _data,
      observacao: observacao.isEmpty ? null : observacao,
    );

    if (_isEdit) {
      await _controller.updateManejo(_args!.idManejo, manejo);
    } else {
      await _controller.create(manejo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Manejo' : 'Novo Manejo'),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          _isEdit ? Icons.edit_outlined : Icons.add_outlined,
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
                              _isEdit ? 'Editar Manejo' : 'Novo Manejo',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isEdit
                                  ? 'Atualize as informações do manejo'
                                  : 'Preencha os dados para cadastrar',
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
                  Obx(() {
                    final propriedades = _propriedadeController.properties;
                    final idSelecionado = propriedades
                            .any((p) => p.idPropriedade == _idPropriedade.value)
                        ? _idPropriedade.value
                        : null;
                    return AppDropdown<int>(
                      label: 'Propriedade *',
                      hint: 'Selecione',
                      items: propriedades
                          .map((p) => DropdownMenuItem(
                                value: p.idPropriedade,
                                child: Text(p.nome),
                              ))
                          .toList(),
                      value: idSelecionado,
                      onChanged: (v) {
                        if (v != null) _idPropriedade.value = v;
                      },
                      enabled: propriedades.isNotEmpty,
                      prefixIcon: Icons.landscape,
                      validator: (value) {
                        if (value == null || value <= 0) {
                          return 'Propriedade é obrigatória';
                        }
                        return null;
                      },
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Data *',
                    hint: 'Selecione a data',
                    controller: _dataController,
                    readOnly: true,
                    onTap: _selectData,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectData,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Data é obrigatória';
                      }
                      if (_data.isAfter(DateTime.now())) {
                        return 'A data não pode ser futura';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Descrição',
                    hint: 'Detalhes do manejo...',
                    controller: _observacaoController,
                    icon: Icons.description,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(
                        () => AppButton.primary(
                          label: _isEdit ? 'Atualizar' : 'Criar',
                          onPressed:
                              _controller.isLoading.value ? null : _submit,
                          isLoading: _controller.isLoading.value,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton.outline(
                        label: 'Cancelar',
                        onPressed: () => Get.back(),
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
