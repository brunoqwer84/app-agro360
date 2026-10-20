import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/compra_despesa_controller.dart';
import '../models/leitura_nota_result.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Tela de Revisão da Leitura de Nota Fiscal por Imagem / OCR
/// Permite ao usuário inspecionar, corrigir e confirmar os dados extraídos antes de persistir.
class CompraDespesaRevisaoView extends StatefulWidget {
  const CompraDespesaRevisaoView({super.key});

  @override
  State<CompraDespesaRevisaoView> createState() =>
      _CompraDespesaRevisaoViewState();
}

class _CompraDespesaRevisaoViewState extends State<CompraDespesaRevisaoView> {
  final _formKey = GlobalKey<FormState>();
  late final CompraDespesaController _controller;

  late final LeituraNotaResult _leitura;
  File? _imageFile;

  // Controllers de formulário
  late final TextEditingController _descricaoController;
  late final TextEditingController _valorTotalController;
  late final TextEditingController _numeroDocumentoController;
  late final TextEditingController _chaveAcessoController;
  late final TextEditingController _observacaoController;

  int? _idFornecedor;
  int? _idPropriedade;
  int? _idCategoria;
  DateTime _dataCompra = DateTime.now();
  String? _formaPagamento;
  final String _status = 'CONCLUIDA';

  // Inclusão no Financeiro (Contas a Pagar)
  bool _incluirNoFinanceiro = true;
  DateTime? _dataVencimento;
  String _statusLancamento = 'PENDENTE';

  // Itens e Vencimentos editáveis
  final List<ItemNotaModel> _itens = [];
  final List<ParcelaNotaModel> _parcelas = [];

  // Controle de duplicidade
  bool _ignorarDuplicidade = false;

  // TODO: Implementar consulta direta via SEFAZ através da Chave de Acesso / QR Code
  // TODO: Implementar leitura óptica de linha digitável / código de barras de Boleto Bancário

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CompraDespesaController>()
        ? Get.find<CompraDespesaController>()
        : Get.put<CompraDespesaController>(CompraDespesaController());

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _leitura = args['leitura'] as LeituraNotaResult? ?? LeituraNotaResult();
    _imageFile = args['imageFile'] as File?;

