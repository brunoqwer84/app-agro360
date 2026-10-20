import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/financeiro_controller.dart';
import '../models/lancamento_financeiro.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Formulário de Lançamento Financeiro (Receita / Despesa) com vínculo por ID de Categoria
class FinanceiroFormView extends StatefulWidget {
  const FinanceiroFormView({super.key});

  @override
  State<FinanceiroFormView> createState() => _FinanceiroFormViewState();
}

class _FinanceiroFormViewState extends State<FinanceiroFormView> {
  final _formKey = GlobalKey<FormState>();
  late final LancamentoFinanceiro? _lancamento;
  late final FinanceiroController _controller;

  late String _tipo; // 'P' para despesa, 'R' para receita
  late final TextEditingController _descricaoController;
  late final TextEditingController _valorController;
  late final TextEditingController _observacaoController;

  DateTime? _dataVencimento;
  DateTime? _dataPagamento;
  late String _status;
  int? _idCategoria;
  String? _formaPagamento;
  int? _idManejo;
  int? _idPropriedade;
  int? _idPessoa;

  bool get _isEdit => _lancamento != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<FinanceiroController>()
        ? Get.find<FinanceiroController>()
        : Get.put<FinanceiroController>(FinanceiroController());

    _lancamento = Get.arguments as LancamentoFinanceiro?;

    // 'P' = Despesa / A Pagar, 'R' = Receita / A Receber
    _tipo = _lancamento != null
        ? (_lancamento!.isReceita ? 'R' : 'P')
        : 'P';

    _descricaoController =
        TextEditingController(text: _lancamento?.descricao ?? '');
    _valorController = TextEditingController(
      text: _lancamento != null ? _lancamento!.valor.toStringAsFixed(2) : '',
    );
    _observacaoController =
        TextEditingController(text: _lancamento?.observacao ?? '');

    _dataVencimento = _lancamento?.dataVencimento ?? DateTime.now();
    _dataPagamento = _lancamento?.dataPagamento;
    _status = _lancamento?.status ?? AppConstants.statusPendente;

    _idCategoria = _lancamento?.idCategoria;
    _formaPagamento =
        _lancamento?.formaPagamento ?? AppConstants.formasPagamento.first;
    _idManejo = _lancamento?.idManejo;
    _idPropriedade = _lancamento?.idPropriedade;
    _idPessoa = _lancamento?.idPessoa;

    // Carrega listas auxiliares (Categorias, Manejos, Pessoas, Propriedades)
    _controller.loadAuxiliares();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _mudarTipo(String novoTipo) {
    if (_tipo == novoTipo) return;
    setState(() {
      _tipo = novoTipo;
      // Ao mudar de tipo, verifica se a categoria selecionada ainda pertence ao tipo novo
      final cats = _controller.getCategoriasPorTipo(_tipo);
      if (!cats.any((c) => c.idCategoria == _idCategoria)) {
        _idCategoria = null;
      }
      // Verifica se a pessoa/fornecedor selecionado é compatível com o novo tipo
      final pessoasValidas = _controller.getPessoasPorTipoLancamento(_tipo);
      if (!pessoasValidas.any((p) => p.idPessoa == _idPessoa)) {
        _idPessoa = null;
      }
    });
  }

