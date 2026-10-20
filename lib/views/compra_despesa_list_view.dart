import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/compra_despesa_controller.dart';
import '../controllers/financeiro_controller.dart' show PeriodoExercicio;
import '../models/compra_despesa.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';

/// Tela de listagem e acompanhamento do módulo de Compras e Despesas
class CompraDespesaListView extends StatefulWidget {
  const CompraDespesaListView({super.key});

  @override
  State<CompraDespesaListView> createState() => _CompraDespesaListViewState();
}

class _CompraDespesaListViewState extends State<CompraDespesaListView> {
  late final CompraDespesaController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CompraDespesaController>()
        ? Get.find<CompraDespesaController>()
        : Get.put<CompraDespesaController>(CompraDespesaController());
  }

  Future<void> _capturarNota(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source);
      if (picked == null) return;

      final file = File(picked.path);
      final dados = await controller.processarFotoNota(file);
      if (dados != null) {
        final res = await Get.toNamed(AppRoutes.compraDespesaRevisao, arguments: dados);
        if (res == true) {
          controller.loadAll();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Câmera / Galeria',
        'Não foi possível acessar a câmera ou galeria. Verifique as permissões.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _abrirOpcoesLeituraNF() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 28),
                title: Text(
                  'Lançar Despesa por Foto da NF',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text('Tire uma foto ou escolha da galeria para extrair os dados automaticamente'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Tirar foto com a Câmera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _capturarNota(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _capturarNota(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return Obx(() {
      final isOcr = controller.isReadingOcr.value;

      return Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Compras & Despesas'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.document_scanner_rounded),
                  tooltip: 'Ler NF por Foto',
                  onPressed: isOcr ? null : _abrirOpcoesLeituraNF,
                ),
                IconButton(
                  icon: const Icon(Icons.people_outline),
                  tooltip: 'Fornecedores',
                  onPressed: () => Get.toNamed(AppRoutes.pessoas),
                ),
                IconButton(
                  icon: const Icon(Icons.category_outlined),
                  tooltip: 'Categorias de Despesa',
                  onPressed: () => Get.toNamed(AppRoutes.categoriasFinanceiras),
                ),
              ],
            ),
            body: Column(
              children: [
                // Seletor de Período
                _buildPeriodSelector(),

                // Resumo numérico do período
                _buildQuickSummaryCard(),

                // Lista de Compras / Despesas
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => controller.loadAll(),
                    child: Obx(() {
                      if (controller.isLoading.value && controller.compras.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final lista = controller.compras;

                      if (lista.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Nenhuma compra ou despesa',
                          subtitle:
                              'Nenhum registro encontrado para o período selecionado.',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: lista.length,
                        itemBuilder: (context, index) {
                          final item = lista[index];
                          return _buildCompraCard(item);
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'btnLerNF',
                    onPressed: isOcr ? null : _abrirOpcoesLeituraNF,
                    backgroundColor: AppColors.accent,
                    icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                    label: const Text(
                      'Ler NF',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FloatingActionButton.extended(
                    heroTag: 'btnNovaCompraDespesa',
                    onPressed: () async {
                      final res = await Get.toNamed(AppRoutes.compraDespesaForm);
                      if (res == true) {
                        controller.loadAll();
                      }
                    },
                    backgroundColor: colorScheme.primary,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      'Nova Despesa',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isOcr)
            Container(
              color: Colors.black54,
              child: const Center(
                child: AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Lendo nota fiscal...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Extraindo itens, valores e parcelas com IA',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  /// Barra de seleção de período do exercício
  Widget _buildPeriodSelector() {
    return Obx(() {
      final periodo = controller.periodoSelecionado.value;
      final dtInicio = controller.dataInicio.value;
      final dtFim = controller.dataFim.value;

      String rangeLabel = 'Todas as compras/despesas';
      if (dtInicio != null && dtFim != null) {
        rangeLabel =
            '${Formatters.formatDate(dtInicio)} até ${Formatters.formatDate(dtFim)}';
      } else if (dtInicio != null) {
        rangeLabel = 'A partir de ${Formatters.formatDate(dtInicio)}';
      }

      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip(
                    label: '30 Dias',
                    selected: periodo == PeriodoExercicio.dias30,
                    onTap: () =>
                        controller.aplicarPeriodo(PeriodoExercicio.dias30),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildPeriodChip(
                    label: '60 Dias',
                    selected: periodo == PeriodoExercicio.dias60,
                    onTap: () =>
                        controller.aplicarPeriodo(PeriodoExercicio.dias60),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildPeriodChip(
                    label: 'Exercício Anual',
                    selected: periodo == PeriodoExercicio.anual,
                    onTap: () =>
                        controller.aplicarPeriodo(PeriodoExercicio.anual),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildPeriodChip(
                    label: 'Personalizado',
                    selected: periodo == PeriodoExercicio.customizado,
                    icon: Icons.date_range_rounded,
                    onTap: _selecionarPeriodoCustomizado,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildPeriodChip(
                    label: 'Tudo',
                    selected: periodo == PeriodoExercicio.todos,
                    onTap: () =>
                        controller.aplicarPeriodo(PeriodoExercicio.todos),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  rangeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPeriodChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.primary.withValues(alpha: 0.06),
      checkmarkColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 0),
      visualDensity: VisualDensity.compact,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.35),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
    );
  }

  Future<void> _selecionarPeriodoCustomizado() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDateRange: DateTimeRange(
        start: controller.dataInicio.value ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: controller.dataFim.value ?? DateTime.now(),
      ),
      helpText: 'Selecione o período de compras',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );

    if (picked != null) {
      controller.aplicarPeriodo(
        PeriodoExercicio.customizado,
        customInicio: picked.start,
        customFim: picked.end,
      );
    }
  }

  /// Card de resumo financeiro das despesas/compras no período
  Widget _buildQuickSummaryCard() {
    return Obx(() {
      final total = controller.totalValorCompras;
      final totalPendente = controller.totalPendenteNoFinanceiro;
      final qtd = controller.compras.length;

      return Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(
              title: 'Total Compras',
              value: Formatters.formatCurrency(total),
              icon: Icons.shopping_bag_outlined,
              color: AppColors.error,
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            _buildMetricItem(
              title: 'A Pagar no Fin.',
              value: Formatters.formatCurrency(totalPendente),
              icon: Icons.schedule_rounded,
              color: AppColors.warning,
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            _buildMetricItem(
              title: 'Registros',
              value: '$qtd',
              icon: Icons.receipt_long_rounded,
              color: AppColors.primary,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Card de compra/despesa
  Widget _buildCompraCard(CompraDespesa item) {
    final fornecedorNome = item.nomeFornecedor ?? 'Fornecedor #${item.idFornecedor}';
    final propNome = item.nomePropriedade ?? 'Propriedade #${item.idPropriedade}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.md,
      onTap: () => _abrirOpcoesCompra(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone da compra
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_checkout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Informações centrais
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fornecedorNome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.descricao,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Data: ${Formatters.formatDate(item.dataCompra)}'
                      '${item.numeroDocumento != null && item.numeroDocumento!.isNotEmpty ? " • NF/Doc: #${item.numeroDocumento}" : ""}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Valor da compra
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(item.valorTotal),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  if (item.formaPagamento != null &&
                      item.formaPagamento!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.formaPagamento!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),
          const Divider(height: 12),

          // Tags e status financeiro
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildMiniTag(
                icon: Icons.landscape_rounded,
                label: propNome,
                color: AppColors.categoryTeal,
              ),
              if (item.nomeCategoria != null)
                _buildMiniTag(
                  icon: Icons.category_outlined,
                  label: item.nomeCategoria!,
                  color: AppColors.primary,
                ),
              if (item.temLancamentoFinanceiro) ...[
                if (item.isPagoNoFinanceiro)
                  const AppStatusBadge(
                    label: 'PAGO NO FINANCEIRO',
                    type: AppStatusType.active,
                    size: AppStatusBadgeSize.small,
                  )
                else
                  AppStatusBadge(
                    label: item.dataVencimentoLancamento != null
                        ? 'A PAGAR (Venc: ${Formatters.formatDate(item.dataVencimentoLancamento!)})'
                        : 'A PAGAR NO FINANCEIRO',
                    type: AppStatusType.pending,
                    size: AppStatusBadgeSize.small,
                  ),
              ] else
                const AppStatusBadge(
                  label: 'SEM LANÇAMENTO FINANCEIRO',
                  type: AppStatusType.info,
                  size: AppStatusBadgeSize.small,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe menu de opções da compra/despesa selecionada
  void _abrirOpcoesCompra(CompraDespesa item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.descricao,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(item.valorTotal),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Fornecedor: ${item.nomeFornecedor ?? "N/A"}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Divider(height: 20),

              // Ação Editar
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Editar Compra / Despesa'),
                onTap: () async {
                  Get.back();
                  final res = await Get.toNamed(
                    AppRoutes.compraDespesaForm,
                    arguments: item,
                  );
                  if (res == true) {
                    controller.loadAll();
                  }
                },
              ),

              // Ação Excluir
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: const Text(
                  'Excluir Compra / Despesa',
                  style: TextStyle(color: AppColors.error),
                ),
                onTap: () {
                  Get.back();
                  _confirmarExclusao(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(CompraDespesa item) {
    Get.dialog(
      AlertDialog(
        title: const Text('Excluir Compra / Despesa'),
        content: Text(
          'Deseja realmente excluir a compra "${item.descricao}" no valor de ${Formatters.formatCurrency(item.valorTotal)}?'
          '${item.temLancamentoFinanceiro ? "\n\nO lançamento a pagar associado no financeiro também será removido." : ""}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Get.back();
              await controller.deletar(item.idCompraDespesa);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
