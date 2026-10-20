import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/compra_despesa_controller.dart';
import '../models/compra_despesa.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Formulário de Compra e Despesa vinculado a Fornecedor e Contas a Pagar
class CompraDespesaFormView extends StatefulWidget {
  const CompraDespesaFormView({super.key});

  @override
  State<CompraDespesaFormView> createState() => _CompraDespesaFormViewState();
}

class _CompraDespesaFormViewState extends State<CompraDespesaFormView> {
  final _formKey = GlobalKey<FormState>();
  late final CompraDespesa? _compra;
  late final CompraDespesaController _controller;

  late final TextEditingController _descricaoController;
  late final TextEditingController _valorController;
  late final TextEditingController _numeroDocumentoController;
  late final TextEditingController _observacaoController;

  int? _idFornecedor;
  int? _idPropriedade;
  int? _idCategoria;
  DateTime _dataCompra = DateTime.now();
  String? _formaPagamento;
  String _status = 'CONCLUIDA';

  // Inclusão no Financeiro (Contas a Pagar)
  bool _incluirNoFinanceiro = true;
  DateTime? _dataVencimento;
  String _statusLancamento = 'PENDENTE';
  DateTime? _dataPagamento;

  bool get _isEdit => _compra != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CompraDespesaController>()
        ? Get.find<CompraDespesaController>()
        : Get.put<CompraDespesaController>(CompraDespesaController());

    _compra = Get.arguments as CompraDespesa?;

    _descricaoController =
        TextEditingController(text: _compra?.descricao ?? '');
    _valorController = TextEditingController(
      text: _compra != null ? _compra!.valorTotal.toStringAsFixed(2) : '',
    );
    _numeroDocumentoController =
        TextEditingController(text: _compra?.numeroDocumento ?? '');
    _observacaoController =
        TextEditingController(text: _compra?.observacao ?? '');

    if (_compra != null) {
      _idFornecedor = _compra!.idFornecedor;
      _idPropriedade = _compra!.idPropriedade;
      _idCategoria = _compra!.idCategoria;
      _dataCompra = _compra!.dataCompra;
      _formaPagamento = _compra!.formaPagamento ?? AppConstants.formasPagamento.first;
      _status = _compra!.status;

      _incluirNoFinanceiro = _compra!.temLancamentoFinanceiro;
      _dataVencimento = _compra!.dataVencimentoLancamento ?? _compra!.dataCompra;
      _statusLancamento = _compra!.statusLancamento ?? 'PENDENTE';
      _dataPagamento = _compra!.dataPagamentoLancamento;
    } else {
      _formaPagamento = AppConstants.formasPagamento.first;
      _dataVencimento = DateTime.now();
    }

