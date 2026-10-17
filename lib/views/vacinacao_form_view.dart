import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/vacinacao_controller.dart';
import '../models/animal.dart';
import '../models/manejo.dart';
import '../models/vacinacao.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Formulário de Vacinação (criar/editar)
class VacinacaoFormView extends StatefulWidget {
  const VacinacaoFormView({super.key});

  @override
  State<VacinacaoFormView> createState() => _VacinacaoFormViewState();
}

class _VacinacaoFormViewState extends State<VacinacaoFormView> {
  final _formKey = GlobalKey<FormState>();

  late final VacinacaoController _controller;
  late final ManejoController _manejoController;
  late final AnimalController _animalController;
  late final TextEditingController _nomeController;
  late final TextEditingController _proximaDoseController;

  final _idManejo = Rxn<int>();
  final _idAnimal = Rxn<int>();

  late DateTime _proximaDose;

  Vacinacao? _args;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<VacinacaoController>();
    _manejoController = Get.find<ManejoController>();
    _animalController = Get.find<AnimalController>();
    _args = Get.arguments as Vacinacao?;
    _isEdit = _args != null;

    _proximaDose = _args?.proximaDose ?? DateTime.now();
    _proximaDoseController =
        TextEditingController(text: Formatters.formatDate(_proximaDose));
    _nomeController = TextEditingController(text: _args?.nome ?? '');

    final idManejo = _args?.idManejo ?? 0;
    _idManejo.value = idManejo > 0 ? idManejo : null;

    final idAnimal = _args?.idAnimal ?? 0;
    _idAnimal.value = idAnimal > 0 ? idAnimal : null;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _proximaDoseController.dispose();
    super.dispose();
  }

  Future<void> _selectProximaDose() async {
    final firstDate = DateTime(2000);
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    var initialDate = _proximaDose;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    _proximaDose = picked;
    _proximaDoseController.text = Formatters.formatDate(picked);
  }

  Manejo? get _manejoSelecionado => _manejoController.manejos
      .firstWhereOrNull((m) => m.idManejo == _idManejo.value);

  List<Animal> get _animaisDoManejo {
    final manejo = _manejoSelecionado;
    if (manejo == null) return const [];
    return _animalController.animais
        .where((a) =>
            a.propriedade.idPropriedade == manejo.propriedade?.idPropriedade)
        .toList();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final manejoSelecionado = _manejoSelecionado;
    if (manejoSelecionado == null) {
      Get.snackbar(
        'Atenção',
        'Selecione uma opção válida',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final animaisDoManejo = _animaisDoManejo;
    final animalSelecionado =
        animaisDoManejo.firstWhereOrNull((a) => a.idAnimal == _idAnimal.value);
    if (animalSelecionado == null) {
      Get.snackbar(
        'Atenção',
        animaisDoManejo.isEmpty
            ? 'Nenhum animal nesta propriedade'
            : 'Selecione um animal',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!_proximaDose.isAfter(manejoSelecionado.data)) {
      Get.snackbar(
        'Atenção',
        'A próxima dose deve ser posterior à data do manejo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final vacinacao = Vacinacao(
      idVacinacao: _isEdit ? _args!.idVacinacao : 0,
      manejo: manejoSelecionado,
      animal: animalSelecionado,
      nome: _nomeController.text.trim(),
      proximaDose: _proximaDose,
    );

    if (_isEdit) {
      await _controller.updateVacinacao(_args!.idVacinacao, vacinacao);
    } else {
      await _controller.create(vacinacao);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Vacinação' : 'Nova Vacinação'),
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
                              _isEdit ? 'Editar Vacinação' : 'Nova Vacinação',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isEdit
                                  ? 'Atualize as informações da vacinação'
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
                    final manejos = _manejoController.manejos;
                    final idSelecionado =
                        manejos.any((m) => m.idManejo == _idManejo.value)
                            ? _idManejo.value
                            : null;
                    return AppDropdown<int>(
                      label: 'Manejo *',
                      hint: 'Selecione',
                      items: manejos
                          .map((m) => DropdownMenuItem(
                                value: m.idManejo,
                                child: Text(
                                    '${Formatters.formatDate(m.data)} • ${m.propriedade?.nome ?? ''}'),
                              ))
                          .toList(),
                      value: idSelecionado,
                      onChanged: (v) {
                        if (v != null && v != _idManejo.value) {
                          _idManejo.value = v;
                          _idAnimal.value = null;
                        }
                      },
                      enabled: manejos.isNotEmpty,
                      prefixIcon: Icons.assignment,
                      validator: (value) {
                        if (value == null || value <= 0) {
                          return 'Manejo é obrigatório';
                        }
                        return null;
                      },
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    final manejoSelecionado = _manejoSelecionado;
                    final animaisDoManejo = _animaisDoManejo;
                    final animalSelecionado = animaisDoManejo
                        .firstWhereOrNull((a) => a.idAnimal == _idAnimal.value);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppDropdown<Animal>(
                          key: ValueKey('vacinacao-animal-${_idManejo.value}'),
                          label: 'Animal *',
                          hint: 'Selecione',
                          items: animaisDoManejo
                              .map((a) => DropdownMenuItem(
                                    value: a,
                                    child: Text(a.identificacao),
                                  ))
                              .toList(),
                          value: animalSelecionado,
                          onChanged: (v) {
                            if (v != null) _idAnimal.value = v.idAnimal;
                          },
                          enabled: manejoSelecionado != null &&
                              animaisDoManejo.isNotEmpty,
                          prefixIcon: Icons.pets,
                          validator: (value) {
                            if (value == null) {
                              return 'Animal é obrigatório';
                            }
                            return null;
                          },
                        ),
                        if (manejoSelecionado != null &&
                            animaisDoManejo.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                              left: AppSpacing.md,
                            ),
                            child: Text(
                              'Nenhum animal nesta propriedade',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Nome da Vacina *',
                    hint: 'Ex: Vacina Febre Aftosa',
                    controller: _nomeController,
                    icon: Icons.medication,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome da vacina é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Próxima Dose *',
                    hint: 'Selecione a data',
                    controller: _proximaDoseController,
                    readOnly: true,
                    onTap: _selectProximaDose,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectProximaDose,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Próxima dose é obrigatória';
                      }
                      final manejo = _manejoSelecionado;
                      if (manejo != null &&
                          !_proximaDose.isAfter(manejo.data)) {
                        return 'A próxima dose deve ser posterior à data do manejo';
                      }
                      return null;
                    },
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
