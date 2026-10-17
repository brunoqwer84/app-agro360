import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../models/animal.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../utils/constants.dart';

/// Formulário de Animal (criar/editar)
class AnimalFormView extends StatefulWidget {
  const AnimalFormView({super.key});

  @override
  State<AnimalFormView> createState() => _AnimalFormViewState();
}

class _AnimalFormViewState extends State<AnimalFormView> {
  final _formKey = GlobalKey<FormState>();

  late final AnimalController _controller;
  late final TextEditingController _identificacaoController;
  late final TextEditingController _dataNascimentoController;

  final _sexo = RxString(AppConstants.sexoMacho);
  final _tipoProducao = RxString(AppConstants.producaoLeite);
  final _status = RxString(AppConstants.statusAtivo);
  final _idPropriedade = Rxn<int>();
  final _idRaca = Rxn<int>();

  DateTime? _dataNascimento;

  Animal? _args;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AnimalController>();
    _args = Get.arguments as Animal?;
    _isEdit = _args != null;

    _dataNascimento = _args?.dataNascimento;
    _identificacaoController =
        TextEditingController(text: _args?.identificacao ?? '');
    _dataNascimentoController = TextEditingController(
      text: _dataNascimento != null
          ? Formatters.formatDate(_dataNascimento!)
          : '',
    );

    final argSexo = _args?.sexo;
    _sexo.value =
        (argSexo == AppConstants.sexoMacho || argSexo == AppConstants.sexoFemea)
            ? argSexo!
            : AppConstants.sexoMacho;

    final argTipoProducao = _args?.tipoProducao;
    _tipoProducao.value = (argTipoProducao == AppConstants.producaoLeite ||
            argTipoProducao == AppConstants.producaoCorte ||
            argTipoProducao == AppConstants.producaoMisto)
        ? argTipoProducao!
        : AppConstants.producaoLeite;

    final argStatus = _args?.status;
    _status.value = (argStatus == AppConstants.statusAtivo ||
            argStatus == AppConstants.statusVendido ||
            argStatus == AppConstants.statusMorto)
        ? argStatus!
        : AppConstants.statusAtivo;

    final idPropriedade = _args?.idPropriedade ?? 0;
    _idPropriedade.value = idPropriedade > 0 ? idPropriedade : null;

    final idRaca = _args?.idRaca ?? 0;
    _idRaca.value = idRaca > 0 ? idRaca : null;
  }

  @override
  void dispose() {
    _identificacaoController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> _selectDataNascimento() async {
    final now = DateTime.now();
    final nascimento = _dataNascimento;
    final initialDate =
        (nascimento != null && nascimento.isBefore(now)) ? nascimento : now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked == null) return;
    _dataNascimento = picked;
    _dataNascimentoController.text = Formatters.formatDate(picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final propriedadeSelecionada = _controller.propriedades
        .firstWhereOrNull((p) => p.idPropriedade == _idPropriedade.value);
    final racaSelecionada =
        _controller.racas.firstWhereOrNull((r) => r.idRaca == _idRaca.value);

    if (propriedadeSelecionada == null || racaSelecionada == null) {
      Get.snackbar(
        'Atenção',
        'Selecione uma opção válida',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final animal = Animal(
      idAnimal: _isEdit ? _args!.idAnimal : 0,
      identificacao: _identificacaoController.text.trim(),
      sexo: _sexo.value,
      dataNascimento: _dataNascimento,
      tipoProducao: _tipoProducao.value,
      status: _status.value,
      propriedade: propriedadeSelecionada,
      raca: racaSelecionada,
    );

    if (_isEdit) {
      await _controller.updateAnimal(_args!.idAnimal, animal);
    } else {
      await _controller.create(animal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Animal' : 'Novo Animal'),
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
                              _isEdit ? 'Editar Animal' : 'Novo Animal',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isEdit
                                  ? 'Atualize as informações do animal'
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
                  AppInput(
                    label: 'Identificação *',
                    hint: 'Ex: 001',
                    controller: _identificacaoController,
                    icon: Icons.tag,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Identificação é obrigatória';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => AppDropdown<String>(
                      label: 'Sexo',
                      hint: 'Selecione',
                      items: const [
                        DropdownMenuItem(
                            value: AppConstants.sexoMacho,
                            child: Text('Macho')),
                        DropdownMenuItem(
                            value: AppConstants.sexoFemea,
                            child: Text('Fêmea')),
                      ],
                      value: _sexo.value,
                      onChanged: (v) {
                        if (v != null) _sexo.value = v;
                      },
                      prefixIcon: Icons.pets,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    label: 'Data de Nascimento',
                    hint: 'Selecione a data',
                    controller: _dataNascimentoController,
                    readOnly: true,
                    onTap: _selectDataNascimento,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDataNascimento,
                    ),
                    validator: (value) {
                      final data = _dataNascimento;
                      if (data == null) return null;
                      if (data.isAfter(DateTime.now())) {
                        return 'Data de nascimento não pode ser futura';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => AppDropdown<String>(
                      label: 'Tipo de Produção',
                      hint: 'Selecione',
                      items: const [
                        DropdownMenuItem(
                            value: AppConstants.producaoLeite,
                            child: Text('Leite')),
                        DropdownMenuItem(
                            value: AppConstants.producaoCorte,
                            child: Text('Corte')),
                        DropdownMenuItem(
                            value: AppConstants.producaoMisto,
                            child: Text('Misto')),
                      ],
                      value: _tipoProducao.value,
                      onChanged: (v) {
                        if (v != null) _tipoProducao.value = v;
                      },
                      prefixIcon: Icons.agriculture,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(
                    () => AppDropdown<String>(
                      label: 'Status',
                      hint: 'Selecione',
                      items: const [
                        DropdownMenuItem(
                            value: AppConstants.statusAtivo,
                            child: Text('Ativo')),
                        DropdownMenuItem(
                            value: AppConstants.statusVendido,
                            child: Text('Vendido')),
                        DropdownMenuItem(
                            value: AppConstants.statusMorto,
                            child: Text('Morto')),
                      ],
                      value: _status.value,
                      onChanged: (v) {
                        if (v != null) _status.value = v;
                      },
                      prefixIcon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() {
                    final propriedades = _controller.propriedades;
                    final idSelecionado = propriedades
                            .any((p) => p.idPropriedade == _idPropriedade.value)
                        ? _idPropriedade.value
                        : null;
                    return AppDropdown<int>(
                      label: 'Propriedade *',
                      hint: _controller.carregandoDropdowns.value
                          ? 'Carregando...'
                          : 'Selecione',
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
                  Obx(() {
                    final racas = _controller.racas;
                    final idSelecionado =
                        racas.any((r) => r.idRaca == _idRaca.value)
                            ? _idRaca.value
                            : null;
                    return AppDropdown<int>(
                      label: 'Raça *',
                      hint: _controller.carregandoDropdowns.value
                          ? 'Carregando...'
                          : 'Selecione',
                      items: racas
                          .map((r) => DropdownMenuItem(
                                value: r.idRaca,
                                child: Text(r.descricao),
                              ))
                          .toList(),
                      value: idSelecionado,
                      onChanged: (v) {
                        if (v != null) _idRaca.value = v;
                      },
                      enabled: racas.isNotEmpty,
                      prefixIcon: Icons.pets,
                      validator: (value) {
                        if (value == null || value <= 0) {
                          return 'Raça é obrigatória';
                        }
                        return null;
                      },
                    );
                  }),
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