    _controller.loadAuxiliares();
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _numeroDocumentoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataCompra() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _dataCompra = picked;
        // Se ainda não definiu vencimento ou se eram iguais, acompanha a data da compra
        if (_dataVencimento == null || _dataVencimento == _dataCompra) {
          _dataVencimento = picked;
        }
      });
    }
  }

  Future<void> _selecionarDataVencimento() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataVencimento ?? _dataCompra,
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

    if (_idFornecedor == null) {
      Get.snackbar(
        'Atenção',
        'Selecione um fornecedor para a compra/despesa',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_idPropriedade == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a propriedade vinculada à compra/despesa',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final valorLimpo =
        _valorController.text.trim().replaceAll(',', '.').replaceAll(' ', '');
    final valorNum = double.tryParse(valorLimpo);
    if (valorNum == null || valorNum <= 0) {
      Get.snackbar(
        'Atenção',
        'Informe um valor válido maior que zero',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final data = <String, dynamic>{
      'descricao': _descricaoController.text.trim(),
      'valorTotal': valorNum,
      'dataCompra': _dataCompra.toIso8601String().split('T')[0],
      if (_numeroDocumentoController.text.trim().isNotEmpty)
        'numeroDocumento': _numeroDocumentoController.text.trim(),
      if (_formaPagamento != null) 'formaPagamento': _formaPagamento,
      'status': _status,
      if (_observacaoController.text.trim().isNotEmpty)
        'observacao': _observacaoController.text.trim(),
      'idFornecedor': _idFornecedor,
      'idPropriedade': _idPropriedade,
      if (_idCategoria != null) 'idCategoria': _idCategoria,

      // Inclusão no financeiro
      'incluirNoFinanceiro': _incluirNoFinanceiro,
      if (_incluirNoFinanceiro) ...{
        'dataVencimento': (_dataVencimento ?? _dataCompra)
            .toIso8601String()
            .split('T')[0],
        'statusLancamento': _statusLancamento,
        if (_statusLancamento == 'PAGO' && _dataPagamento != null)
          'dataPagamento': _dataPagamento!.toIso8601String().split('T')[0],
      },
    };

    bool ok;
    if (_isEdit) {
      ok = await _controller.atualizar(_compra!.idCompraDespesa, data);
    } else {
      ok = await _controller.criar(data);
    }

    if (ok) {
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Compra / Despesa' : 'Nova Compra / Despesa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fornecedor
              _buildFornecedorSection(),
              const SizedBox(height: AppSpacing.md),

              // Propriedade
              _buildPropriedadeSection(),
              const SizedBox(height: AppSpacing.md),

              // Categoria de Despesa
              _buildCategoriaSection(),
              const SizedBox(height: AppSpacing.md),

              // Descrição
              AppInput(
                label: 'Descrição da Compra / Despesa *',
                hint: 'Ex: Ração Bovina 20 sacos, Vacinas, Sal Mineral...',
                controller: _descricaoController,
                icon: Icons.description_outlined,
                textCapitalization: TextCapitalization.sentences,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Informe a descrição da compra ou despesa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Valor Total e Data da Compra
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppInput(
                      label: 'Valor Total (R\$) *',
                      hint: '0,00',
                      controller: _valorController,
                      icon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*[\.,]?\d{0,2}')),
                      ],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Informe o valor';
                        }
                        final num = double.tryParse(val.replaceAll(',', '.'));
                        if (num == null || num <= 0) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      onTap: _selecionarDataCompra,
                      child: IgnorePointer(
                        child: AppInput(
                          label: 'Data da Compra *',
                          controller: TextEditingController(
                            text: Formatters.formatDate(_dataCompra),
                          ),
                          icon: Icons.calendar_today_rounded,
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Número do Documento / NF e Forma de Pagamento
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: AppInput(
                      label: 'Nota Fiscal / Doc. (Opcional)',
                      hint: 'NF-e 12345',
                      controller: _numeroDocumentoController,
                      icon: Icons.receipt_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 3,
                    child: AppDropdown<String?>(
                      label: 'Forma de Pagamento',
                      value: _formaPagamento,
                      items: AppConstants.formasPagamento
                          .map(
                            (fp) => DropdownMenuItem(
                              value: fp,
                              child: Text(fp, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _formaPagamento = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Card de Inclusão no Financeiro (Contas a Pagar)
              _buildFinanceiroIntegrationCard(),
              const SizedBox(height: AppSpacing.md),

              // Observações
              AppInput(
                label: 'Observações (Opcional)',
                hint: 'Condições de entrega, garantia, detalhes...',
                controller: _observacaoController,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Botão Salvar
              Obx(() => AppButton.primary(
                    label: _isEdit
                        ? 'Atualizar Compra / Despesa'
                        : 'Salvar Compra / Despesa',
                    icon: const Icon(Icons.check_rounded, color: Colors.white),
                    isLoading: _controller.isSaving.value,
                    onPressed: _controller.isSaving.value ? null : _salvar,
                  )),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFornecedorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Fornecedor *',
                style: TextStyle(
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
                  arguments: {'initialTipo': 'F'},
                );
                await _controller.loadAuxiliares();
                setState(() {});
              },
              icon: const Icon(Icons.add_circle_outline_rounded, size: 14),
              label: const Text(
                'Novo Fornecedor',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Obx(() {
          final fornecedores = _controller.fornecedores;

          return AppDropdown<int?>(
            label: 'Selecione o Fornecedor',
            value: _idFornecedor,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Selecione um fornecedor'),
              ),
              ...fornecedores.map(
                (f) => DropdownMenuItem<int?>(
                  value: f.idPessoa,
                  child: Text(
                    '${f.nome} (${f.cpfCnpj})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _idFornecedor = val),
            validator: (val) {
              if (val == null) return 'Selecione um fornecedor';
              return null;
            },
          );
        }),
      ],
    );
  }

  Widget _buildPropriedadeSection() {
    return Obx(() {
      final props = _controller.propriedades;

      return AppDropdown<int?>(
        label: 'Propriedade Vinculada *',
        value: _idPropriedade,
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Selecione uma propriedade'),
          ),
          ...props.map(
            (p) => DropdownMenuItem<int?>(
              value: p.idPropriedade,
              child: Text(p.nome, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: (val) => setState(() => _idPropriedade = val),
        validator: (val) {
          if (val == null) return 'Selecione a propriedade vinculada';
          return null;
        },
      );
    });
  }

  Widget _buildCategoriaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Categoria da Despesa (Opcional)',
                style: TextStyle(
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
              label: const Text(
                'Nova Categoria',
                style: TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Obx(() {
          final cats = _controller.categorias;

          return AppDropdown<int?>(
            label: 'Selecione a Categoria de Despesa',
            value: _idCategoria,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Sem Categoria'),
              ),
              ...cats.map(
                (c) => DropdownMenuItem<int?>(
                  value: c.idCategoria,
                  child: Text(c.nome, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (val) => setState(() => _idCategoria = val),
          );
        }),
      ],
    );
  }

  /// Card expansível com opção de integração ao Contas a Pagar
  Widget _buildFinanceiroIntegrationCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _incluirNoFinanceiro
            ? AppColors.primary.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _incluirNoFinanceiro
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.divider,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _incluirNoFinanceiro
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.divider.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: _incluirNoFinanceiro
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incluir no Contas a Pagar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _incluirNoFinanceiro
                          ? 'Gera automaticamente o lançamento a pagar no módulo financeiro.'
                          : 'Apenas registro operacional, sem lançamento financeiro.',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _incluirNoFinanceiro,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                onChanged: (val) => setState(() => _incluirNoFinanceiro = val),
              ),
            ],
          ),

          if (_incluirNoFinanceiro) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: AppSpacing.md),

            // Data de Vencimento
            InkWell(
              onTap: _selecionarDataVencimento,
              child: IgnorePointer(
                child: AppInput(
                  label: 'Data de Vencimento no Financeiro *',
                  controller: TextEditingController(
                    text: Formatters.formatDate(_dataVencimento),
                  ),
                  icon: Icons.event_available_rounded,
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Status do Lançamento no Financeiro
            AppDropdown<String>(
              label: 'Situação do Pagamento *',
              value: _statusLancamento,
              items: const [
                DropdownMenuItem(
                  value: 'PENDENTE',
                  child: Text('Pendente (A Pagar)'),
                ),
                DropdownMenuItem(
                  value: 'PAGO',
                  child: Text('Já Liquidado (Pago)'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _statusLancamento = val;
                    if (val == 'PAGO' && _dataPagamento == null) {
                      _dataPagamento = DateTime.now();
                    }
                  });
                }
              },
            ),

            if (_statusLancamento == 'PAGO') ...[
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: _selecionarDataPagamento,
                child: IgnorePointer(
                  child: AppInput(
                    label: 'Data do Pagamento / Quitação *',
                    controller: TextEditingController(
                      text: Formatters.formatDate(_dataPagamento),
                    ),
                    icon: Icons.check_circle_outline_rounded,
                    readOnly: true,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
