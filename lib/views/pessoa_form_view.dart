import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/pessoa_controller.dart';
import '../models/endereco_pessoa.dart';
import '../models/pessoa.dart';
import '../services/api_service.dart';
import '../services/cep_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Formulário de Cliente / Fornecedor / Pessoa (criar/editar)
class PessoaFormView extends StatefulWidget {
  const PessoaFormView({super.key});

  @override
  State<PessoaFormView> createState() => _PessoaFormViewState();
}

class _PessoaFormViewState extends State<PessoaFormView> {
  final _formKey = GlobalKey<FormState>();
  late final Pessoa? _pessoa;
  late final PessoaController _controller;
  final ApiService _apiService =
      Get.isRegistered<ApiService>() ? Get.find<ApiService>() : ApiService();
  final CepService _cepService = CepService();

  late final TextEditingController _nomeController;
  late final TextEditingController _cpfCnpjController;
  late final TextEditingController _foneController;
  late final TextEditingController _emailController;

  // Controladores de Endereço (opcional)
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  final FocusNode _numeroFocusNode = FocusNode();
  String? _uf;
  late bool _mostrarEndereco;
  bool _isBuscandoCep = false;
  List<String> _cidadesDoEstado = [];
  bool _isCarregandoCidades = false;

  late bool _ativo;
  late String _tipo; // 'C' (Cliente), 'F' (Fornecedor), 'A' (Ambos)

  bool get _isEdit => _pessoa != null;

  String get _papelLabel {
    if (_tipo == 'C') return 'Cliente';
    if (_tipo == 'F') return 'Fornecedor';
    return 'Cliente / Fornecedor';
  }

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<PessoaController>()
        ? Get.find<PessoaController>()
        : Get.put<PessoaController>(PessoaController());

    final args = Get.arguments;
    if (args is Pessoa) {
      _pessoa = args;
      _tipo = args.tipo;
    } else if (args is Map) {
      _pessoa = args['pessoa'] as Pessoa?;
      _tipo = _pessoa?.tipo ?? (args['initialTipo'] as String? ?? 'A');
    } else {
      _pessoa = null;
      _tipo = 'A';
    }

    _nomeController = TextEditingController(text: _pessoa?.nome ?? '');
    _cpfCnpjController = TextEditingController(
      text: _pessoa != null ? Formatters.formatCpfCnpj(_pessoa!.cpfCnpj) : '',
    );
    _foneController = TextEditingController(
      text: _pessoa?.fone != null ? Formatters.formatPhone(_pessoa!.fone!) : '',
    );
    _emailController = TextEditingController(text: _pessoa?.email ?? '');
    _ativo = _pessoa?.ativo ?? true;

    // Inicialização do endereço
    final end = _pessoa?.endereco;
    _cepController = TextEditingController(
      text: end?.cep != null ? Formatters.formatCep(end!.cep!) : '',
    );
    _logradouroController = TextEditingController(text: end?.logradouro ?? '');
    _numeroController = TextEditingController(text: end?.numero ?? '');
    _complementoController = TextEditingController(text: end?.complemento ?? '');
    _bairroController = TextEditingController(text: end?.bairro ?? '');
    _cidadeController = TextEditingController(text: end?.cidade ?? '');
    _uf = (end?.uf != null && end!.uf!.trim().isNotEmpty)
        ? end.uf!.trim().toUpperCase()
        : null;
    _mostrarEndereco = end != null && end.hasEndereco;

    if (_uf != null && _uf!.isNotEmpty) {
      _carregarCidades(_uf!, manterCidadeAtual: true);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _foneController.dispose();
    _emailController.dispose();

    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _numeroFocusNode.dispose();
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

  String? _validateOptionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return CustomValidators.validateEmail(value);
  }

  /// Carrega a lista de municípios para a UF selecionada (via tabela municipio do banco de dados Agro360)
  Future<void> _carregarCidades(String uf, {bool manterCidadeAtual = false}) async {
    setState(() => _isCarregandoCidades = true);
    try {
      final cidades = await _apiService.getMunicipiosPorUf(uf);
      if (mounted) {
        setState(() {
          _cidadesDoEstado = cidades;
          if (!manterCidadeAtual && _cidadeController.text.isNotEmpty) {
            final exists = cidades.any(
              (c) => c.toLowerCase() == _cidadeController.text.trim().toLowerCase(),
            );
            if (!exists) {
              _cidadeController.clear();
            }
          }
        });
      }
    } catch (_) {
      // Ignora falha silenciosa
    } finally {
      if (mounted) {
        setState(() => _isCarregandoCidades = false);
      }
    }
  }