    _inicializarDados();
  }

  void _inicializarDados() {
    String descPadrao = 'Compra / Despesa';
    if (_leitura.fornecedor != null && _leitura.fornecedor!.isNotEmpty) {
      descPadrao = 'Compra - ${_leitura.fornecedor}';
    } else if (_leitura.numero != null) {
      descPadrao = 'NF ${_leitura.numero}';
    }

    _descricaoController = TextEditingController(text: descPadrao);
    _valorTotalController = TextEditingController(
      text: _leitura.total != null ? _leitura.total!.toStringAsFixed(2) : '',
    );
    _numeroDocumentoController =
        TextEditingController(text: _leitura.numero ?? '');
    _chaveAcessoController =
        TextEditingController(text: _leitura.chaveAcesso ?? '');

    String obsInicial = '';
    if (_leitura.tipoDocumento != null) {
      obsInicial += 'Documento: ${_leitura.tipoDocumento}\n';
    }
    if (_leitura.cnpj != null) {
      obsInicial += 'CNPJ Fornecedor: ${_leitura.cnpj}\n';
    }
    _observacaoController = TextEditingController(text: obsInicial.trim());

    if (_leitura.dataEmissao != null) {
      _dataCompra = _leitura.dataEmissao!;
    }
    _dataVencimento = _leitura.vencimentos.isNotEmpty &&
            _leitura.vencimentos.first.dataVencimento != null
        ? _leitura.vencimentos.first.dataVencimento
        : _dataCompra;

    _formaPagamento = AppConstants.formasPagamento.first;
    _idCategoria = _leitura.idCategoriaSugerida;

    _itens.addAll(_leitura.itens);
    _parcelas.addAll(_leitura.vencimentos);

    // Carrega auxiliares e tenta selecionar fornecedor por CNPJ
    _controller.loadAuxiliares().then((_) {
      if (mounted) {
        _tentarVincularFornecedor();
      }
    });
  }

  void _tentarVincularFornecedor() {
    if (_leitura.cnpj != null && _leitura.cnpj!.isNotEmpty) {
      final cnpjLimpo = Formatters.cleanCpfCnpj(_leitura.cnpj!);
      final match = _controller.fornecedores.firstWhereOrNull((f) {
        return Formatters.cleanCpfCnpj(f.cpfCnpj) == cnpjLimpo;
      });

      if (match != null) {
        setState(() {
          _idFornecedor = match.idPessoa;
        });
      }
    }

    // Se só tem uma propriedade ativa, pré-seleciona
    if (_idPropriedade == null && _controller.propriedades.length == 1) {
      setState(() {
        _idPropriedade = _controller.propriedades.first.idPropriedade;
      });
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorTotalController.dispose();
    _numeroDocumentoController.dispose();
    _chaveAcessoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  void _abrirVisualizadorImagem() {
    if (_imageFile == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        backgroundColor: Colors.black87,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: Image.file(_imageFile!),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarDataCompra() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataCompra,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dataCompra = picked);
    }
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

  void _adicionarItem() {
    final descCtrl = TextEditingController();
    final qtdCtrl = TextEditingController(text: '1');
    final unitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição do item *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qtdCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantidade'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: unitCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Valor unitário (R\$) *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final desc = descCtrl.text.trim();
              if (desc.isEmpty) return;
              final qtd = double.tryParse(qtdCtrl.text.replaceAll(',', '.')) ?? 1.0;
              final unit = double.tryParse(unitCtrl.text.replaceAll(',', '.')) ?? 0.0;
              setState(() {
                _itens.add(ItemNotaModel(
                  descricao: desc,
                  quantidade: qtd,
                  valorUnitario: unit,
                  valorTotal: qtd * unit,
                ));
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  void _adicionarParcela() {
    final numCtrl = TextEditingController(text: '${_parcelas.length + 1}');
    final valCtrl = TextEditingController();
    DateTime dtVenc = DateTime.now().add(Duration(days: 30 * (_parcelas.length + 1)));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Adicionar Parcela'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: numCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Número da parcela'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vencimento:'),
                  subtitle: Text(Formatters.formatDate(dtVenc)),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context,
                      initialDate: dtVenc,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (p != null) {
                      setDlgState(() => dtVenc = p);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Valor da parcela (R\$) *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(valCtrl.text.replaceAll(',', '.')) ?? 0.0;
                final numP = int.tryParse(numCtrl.text) ?? (_parcelas.length + 1);
                setState(() {
                  _parcelas.add(ParcelaNotaModel(
                    numeroParcela: numP,
                    dataVencimento: dtVenc,
                    valor: val,
                  ));
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _removerParcela(int index) {
    setState(() {
      _parcelas.removeAt(index);
    });
  }

  Future<void> _confirmarESalvar() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Atenção',
        'Preencha todos os campos obrigatórios corretamente.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_idFornecedor == null) {
      Get.snackbar(
        'Atenção',
        'Selecione ou cadastre o fornecedor da despesa.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_idPropriedade == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a propriedade vinculada.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_leitura.temDuplicidade && !_ignorarDuplicidade) {
      final prosseguir = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Possível Duplicidade'),
          content: Text(
            'Já existe a despesa #${_leitura.idDespesaDuplicada} com estes dados. Deseja registrar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Lançar Mesmo Assim'),
            ),
          ],
        ),
      );
      if (prosseguir != true) return;
    }

    final double valor =
        double.parse(_valorTotalController.text.replaceAll(',', '.'));

    final dados = {
      'descricao': _descricaoController.text.trim(),
      'valorTotal': valor,
      'dataCompra': _dataCompra.toIso8601String().split('T')[0],
      'numeroDocumento': _numeroDocumentoController.text.trim().isEmpty
          ? null
          : _numeroDocumentoController.text.trim(),
      'chaveAcesso': _chaveAcessoController.text.trim().isEmpty
          ? null
          : _chaveAcessoController.text.trim(),
      'tipoDocumento': _leitura.tipoDocumento ?? 'NFE',
      'anexoImagemUrl': _leitura.anexoTempPath,
      'formaPagamento': _formaPagamento,
      'status': _status,
      'observacao': _observacaoController.text.trim().isEmpty
          ? null
          : _observacaoController.text.trim(),
      'idFornecedor': _idFornecedor,
      'idPropriedade': _idPropriedade,
      if (_idCategoria != null) 'idCategoria': _idCategoria,
      'incluirNoFinanceiro': _incluirNoFinanceiro,
      'statusLancamento': _statusLancamento,
      'dataVencimento': _dataVencimento != null
          ? _dataVencimento!.toIso8601String().split('T')[0]
          : _dataCompra.toIso8601String().split('T')[0],
      'itens': _itens.map((i) => i.toJson()).toList(),
      'parcelas': _parcelas.map((p) => p.toJson()).toList(),
    };

    final sucesso = await _controller.criar(dados);
    if (sucesso) {
      Get.back(result: true);
    }
  }

  void _descartar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar Leitura?'),
        content: const Text(
          'Os dados extraídos desta nota fiscal serão descartados. Nenhuma despesa será criada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continuar Editando'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.back(result: false);
            },
            child: const Text('Descartar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Revisão da Nota Fiscal'),
        actions: [
          TextButton(
            onPressed: _descartar,
            child: const Text(
              'Descartar',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // 1. Miniatura da Imagem com toque para ampliar
            _buildImageThumbnailCard(),
            const SizedBox(height: AppSpacing.md),

            // 2. Banner de Duplicidade (se houver)
            if (_leitura.temDuplicidade && !_ignorarDuplicidade) ...[
              _buildDuplicateBanner(),
              const SizedBox(height: AppSpacing.md),
            ],

            // 3. Banner de Avisos da IA/OCR
            if (_leitura.temAvisos) ...[
              _buildWarningsBanner(),
              const SizedBox(height: AppSpacing.md),
            ],

            // 4. Seção Dados Principais da Despesa
            _buildDadosPrincipaisCard(),
            const SizedBox(height: AppSpacing.md),

            // 5. Seção Itens da Nota Fiscal
            _buildItensCard(),
            const SizedBox(height: AppSpacing.md),

            // 6. Seção Parcelas e Contas a Pagar
            _buildFinanceiroCard(),
            const SizedBox(height: AppSpacing.lg),

            // 7. Botões de Ação
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnailCard() {
    return AppCard(
      child: InkWell(
        onTap: _abrirVisualizadorImagem,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.receipt_long_rounded, size: 40),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _leitura.tipoDocumento ?? 'Nota Fiscal Analisada',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toque para visualizar e dar zoom na imagem original',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.zoom_in_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Ampliar comprovante',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuplicateBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Possível Despesa Duplicada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Já existe uma despesa cadastrada (#${_leitura.idDespesaDuplicada}) com esta chave de acesso ou fornecedor/número/valor.',
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navegar diretamente para detalhes da despesa existente
                  Get.snackbar(
                    'Despesa #${_leitura.idDespesaDuplicada}',
                    'Esta despesa já consta cadastrada no seu painel.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                label: const Text('Ver despesa existente'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                ),
                onPressed: () {
                  setState(() => _ignorarDuplicidade = true);
                },
                child: const Text('Lançar mesmo assim', style: TextStyle(color: Colors.black87)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Avisos de Conferência da Nota',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._leitura.avisos.map(
            (aviso) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      aviso,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDadosPrincipaisCard() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dados Gerais da Despesa',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSpacing.md),

            // Descrição
            AppInput(
              controller: _descricaoController,
              label: 'Descrição da Compra / Despesa *',
              hint: 'Ex.: Insumos agrícolas, Ração bovina',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Fornecedor
            Obx(() {
              final fornecedoresList = _controller.fornecedores;
              return AppDropdown<int>(
                label: 'Fornecedor *',
                value: _idFornecedor,
                items: fornecedoresList.map((f) {
                  final cpfCnpjText = f.cpfCnpj.isNotEmpty ? ' (${f.cpfCnpj})' : '';
                  return DropdownMenuItem<int>(
                    value: f.idPessoa,
                    child: Text(
                      '${f.nome}$cpfCnpjText',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _idFornecedor = val),
                validator: (v) => v == null ? 'Selecione o fornecedor' : null,
              );
            }),
            if (_leitura.fornecedor != null && _idFornecedor == null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Identificado na nota: "${_leitura.fornecedor}"${_leitura.cnpj != null ? ' - CNPJ ${_leitura.cnpj}' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),

            // Propriedade
            Obx(() {
              final propriedadesList = _controller.propriedades;
              return AppDropdown<int>(
                label: 'Propriedade de Destino *',
                value: _idPropriedade,
                items: propriedadesList.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.idPropriedade,
                    child: Text(p.nome, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _idPropriedade = val),
                validator: (v) => v == null ? 'Selecione a propriedade' : null,
              );
            }),
            const SizedBox(height: AppSpacing.sm),

            // Categoria de Despesa
            Obx(() {
              final categoriasList = _controller.categorias;
              return AppDropdown<int?>(
                label: 'Categoria Financeira',
                value: _idCategoria,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Sem categoria'),
                  ),
                  ...categoriasList.map((c) {
                    return DropdownMenuItem<int?>(
                      value: c.idCategoria,
                      child: Text(c.nome, overflow: TextOverflow.ellipsis),
                    );
                  }),
                ],
                onChanged: (val) => setState(() => _idCategoria = val),
              );
            }),
            if (_leitura.categoriaSugerida != null && _idCategoria != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  'Sugerido pela inteligência artificial: "${_leitura.categoriaSugerida}"',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: AppSpacing.md),

            // Linha: Valor Total e Data da Compra
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    controller: _valorTotalController,
                    label: 'Valor Total (R\$) *',
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o valor';
                      final parsed =
                          double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Valor inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: InkWell(
                    onTap: _selecionarDataCompra,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data da Emissão *',
                        suffixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Text(Formatters.formatDate(_dataCompra)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Número do Documento e Chave de Acesso
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppInput(
                    controller: _numeroDocumentoController,
                    label: 'Nº do Documento / Nota',
                    hint: 'Ex.: 12345',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: AppInput(
                    controller: _chaveAcessoController,
                    label: 'Chave de Acesso (44 dígitos)',
                    hint: 'Sequência da NF-e',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Forma de pagamento
            AppDropdown<String>(
              label: 'Forma de Pagamento',
              value: _formaPagamento,
              items: AppConstants.formasPagamento.map((f) {
                return DropdownMenuItem<String>(
                  value: f,
                  child: Text(f),
                );
              }).toList(),
              onChanged: (val) => setState(() => _formaPagamento = val),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Observações
            AppInput(
              controller: _observacaoController,
              label: 'Observações / Detalhes',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensCard() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Itens Discriminados',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      '${_itens.length} ${_itens.length == 1 ? "item identificado" : "itens identificados"}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _adicionarItem,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Adicionar Item'),
                ),
              ],
            ),
            const Divider(),
            if (_itens.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'Nenhum item discriminado na leitura.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _itens.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final it = _itens[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(it.descricao, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${it.quantidade} x ${Formatters.formatCurrency(it.valorUnitario)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(it.valorTotal),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                          onPressed: () => _removerItem(i),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceiroCard() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _incluirNoFinanceiro,
                  onChanged: (val) =>
                      setState(() => _incluirNoFinanceiro = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    'Gerar Conta a Pagar no Financeiro',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            if (_incluirNoFinanceiro) ...[
              const SizedBox(height: AppSpacing.sm),
              // Vencimento Principal
              InkWell(
                onTap: _selecionarDataVencimento,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data do 1º Vencimento *',
                    suffixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(Formatters.formatDate(_dataVencimento ?? _dataCompra)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Status do Lançamento
              AppDropdown<String>(
                label: 'Status do Contas a Pagar',
                value: _statusLancamento,
                items: const [
                  DropdownMenuItem(value: 'PENDENTE', child: Text('PENDENTE (A Pagar)')),
                  DropdownMenuItem(value: 'PAGO', child: Text('PAGO (Quitado)')),
                ],
                onChanged: (val) =>
                    setState(() => _statusLancamento = val ?? 'PENDENTE'),
              ),
              const SizedBox(height: AppSpacing.md),

              // Lista de Parcelas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Parcelamento / Vencimentos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: _adicionarParcela,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Adicionar Parcela'),
                  ),
                ],
              ),
              const Divider(),
              if (_parcelas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Vencimento integral na data informada acima.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _parcelas.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = _parcelas[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Parcela ${p.numeroParcela}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        p.dataVencimento != null
                            ? 'Vencimento: ${Formatters.formatDate(p.dataVencimento!)}'
                            : 'Sem vencimento especificado',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Formatters.formatCurrency(p.valor),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            onPressed: () => _removerParcela(i),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() {
          final isSaving = _controller.isSaving.value;
          return AppButton.primary(
            label: isSaving ? 'Salvando...' : 'Confirmar e Salvar Despesa',
            icon: const Icon(Icons.check_circle_outline_rounded),
            isLoading: isSaving,
            onPressed: isSaving ? null : _confirmarESalvar,
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _descartar,
          icon: const Icon(Icons.cancel_outlined, color: AppColors.textSecondary),
          label: const Text(
            'Descartar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
