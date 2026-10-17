import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/pesagem_controller.dart';
import '../models/animal.dart';
import '../models/manejo.dart';
import '../models/pesagem.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Formulário de Pesagem (criar/editar)
class PesagemFormView extends StatefulWidget {
  const PesagemFormView({super.key});

  @override
  State<PesagemFormView> createState() => _PesagemFormViewState();
}

class _PesagemFormViewState extends State<PesagemFormView> {
  final _formKey = GlobalKey<FormState>();

  late final PesagemController _controller;
  late final ManejoController _manejoController;
  late final AnimalController _animalController;
  late final TextEditingController _pesoController;

  final _idManejo = Rxn<int>();
  final _idAnimal = Rxn<int>();

  Pesagem? _args;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PesagemController>();
    _manejoController = Get.find<ManejoController>();
    _animalController = Get.find<AnimalController>();
    _args = Get.arguments as Pesagem?;
    _isEdit = _args != null;

    _pesoController =
        TextEditingController(text: _args?.pesoKg.toString() ?? '');

    final idManejo = _args?.idManejo ?? 0;
    _idManejo.value = idManejo > 0 ? idManejo : null;

    final idAnimal = _args?.idAnimal ?? 0;
    _idAnimal.value = idAnimal > 0 ? idAnimal : null;
  }

  @override
  void dispose() {
    _pesoController.dispose();
    super.dispose();
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

    final peso =
        double.tryParse(_pesoController.text.trim().replaceAll(',', '.'));
    if (peso == null || peso <= 0) {
      Get.snackbar(
        'Atenção',
        'Peso deve ser maior que zero',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final pesagem = Pesagem(
      idPesagem: _isEdit ? _args!.idPesagem : 0,
      manejo: manejoSelecionado,
      animal: animalSelecionado,
      pesoKg: peso,
    );

    if (_isEdit) {
      await _controller.updatePesagem(_args!.idPesagem, pesagem);
    } else {
      await _controller.create(pesagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Pesagem' : 'Nova Pesagem'),
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
                              _isEdit ? 'Editar Pesagem' : 'Nova Pesagem',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isEdit
                                  ? 'Atualize as informações da pesagem'
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
                          key: ValueKey('pesagem-animal-${_idManejo.value}'),
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
                    label: 'Peso (kg) *',
                    hint: 'Ex: 450.5',
                    controller: _pesoController,
                    icon: Icons.monitor_weight,
                    suffixText: 'kg',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*[.,]?\d{0,2}$')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Peso é obrigatório';
                      }
                      final peso =
                          double.tryParse(value.trim().replaceAll(',', '.'));
                      if (peso == null || peso <= 0) {
                        return 'Peso deve ser maior que zero';
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