  /// Consulta CEP automaticamente via ViaCEP (com fallback para BrasilAPI)
  Future<void> _consultarCep(String cep, {bool showMessage = true}) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) {
      if (showMessage) {
        Get.snackbar(
          'CEP Incompleto',
          'Informe os 8 dígitos do CEP para realizar a busca',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    setState(() => _isBuscandoCep = true);
    try {
      final result = await _cepService.buscarCep(cleanCep);
      if (result != null) {
        setState(() {
          if (result.logradouro.isNotEmpty) {
            _logradouroController.text = result.logradouro;
          }
          if (result.bairro.isNotEmpty) {
            _bairroController.text = result.bairro;
          }
          if (result.cidade.isNotEmpty) {
            _cidadeController.text = result.cidade;
          }
          if (result.uf.isNotEmpty && AppConstants.ufs.contains(result.uf)) {
            _uf = result.uf;
            _carregarCidades(result.uf, manterCidadeAtual: true);
          }
          if (result.complemento.isNotEmpty &&
              _complementoController.text.trim().isEmpty) {
            _complementoController.text = result.complemento;
          }
        });

        // Direciona o foco para o número automaticamente
        _numeroFocusNode.requestFocus();

        Get.snackbar(
          'Endereço Localizado',
          '${result.cidade}/${result.uf} preenchido via consulta de CEP',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else if (showMessage) {
        Get.snackbar(
          'CEP não localizado',
          'Não encontramos o endereço para o CEP informado. Preencha manualmente.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
      if (showMessage) {
        Get.snackbar(
          'Erro na busca',
          'Não foi possível consultar o CEP no momento. Verifique a internet.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBuscandoCep = false);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final cpfCnpjDigits =
        _cpfCnpjController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final foneDigits = _foneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final emailTrimmed = _emailController.text.trim();

    // Endereço opcional
    EnderecoPessoa? endereco;
    final cepDigits = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (_mostrarEndereco &&
        (cepDigits.isNotEmpty ||
            _logradouroController.text.trim().isNotEmpty ||
            _numeroController.text.trim().isNotEmpty ||
            _complementoController.text.trim().isNotEmpty ||
            _bairroController.text.trim().isNotEmpty ||
            _cidadeController.text.trim().isNotEmpty ||
            (_uf != null && _uf!.isNotEmpty))) {
      endereco = EnderecoPessoa(
        idEnderecoPessoa: _pessoa?.endereco?.idEnderecoPessoa,
        cep: cepDigits.isEmpty ? null : cepDigits,
        logradouro: _logradouroController.text.trim().isEmpty
            ? null
            : _logradouroController.text.trim(),
        numero: _numeroController.text.trim().isEmpty
            ? null
            : _numeroController.text.trim(),
        complemento: _complementoController.text.trim().isEmpty
            ? null
            : _complementoController.text.trim(),
        bairro: _bairroController.text.trim().isEmpty
            ? null
            : _bairroController.text.trim(),
        cidade: _cidadeController.text.trim().isEmpty
            ? null
            : _cidadeController.text.trim(),
        uf: _uf,
      );
    }

    final pessoa = Pessoa(
      idPessoa: _isEdit ? _pessoa!.idPessoa : 0,
      nome: _nomeController.text.trim(),
      cpfCnpj: cpfCnpjDigits,
      fone: foneDigits.isEmpty ? null : foneDigits,
      email: emailTrimmed.isEmpty ? null : emailTrimmed,
      ativo: _ativo,
      tipo: _tipo,
      endereco: endereco,
    );

    if (_isEdit) {
      await _controller.updatePessoa(_pessoa!.idPessoa, pessoa);
    } else {
      await _controller.create(pessoa);
    }
  }

  Widget _buildEnderecoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Endereço (Opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Localização ou sede para entregas e faturamento',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _mostrarEndereco = !_mostrarEndereco;
                    if (!_mostrarEndereco) {
                      _cepController.clear();
                      _logradouroController.clear();
                      _numeroController.clear();
                      _complementoController.clear();
                      _bairroController.clear();
                      _cidadeController.clear();
                      _cidadesDoEstado.clear();
                      _uf = null;
                    }
                  });
                },
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _mostrarEndereco
                          ? Icons.remove_circle_outline_rounded
                          : Icons.add_circle_outline_rounded,
                      size: 14,
                      color:
                          _mostrarEndereco ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _mostrarEndereco ? 'Remover' : 'Adicionar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _mostrarEndereco
                            ? AppColors.error
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_mostrarEndereco) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),

            // CEP com busca automática e botão de consulta
            AppInput(
              label: 'CEP',
              hint: '00000-000',
              controller: _cepController,
              icon: Icons.map_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (val) {
                _applyMask(
                  _cepController,
                  Formatters.formatCep,
                );
                final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.length == 8 && !_isBuscandoCep) {
                  _consultarCep(digits, showMessage: false);
                }
              },
              suffixIcon: _isBuscandoCep
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      tooltip: 'Consultar CEP (ViaCEP)',
                      onPressed: () =>
                          _consultarCep(_cepController.text, showMessage: true),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Logradouro (Rua, Avenida, Rodovia)
            AppInput(
              label: 'Logradouro / Rua / Rodovia',
              hint: 'Ex: Av. Goiás, Rodovia GO-060 km 12',
              controller: _logradouroController,
              icon: Icons.signpost_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // Número e Complemento
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppInput(
                    label: 'Número',
                    hint: 'S/N, 100',
                    controller: _numeroController,
                    focusNode: _numeroFocusNode,
                    icon: Icons.numbers_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: AppInput(
                    label: 'Complemento',
                    hint: 'Apto, Galpão',
                    controller: _complementoController,
                    icon: Icons.apartment_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Bairro
            AppInput(
              label: 'Bairro / Distrito / Setor',
              hint: 'Ex: Centro, Setor Bueno, Zona Rural',
              controller: _bairroController,
              icon: Icons.holiday_village_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),

            // UF e Cidade (UF primeiro para definir a lista de municípios correspondentes)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 95,
                  child: AppDropdown<String?>(
                    label: 'UF',
                    value: _uf,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: 10,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('UF', overflow: TextOverflow.ellipsis),
                      ),
                      ...AppConstants.ufs.map(
                        (uf) => DropdownMenuItem<String?>(
                          value: uf,
                          child: Text(uf, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _uf = val;
                      });
                      if (val != null && val.isNotEmpty) {
                        _cidadeController.clear();
                        _carregarCidades(val, manterCidadeAtual: false);
                      } else {
                        setState(() {
                          _cidadesDoEstado = [];
                          _cidadeController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildCidadeField(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCidadeField() {
    return InkWell(
      onTap: _abrirSeletorCidade,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: IgnorePointer(
        child: AppInput(
          label: 'Cidade',
          hint: _uf == null ? 'Selecione a UF' : 'Selecione a cidade',
          controller: _cidadeController,
          icon: Icons.location_city_outlined,
          readOnly: true,
          suffixIcon: _isCarregandoCidades
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
        ),
      ),
    );
  }

  void _abrirSeletorCidade() {
    if (_uf == null || _uf!.isEmpty) {
      Get.snackbar(
        'Selecione o Estado (UF)',
        'Escolha primeiro o estado para carregar os municípios correspondentes.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CidadePickerSheet(
        uf: _uf!,
        cidadeAtual: _cidadeController.text.trim(),
        cidades: _cidadesDoEstado,
        apiService: _apiService,
        onSelecionarCidade: (cidade) {
          setState(() {
            _cidadeController.text = cidade;
          });
        },
      ),
    );
  }

  Widget _buildTipoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Papel no Módulo Financeiro *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              // Cliente
              _buildTipoOption(
                label: 'Cliente',
                code: 'C',
                icon: Icons.person_rounded,
                selectedColor: AppColors.success,
              ),
              // Fornecedor
              _buildTipoOption(
                label: 'Fornecedor',
                code: 'F',
                icon: Icons.local_shipping_outlined,
                selectedColor: AppColors.categoryOrange,
              ),
              // Ambos
              _buildTipoOption(
                label: 'Ambos',
                code: 'A',
                icon: Icons.swap_horiz_rounded,
                selectedColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipoOption({
    required String label,
    required String code,
    required IconData icon,
    required Color selectedColor,
  }) {
    final isSelected = _tipo == code;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tipo = code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Editar $_papelLabel' : 'Novo $_papelLabel',
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
                              color: AppColors.info.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              _isEdit
                                  ? Icons.edit_outlined
                                  : Icons.person_add_outlined,
                              color: AppColors.info,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEdit
                                      ? 'Editar $_papelLabel'
                                      : 'Cadastrar $_papelLabel',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Preencha os dados cadastrais para vínculos financeiros',
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
                      const SizedBox(height: AppSpacing.lg),

                      // Seletor de Papel / Tipo
                      _buildTipoSelector(),
                      const SizedBox(height: AppSpacing.md),

                      // Nome completo / Razão Social
                      AppInput(
                        label: 'Nome completo / Razão Social *',
                        hint: 'Ex: Agropecuária Santa Helena ou Carlos Silva',
                        controller: _nomeController,
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            CustomValidators.validateRequired(value, 'Nome'),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // CPF / CNPJ
                      AppInput(
                        label: 'CPF / CNPJ *',
                        hint: '000.000.000-00 ou 00.000.000/0000-00',
                        controller: _cpfCnpjController,
                        icon: Icons.document_scanner_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) => _applyMask(
                          _cpfCnpjController,
                          Formatters.formatCpfCnpj,
                        ),
                        validator: CustomValidators.validateCpfCnpj,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Telefone
                      AppInput(
                        label: 'Telefone / WhatsApp (opcional)',
                        hint: '(00) 00000-0000',
                        controller: _foneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (val) => _applyMask(
                          _foneController,
                          Formatters.formatPhone,
                        ),
                        validator: CustomValidators.validatePhone,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // E-mail
                      AppInput(
                        label: 'E-mail (opcional)',
                        hint: 'contato@agro360.com.br',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateOptionalEmail,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Seção de Endereço Opcional
                      _buildEnderecoSection(),
                      const SizedBox(height: AppSpacing.md),

                      // Switch ativo
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          title: const Text('Cadastro ativo'),
                          subtitle: Text(
                            _ativo
                                ? 'Disponível para lançamentos financeiros'
                                : 'Desativado para novos lançamentos',
                          ),
                          value: _ativo,
                          onChanged: (value) => setState(() => _ativo = value),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primaryContainer,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Botões
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Obx(
                            () => AppButton.primary(
                              label: _isEdit ? 'Atualizar' : 'Salvar',
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

/// Modal inferior para seleção pesquisável de municípios do estado
class _CidadePickerSheet extends StatefulWidget {
  final String uf;
  final String cidadeAtual;
  final List<String> cidades;
  final ApiService apiService;
  final ValueChanged<String> onSelecionarCidade;

  const _CidadePickerSheet({
    required this.uf,
    required this.cidadeAtual,
    required this.cidades,
    required this.apiService,
    required this.onSelecionarCidade,
  });

  @override
  State<_CidadePickerSheet> createState() => _CidadePickerSheetState();
}

class _CidadePickerSheetState extends State<_CidadePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _todasCidades = [];
  List<String> _filtradas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cidades.isNotEmpty) {
      _todasCidades = List.from(widget.cidades);
      _filtradas = List.from(widget.cidades);
    } else {
      _carregar();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _isLoading = true);
    try {
      final list = await widget.apiService.getMunicipiosPorUf(widget.uf);
      if (mounted) {
        setState(() {
          _todasCidades = list;
          _filtrar(_searchController.text);
        });
      }
    } catch (_) {
      // Ignora erro
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filtrar(String query) {
    final clean = query.trim().toLowerCase();
    setState(() {
      if (clean.isEmpty) {
        _filtradas = List.from(_todasCidades);
      } else {
        _filtradas = _todasCidades
            .where((c) => c.toLowerCase().contains(clean))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.xl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Puxador central
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
              ),
            ),

            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Municípios de ${widget.uf}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isLoading
                              ? 'Consultando municípios no banco de dados...'
                              : '${_filtradas.length} município(s) cadastrado(s)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Campo de busca
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppInput(
                label: 'Buscar município',
                controller: _searchController,
                hint: 'Buscar município em ${widget.uf}...',
                icon: Icons.search_rounded,
                onChanged: _filtrar,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filtrar('');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.divider),

            // Lista de cidades
            Expanded(
              child: _isLoading && _todasCidades.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Buscando municípios no banco de dados Agro360...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : _filtradas.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _searchController.text.trim().isEmpty
                                      ? 'Nenhum município carregado para ${widget.uf}.'
                                      : 'Nenhum município correspondente a "${_searchController.text}".',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (_searchController.text.trim().isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  AppButton.outline(
                                    label:
                                        'Usar "${_searchController.text.trim()}"',
                                    onPressed: () {
                                      widget.onSelecionarCidade(
                                        _searchController.text.trim(),
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    size: AppButtonSize.small,
                                    icon: const Icon(Icons.check_rounded, size: 16),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filtradas.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 48),
                          itemBuilder: (ctx, index) {
                            final cidade = _filtradas[index];
                            final isSelected = widget.cidadeAtual.toLowerCase() ==
                                cidade.toLowerCase();

                            return ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                              title: Text(
                                cidade,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    )
                                  : null,
                              onTap: () {
                                widget.onSelecionarCidade(cidade);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
