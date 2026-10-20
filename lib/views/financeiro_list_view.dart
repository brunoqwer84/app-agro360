import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/financeiro_controller.dart';
import '../models/lancamento_financeiro.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Tela de Gestão Financeira com abas (Contas a Pagar, Contas a Receber, Balanço e Extrato)
class FinanceiroListView extends StatefulWidget {
  const FinanceiroListView({super.key});

  @override
  State<FinanceiroListView> createState() => _FinanceiroListViewState();
}

class _FinanceiroListViewState extends State<FinanceiroListView>
    with SingleTickerProviderStateMixin {
  late final FinanceiroController controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<FinanceiroController>()
        ? Get.find<FinanceiroController>()
        : Get.put<FinanceiroController>(FinanceiroController());
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Financeiro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Compras & Despesas',
            onPressed: () => Get.toNamed(AppRoutes.compraDespesa),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorias Financeiras',
            onPressed: () => Get.toNamed(AppRoutes.categoriasFinanceiras),
          ),
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Clientes & Fornecedores',
            onPressed: () => Get.toNamed(AppRoutes.pessoas),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: 'A Pagar', icon: Icon(Icons.arrow_downward_rounded)),
            Tab(text: 'A Receber', icon: Icon(Icons.arrow_upward_rounded)),
            Tab(text: 'Balanço', icon: Icon(Icons.pie_chart_outline_rounded)),
            Tab(text: 'Extrato', icon: Icon(Icons.receipt_long_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Seletor de Período / Exercício
          _buildPeriodSelector(),

          // Resumo numérico rápido do período
          _buildQuickSummaryCard(),

          // Conteúdo das Abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListTab(
                    tipo: 'DESPESA', tituloVazio: 'Nenhuma conta a pagar'),
                _buildListTab(
                    tipo: 'RECEITA', tituloVazio: 'Nenhuma conta a receber'),
                _buildBalancoTab(),
                _buildListTab(
                    tipo: null, tituloVazio: 'Nenhum lançamento no período'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnNovoLancamento',
        onPressed: () => Get.toNamed(AppRoutes.financeiroForm),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label:
            const Text('Novo Lançamento', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// Barra de seleção de período do exercício
  Widget _buildPeriodSelector() {
    return Obx(() {
      final periodo = controller.periodoSelecionado.value;
      final dtInicio = controller.dataInicio.value;
      final dtFim = controller.dataFim.value;

      String rangeLabel = 'Todos os lançamentos';
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
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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
                const Icon(Icons.event_note_rounded,
                    size: 14, color: AppColors.textSecondary),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.aplicarPeriodo(
        PeriodoExercicio.customizado,
        customInicio: picked.start,
        customFim: picked.end,
      );
    }
  }

  /// Cartão de métricas do período selecionado
  Widget _buildQuickSummaryCard() {
    return Obx(() {
      final balanco = controller.balanco.value;
      final receitas = balanco?.totalReceitas ?? 0.0;
      final despesas = balanco?.totalDespesas ?? 0.0;
      final saldo = balanco?.saldo ?? 0.0;
      final isPositivo = saldo >= 0;

      return Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
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
            // Receitas
            _buildMetricItem(
              title: 'Receitas',
              value: Formatters.formatCurrency(receitas),
              icon: Icons.trending_up_rounded,
              color: AppColors.success,
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            // Despesas
            _buildMetricItem(
              title: 'Despesas',
              value: Formatters.formatCurrency(despesas),
              icon: Icons.trending_down_rounded,
              color: AppColors.error,
            ),
            Container(width: 1, height: 36, color: AppColors.divider),
            // Saldo
            _buildMetricItem(
              title: 'Saldo Líquido',
              value: Formatters.formatCurrency(saldo),
              icon: Icons.account_balance_wallet_rounded,
              color: isPositivo ? AppColors.success : AppColors.error,
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

  /// Lista de lançamentos (A Pagar, A Receber ou Extrato)
  Widget _buildListTab({required String? tipo, required String tituloVazio}) {
    return RefreshIndicator(
      onRefresh: () => controller.loadAll(),
      child: Obx(() {
        if (controller.isLoading.value && controller.lancamentos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        var lista = controller.lancamentos.toList();
        if (tipo != null) {
          if (tipo == 'P' || tipo == 'DESPESA') {
            lista = lista.where((l) => l.isDespesa).toList();
          } else if (tipo == 'R' || tipo == 'RECEITA') {
            lista = lista.where((l) => l.isReceita).toList();
          } else {
            lista = lista.where((l) => l.tipo == tipo).toList();
          }
        }

        if (lista.isEmpty) {
          return AppEmptyState(
            icon: Icons.receipt_long_rounded,
            title: tituloVazio,
            subtitle:
                'Nenhum registro encontrado para o período selecionado.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          itemCount: lista.length,
          itemBuilder: (context, index) {
            final item = lista[index];
            return _buildLancamentoCard(item);
          },
        );
      }),
    );
  }

  /// Card de um lançamento financeiro
  Widget _buildLancamentoCard(LancamentoFinanceiro item) {
    final isReceita = item.isReceita;
    final color = isReceita ? AppColors.success : AppColors.error;
    final catNome = item.nomeCategoria ?? item.categoria ?? 'Sem Categoria';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.md,
      onTap: () => _abrirDetalhesLancamento(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone tipo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceita
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Título e detalhes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.descricao,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$catNome • Venc: ${Formatters.formatDate(item.dataVencimento)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Valor e status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(item.valor),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(item),
                ],
              ),
            ],
          ),

          // Se houver manejo vinculado ou pessoa/propriedade
          if (item.idManejo != null ||
              item.nomePropriedade != null ||
              item.nomePessoa != null) ...[
            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (item.idManejo != null)
                  _buildMiniTag(
                    icon: Icons.agriculture_rounded,
                    label: item.resumoManejo != null
                        ? 'Manejo #${item.idManejo} (${item.resumoManejo})'
                        : 'Manejo #${item.idManejo}',
                    color: AppColors.primary,
                  ),
                if (item.nomePropriedade != null)
                  _buildMiniTag(
                    icon: Icons.landscape_rounded,
                    label: item.nomePropriedade!,
                    color: AppColors.categoryTeal,
                  ),
                if (item.nomePessoa != null)
                  _buildMiniTag(
                    icon: item.isReceita
                        ? Icons.person_rounded
                        : Icons.local_shipping_outlined,
                    label:
                        '${item.isReceita ? "Cliente: " : "Fornecedor: "}${item.nomePessoa!}',
                    color: item.isReceita
                        ? AppColors.success
                        : AppColors.categoryOrange,
                  ),
              ],
            ),
          ],

          // Ações rápidas
          if (item.isPendente) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _confirmarLiquidacao(item),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: Text(
                  item.isReceita ? 'Confirmar Recebimento' : 'Marcar como Pago',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isReceita ? AppColors.success : AppColors.primary,
                  visualDensity: VisualDensity.compact,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniTag(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

  Widget _buildStatusBadge(LancamentoFinanceiro item) {
    if (item.isPago) {
      return const AppStatusBadge(
        label: 'PAGO',
        type: AppStatusType.active,
        size: AppStatusBadgeSize.small,
      );
    } else if (item.isCancelado) {
      return const AppStatusBadge(
        label: 'CANCELADO',
        type: AppStatusType.inactive,
        size: AppStatusBadgeSize.small,
      );
    } else {
      final isVencido = item.isVencido;
      return AppStatusBadge(
        label: isVencido ? 'VENCIDO' : 'PENDENTE',
        type: isVencido ? AppStatusType.error : AppStatusType.pending,
        size: AppStatusBadgeSize.small,
      );
    }
  }

  /// Aba de Balanço do Exercício
  Widget _buildBalancoTab() {
    return RefreshIndicator(
      onRefresh: () => controller.loadAll(),
      child: Obx(() {
        if (controller.isLoading.value && controller.balanco.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final b = controller.balanco.value;
        if (b == null) {
          return const Center(child: Text('Nenhum dado de balanço'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card do Balanço Principal
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: b.isPositivo
                        ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                        : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BALANÇO LÍQUIDO DO EXERCÍCIO',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.formatCurrency(b.saldo),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBalancoSubitem(
                          'Receitas Realizadas',
                          Formatters.formatCurrency(b.totalReceitasPagas),
                          Colors.white,
                        ),
                        _buildBalancoSubitem(
                          'Despesas Pagas',
                          Formatters.formatCurrency(b.totalDespesasPagas),
                          Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBalancoSubitem(
                          'Receitas a Receber',
                          Formatters.formatCurrency(b.totalReceitasPendentes),
                          Colors.white70,
                        ),
                        _buildBalancoSubitem(
                          'Despesas a Pagar',
                          Formatters.formatCurrency(b.totalDespesasPendentes),
                          Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Distribuição por categoria de Despesas
              if (b.despesasPorCategoria.isNotEmpty) ...[
                const Text(
                  'Despesas por Categoria',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...b.despesasPorCategoria.entries.map((entry) {
                  final pct = b.totalDespesas > 0
                      ? (entry.value / b.totalDespesas)
                      : 0.0;
                  return _buildCategoriaBar(
                    categoria: entry.key,
                    valor: entry.value,
                    percentual: pct,
                    color: AppColors.error,
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Distribuição por categoria de Receitas
              if (b.receitasPorCategoria.isNotEmpty) ...[
                const Text(
                  'Receitas por Categoria',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...b.receitasPorCategoria.entries.map((entry) {
                  final pct = b.totalReceitas > 0
                      ? (entry.value / b.totalReceitas)
                      : 0.0;
                  return _buildCategoriaBar(
                    categoria: entry.key,
                    valor: entry.value,
                    percentual: pct,
                    color: AppColors.success,
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Resumo de contagem
              AppCard(
                padding: AppSpacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Lançamentos', '${b.totalLancamentos}'),
                    _buildStatCol('Manejos Vinculados',
                        '${b.lancamentos.where((i) => i.idManejo != null).length}'),
                    _buildStatCol('Exercício',
                        controller.periodoSelecionado.value.name.toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 60), // Margem para FAB
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalancoSubitem(String title, String val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
        const SizedBox(height: 2),
        Text(val,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildCategoriaBar({
    required String categoria,
    required double valor,
    required double percentual,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(categoria,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500)),
              Text(
                '${Formatters.formatCurrency(valor)} (${(percentual * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentual.clamp(0.0, 1.0),
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  void _confirmarLiquidacao(LancamentoFinanceiro item) {
    Get.defaultDialog(
      title: item.isReceita ? 'Confirmar Recebimento' : 'Confirmar Pagamento',
      middleText:
          'Deseja marcar "${item.descricao}" no valor de ${Formatters.formatCurrency(item.valor)} como liquidado na data de hoje?',
      textConfirm: 'Confirmar',
      textCancel: 'Voltar',
      confirmTextColor: Colors.white,
      buttonColor: item.isReceita ? AppColors.success : AppColors.primary,
      onConfirm: () {
        Get.back();
        controller.marcarComoPago(item.idLancamento);
      },
    );
  }

  void _abrirDetalhesLancamento(LancamentoFinanceiro item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                ),
                _buildStatusBadge(item),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Valor: ${Formatters.formatCurrency(item.valor)} (${item.tipo})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: item.isReceita ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Categoria: ${item.nomeCategoria ?? item.categoria ?? "-"}'),
            if (item.nomePessoa != null)
              Text('${item.isReceita ? "Cliente" : "Fornecedor"}: ${item.nomePessoa}'),
            Text('Vencimento: ${Formatters.formatDate(item.dataVencimento)}'),
            if (item.dataPagamento != null)
              Text('Pagamento: ${Formatters.formatDate(item.dataPagamento)}'),
            if (item.formaPagamento != null)
              Text('Forma de Pagamento: ${item.formaPagamento}'),
            if (item.idManejo != null)
              Text(
                  'Manejo Vinculado: #${item.idManejo} ${item.resumoManejo ?? ""}'),
            if (item.observacao != null && item.observacao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Obs: ${item.observacao}',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton.outline(
                    label: 'Editar',
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    onPressed: () {
                      Get.back();
                      Get.toNamed(AppRoutes.financeiroForm, arguments: item);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton.custom(
                    label: 'Excluir',
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 16, color: Colors.white),
                    color: AppColors.error,
                    onPressed: () {
                      Get.back();
                      _confirmarExclusao(item);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarExclusao(LancamentoFinanceiro item) {
    Get.defaultDialog(
      title: 'Excluir Lançamento',
      middleText: 'Tem certeza que deseja excluir "${item.descricao}"?',
      textConfirm: 'Excluir',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.deleteLancamento(item.idLancamento);
      },
    );
  }
}