  Future<void> _selecionarDataVencimento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataVencimento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dataVencimento = picked);
    }
  }

  Future<void> _selecionarDataPagamento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataPagamento ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dataPagamento = picked);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataVencimento == null) {
      Get.snackbar('Atenção', 'Selecione a data de vencimento',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final valorLimpo = _valorController.text.replaceAll(',', '.').trim();
    final valorDouble = double.tryParse(valorLimpo);
    if (valorDouble == null || valorDouble <= 0) {
      Get.snackbar('Atenção', 'Informe um valor válido e maior que zero',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_idCategoria == null) {
      Get.snackbar('Atenção', 'Selecione uma categoria para o lançamento',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (_idPropriedade == null) {
      Get.snackbar('Atenção', 'Selecione a propriedade para o lançamento',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final novoLancamento = LancamentoFinanceiro(
      idLancamento: _isEdit ? _lancamento!.idLancamento : 0,
      tipo: _tipo,
      descricao: _descricaoController.text.trim(),
      valor: valorDouble,
      dataVencimento: _dataVencimento!,
      dataPagamento: _status == AppConstants.statusPago
          ? (_dataPagamento ?? DateTime.now())
          : null,
      status: _status,
      idCategoria: _idCategoria,
      formaPagamento: _formaPagamento,
      idManejo: _idManejo,
      idPropriedade: _idPropriedade,
      idPessoa: _idPessoa,
      observacao: _observacaoController.text.trim().isEmpty
          ? null
          : _observacaoController.text.trim(),
    );

    if (_isEdit) {
      await _controller.updateLancamento(
          _lancamento!.idLancamento, novoLancamento);
    } else {
      await _controller.create(novoLancamento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Lançamento' : 'Novo Lançamento'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Seletor de Tipo: 'P' (Despesa) vs 'R' (Receita)
                _buildTipoSelector(),
                const SizedBox(height: AppSpacing.md),

                // 2. Descrição
                AppInput(
                  label: 'Descrição *',
                  hint: _tipo == 'P'
                      ? 'Ex: Compra de ração, Vacinas, Manutenção...'
                      : 'Ex: Venda de gado, Venda de leite...',
                  controller: _descricaoController,
                  icon: Icons.edit_note_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe a descrição';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 3. Valor
                AppInput(
                  label: 'Valor (R\$) *',
                  hint: '0,00',
                  controller: _valorController,
                  icon: Icons.attach_money_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*[,.]?\d{0,2}')),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe o valor';
                    }
                    final num = double.tryParse(val.replaceAll(',', '.'));
                    if (num == null || num <= 0) {
                      return 'Valor deve ser maior que zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // 4. Categoria (com vínculo de ID e atalho para criar)
                _buildCategoriaSection(),
                const SizedBox(height: AppSpacing.md),

                // 5. Propriedade * (Obrigatória)
                _buildPropriedadeSection(),
                const SizedBox(height: AppSpacing.md),

                // 6. Forma de Pagamento
                AppDropdown<String>(
                  label: 'Forma de Pagamento',
                  value: _formaPagamento,
                  prefixIcon: Icons.payment_rounded,
                  items: AppConstants.formasPagamento
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _formaPagamento = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // 6. Data de Vencimento
                InkWell(
                  onTap: _selecionarDataVencimento,
                  child: IgnorePointer(
                    child: AppInput(
                      label: 'Data de Vencimento *',
                      controller: TextEditingController(
                        text: Formatters.formatDate(_dataVencimento),
                      ),
                      icon: Icons.calendar_today_rounded,
                      readOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 7. Status
                AppDropdown<String>(
                  label: 'Status *',
                  value: _status,
                  prefixIcon: Icons.flag_outlined,
                  items: const [
                    DropdownMenuItem(
                      value: AppConstants.statusPendente,
                      child: Text('Pendente', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.statusPago,
                      child: Text('Pago / Recebido',
                          overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: AppConstants.statusCancelado,
                      child: Text('Cancelado', overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _status = val;
                        if (_status == AppConstants.statusPago &&
                            _dataPagamento == null) {
                          _dataPagamento = DateTime.now();
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Data de Pagamento (apenas se status == PAGO)
                if (_status == AppConstants.statusPago) ...[
                  InkWell(
                    onTap: _selecionarDataPagamento,
                    child: IgnorePointer(
                      child: AppInput(
                        label: 'Data de Pagamento / Liquidação *',
                        controller: TextEditingController(
                          text: Formatters.formatDate(_dataPagamento),
                        ),
                        icon: Icons.check_circle_outline_rounded,
                        readOnly: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Seção de Vínculos Opcionais (Manejo, Pessoa, Propriedade)
                _buildVinculosOpcionais(),

                const SizedBox(height: AppSpacing.md),

                // Observações
                AppInput(
                  label: 'Observações (Opcional)',
                  hint: 'Detalhes adicionais, notas fiscais, recibos...',
                  controller: _observacaoController,
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Botão Salvar
                Obx(() => AppButton.primary(
                      label: _isEdit
                          ? 'Atualizar Lançamento'
                          : 'Salvar Lançamento',
                      icon:
                          const Icon(Icons.check_rounded, color: Colors.white),
                      isLoading: _controller.isSaving.value,
                      onPressed: _controller.isSaving.value ? null : _salvar,
                    )),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipoSelector() {
    final isDespesa = _tipo == 'P';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _mudarTipo('P'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDespesa ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: isDespesa
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
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
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: isDespesa ? Colors.white : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Despesa (Tipo P)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            isDespesa ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _mudarTipo('R'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isDespesa ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: !isDespesa
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
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
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: !isDespesa ? Colors.white : AppColors.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Receita (Tipo R)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            !isDespesa ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Categoria (${_tipo == 'P' ? 'Despesa' : 'Receita'}) *',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                await Get.toNamed(AppRoutes.categoriasFinanceiras);
                await _controller.loadAuxiliares();
                setState(() {});
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
              label: const Text('Nova Categoria',
                  style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Obx(() {
          final cats = _controller.getCategoriasPorTipo(_tipo);

          return AppDropdown<int?>(
            label: 'Selecione a Categoria',
            value: _idCategoria,
            prefixIcon: Icons.category_outlined,
            items: cats.isEmpty
                ? [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Nenhuma categoria cadastrada',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                : [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Selecione uma categoria',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...cats.map((c) => DropdownMenuItem<int?>(
                          value: c.idCategoria,
                          child: Text(
                            c.nome,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
            onChanged: (val) => setState(() => _idCategoria = val),
          );
        }),
      ],
    );
  }

  Widget _buildPropriedadeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Propriedade / Fazenda *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() {
          final props = _controller.propriedades;
          return AppDropdown<int?>(
            label: 'Selecione a Propriedade',
            value: _idPropriedade,
            prefixIcon: Icons.landscape_rounded,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text(
                  'Selecione uma propriedade',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...props.map((p) => DropdownMenuItem<int?>(
                    value: p.idPropriedade,
                    child: Text(
                      p.nome,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            onChanged: (val) {
              setState(() {
                _idPropriedade = val;
                if (_idManejo != null) {
                  final m = _controller.manejos
                      .firstWhereOrNull((item) => item.idManejo == _idManejo);
                  if (m?.propriedade != null &&
                      m?.propriedade?.idPropriedade != val) {
                    _idManejo = null;
                  }
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildVinculosOpcionais() {
    return AppCard(
      padding: AppSpacing.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link_rounded, size: 18, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Vínculos Opcionais',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Você pode vincular este lançamento a um manejo de campo ou a um cliente/fornecedor comercial.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          // Manejo (Opcional - filtrado pela propriedade selecionada)
          Obx(() {
            final lista = _idPropriedade != null
                ? _controller.manejos
                    .where((m) =>
                        m.propriedade == null ||
                        m.propriedade?.idPropriedade == _idPropriedade)
                    .toList()
                : _controller.manejos;

            return AppDropdown<int?>(
              label: 'Manejo Vinculado (Opcional)',
              value: _idManejo,
              prefixIcon: Icons.agriculture_rounded,
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'Nenhum manejo vinculado',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ...lista.map((m) {
                  final desc = m.observacao != null && m.observacao!.isNotEmpty
                      ? ' - ${m.observacao}'
                      : '';
                  final prop = m.propriedade != null
                      ? ' (${m.propriedade!.nome})'
                      : '';
                  return DropdownMenuItem<int?>(
                    value: m.idManejo,
                    child: Text(
                      '#${m.idManejo} ${Formatters.formatDate(m.data)}$prop$desc',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _idManejo = val),
            );
          }),
          const SizedBox(height: AppSpacing.md),

          // Cliente ou Fornecedor (Opcional)
          Obx(() {
            final isReceita = _tipo == 'R';
            final titulo = isReceita ? 'Cliente' : 'Fornecedor';
            final listaPessoas = _controller.getPessoasPorTipoLancamento(_tipo);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '$titulo (Opcional)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await Get.toNamed(
                          AppRoutes.pessoasForm,
                          arguments: {'initialTipo': isReceita ? 'C' : 'F'},
                        );
                        await _controller.loadAuxiliares();
                        setState(() {});
                      },
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 14),
                      label: Text(
                        'Novo $titulo',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppDropdown<int?>(
                  label: 'Selecione o $titulo',
                  value: _idPessoa,
                  prefixIcon: isReceita
                      ? Icons.person_rounded
                      : Icons.local_shipping_outlined,
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(
                        'Nenhum $titulo vinculado',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ...listaPessoas.map((p) => DropdownMenuItem<int?>(
                          value: p.idPessoa,
                          child: Text(
                            '${p.nome} (${p.tipoDescricao})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                  onChanged: (val) => setState(() => _idPessoa = val),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
