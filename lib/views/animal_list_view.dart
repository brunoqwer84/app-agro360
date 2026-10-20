import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../models/animal.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Tela organizada do Cadastro e Rebanho de Animais
/// Exibe a distribuição quantitativa de corte e leite separados por propriedade
class AnimalListView extends StatefulWidget {
  const AnimalListView({super.key});

  @override
  State<AnimalListView> createState() => _AnimalListViewState();
}

class _AnimalListViewState extends State<AnimalListView> {
  late final AnimalController controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<AnimalController>();
    _searchController.text = controller.searchQuery.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rebanho & Animais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar rebanho',
            onPressed: () => controller.refreshAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Painel de Estatísticas de Corte e Leite por Propriedade
          _buildPropriedadesStatsSection(),

          // 2. Barra de Busca e Filtros de Tipo de Produção / Status
          _buildFiltersBar(),

          // 3. Lista de Animais Filtrada
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.animais.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.animais.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhum animal cadastrado',
                    subtitle:
                        'Adicione os primeiros animais de corte ou leite ao rebanho',
                    actionLabel: 'Novo Animal',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.animaisForm);
                    },
                  );
                }

                final filteredList = controller.animaisFiltrados;

                if (filteredList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'Nenhum animal encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Tente ajustar os filtros de propriedade, corte ou leite',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearchQuery('');
                              controller.filtrarPorPropriedade(null);
                              controller.filtrarPorTipoProducao('TODOS');
                              controller.filtrarPorStatus('TODOS');
                            },
                            icon: const Icon(Icons.clear_all_rounded, size: 16),
                            label: const Text('Limpar todos os filtros'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.xl * 2,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final animal = filteredList[index];
                    return _AnimalCard(
                      animal: animal,
                      controller: controller,
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnNovoAnimal',
        onPressed: () {
          controller.clearSelection();
          Get.toNamed(AppRoutes.animaisForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Novo Animal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: AppElevation.level3,
      ),
    );
  }

  /// Painel com resumo quantitativo de Corte e Leite por Propriedade
  Widget _buildPropriedadesStatsSection() {
    return Obx(() {
      final statsList = controller.statsPorPropriedade;
      final selectedId = controller.selectedPropriedadeId.value;

      if (controller.animais.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart_outline_rounded,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Rebanho por Propriedade',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                if (selectedId != null)
                  GestureDetector(
                    onTap: () => controller.filtrarPorPropriedade(null),
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Carrossel horizontal de propriedades
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Card Geral (Todas as propriedades)
                  _buildPropertyStatCard(
                    title: 'Total Geral',
                    isAll: true,
                    isSelected: selectedId == null,
                    total: controller.totalGeral,
                    corte: controller.totalCorteGeral,
                    leite: controller.totalLeiteGeral,
                    misto: controller.totalMistoGeral,
                    onTap: () => controller.filtrarPorPropriedade(null),
                  ),

                  // Cards de cada Propriedade
                  ...statsList.map((stat) {
                    final isSelected = selectedId == stat.idPropriedade;
                    return Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: _buildPropertyStatCard(
                        title: stat.nomePropriedade,
                        isAll: false,
                        isSelected: isSelected,
                        total: stat.total,
                        corte: stat.corte,
                        leite: stat.leite,
                        misto: stat.misto,
                        onTap: () =>
                            controller.filtrarPorPropriedade(stat.idPropriedade),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Card visual de estatísticas de cada propriedade
  Widget _buildPropertyStatCard({
    required String title,
    required bool isAll,
    required bool isSelected,
    required int total,
    required int corte,
    required int leite,
    required int misto,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 175,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 6 : 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título da Fazenda / Propriedade
            Row(
              children: [
                Icon(
                  isAll ? Icons.public_rounded : Icons.landscape_rounded,
                  size: 15,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppRadius.round),
                  ),
                  child: Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),

            // Distribuição quantitativa de Corte e Leite
            Row(
              children: [
                // Corte
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.categoryOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.agriculture_rounded,
                                size: 10, color: AppColors.categoryOrange),
                            SizedBox(width: 2),
                            Text(
                              'Corte',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.categoryOrange,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$corte',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.categoryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),

                // Leite
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.water_drop_outlined,
                                size: 10, color: AppColors.info),
                            SizedBox(width: 2),
                            Text(
                              'Leite',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$leite',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Se houver animais de produção Mista
            if (misto > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      size: 11, color: AppColors.textSecondary),
                  const SizedBox(width: 3),
                  Text(
                    'Misto: $misto',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Barra de busca e filtros rápidos
  Widget _buildFiltersBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        children: [
          // Campo de busca com debounce visual
          AppInput(
            label: 'Buscar animal',
            hint: 'Brinco/ID, raça ou fazenda...',
            controller: _searchController,
            icon: Icons.search_rounded,
            onChanged: (val) => controller.setSearchQuery(val),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      controller.setSearchQuery('');
                    },
                  )
                : const SizedBox.shrink()),
          ),
          const SizedBox(height: 6),

          // Filtros de Tipo de Produção (Todos, Corte, Leite, Misto) e Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildProducaoFilterChip('TODOS', 'Todos os Tipos'),
                const SizedBox(width: AppSpacing.xs),
                _buildProducaoFilterChip(
                  'CORTE',
                  'Corte',
                  icon: Icons.agriculture_rounded,
                  activeColor: AppColors.categoryOrange,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildProducaoFilterChip(
                  'LEITE',
                  'Leite',
                  icon: Icons.water_drop_outlined,
                  activeColor: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                _buildProducaoFilterChip(
                  'MISTO',
                  'Misto',
                  icon: Icons.swap_horiz_rounded,
                  activeColor: AppColors.categoryPurple,
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(width: 1, height: 20, color: AppColors.divider),
                const SizedBox(width: AppSpacing.sm),

                // Filtro de Status
                _buildStatusFilterChip('ATIVO', 'Ativos'),
                const SizedBox(width: AppSpacing.xs),
                _buildStatusFilterChip('TODOS', 'Todos Status'),
                const SizedBox(width: AppSpacing.xs),
                _buildStatusFilterChip('INATIVO', 'Inativos'),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Indicador de filtro de propriedade ativo
          Obx(() {
            final propId = controller.selectedPropriedadeId.value;
            if (propId == null) return const SizedBox.shrink();

            final propNome = controller.propriedades
                    .firstWhereOrNull((p) => p.idPropriedade == propId)
                    ?.nome ??
                'Propriedade #$propId';

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.round),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.filter_alt_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Filtrado por: $propNome',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => controller.filtrarPorPropriedade(null),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProducaoFilterChip(
    String code,
    String label, {
    IconData? icon,
    Color? activeColor,
  }) {
    return Obx(() {
      final isSelected = controller.tipoProducaoFiltro.value == code;
      final color = activeColor ?? AppColors.primary;

      return FilterChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : color,
              )
            : null,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.filtrarPorTipoProducao(code),
        selectedColor: color,
        backgroundColor: AppColors.surface,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
      );
    });
  }

  Widget _buildStatusFilterChip(String code, String label) {
    return Obx(() {
      final isSelected = controller.statusFiltro.value == code;
      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.filtrarPorStatus(code),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
      );
    });
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 6,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          padding: AppSpacing.md,
          child: Row(
            children: [
              AppSkeleton(width: 44, height: 44, borderRadius: AppRadius.md),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(
                        width: 140, height: 18, borderRadius: AppRadius.sm),
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(
                        width: double.infinity,
                        height: 14,
                        borderRadius: AppRadius.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card de exibição organizada de cada animal
class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.controller,
  });

  final Animal animal;
  final AnimalController controller;

  Widget _buildProducaoBadge() {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (animal.isCorte) {
      bg = AppColors.categoryOrange.withValues(alpha: 0.12);
      fg = AppColors.categoryOrange;
      icon = Icons.agriculture_rounded;
      label = 'Corte';
    } else if (animal.isLeite) {
      bg = AppColors.info.withValues(alpha: 0.12);
      fg = AppColors.info;
      icon = Icons.water_drop_outlined;
      label = 'Leite';
    } else if (animal.isMisto) {
      bg = AppColors.categoryPurple.withValues(alpha: 0.12);
      fg = AppColors.categoryPurple;
      icon = Icons.swap_horiz_rounded;
      label = 'Misto';
    } else {
      bg = AppColors.textSecondary.withValues(alpha: 0.1);
      fg = AppColors.textSecondary;
      icon = Icons.pets_rounded;
      label = animal.tipoProducao ?? 'Geral';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isActive = animal.isAtivo;
    final isMacho = animal.isMacho;
    final propNome = animal.propriedade.nome.isNotEmpty
        ? animal.propriedade.nome
        : 'Propriedade #${animal.idPropriedade}';
    final racaDesc = animal.raca.descricao.isNotEmpty
        ? animal.raca.descricao
        : 'Raça #${animal.idRaca}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(animal);
        Get.toNamed(AppRoutes.animaisForm, arguments: animal);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha Superior: Ícone, Identificação, Fazenda, Status e Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar do animal com destaque para tipo de produção
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: animal.isCorte
                      ? AppColors.categoryOrange.withValues(alpha: 0.12)
                      : animal.isLeite
                          ? AppColors.info.withValues(alpha: 0.12)
                          : AppColors.categoryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Icon(
                    animal.isCorte
                        ? Icons.agriculture_rounded
                        : animal.isLeite
                            ? Icons.water_drop_outlined
                            : Icons.pets_rounded,
                    color: animal.isCorte
                        ? AppColors.categoryOrange
                        : animal.isLeite
                            ? AppColors.info
                            : AppColors.categoryBrown,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Identificação e Propriedade
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          animal.identificacao,
                          style: textTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        _buildProducaoBadge(),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.landscape_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            propNome,
                            style: textTheme.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badge
              AppStatusBadge(
                label: isActive ? 'Ativo' : 'Inativo',
                type:
                    isActive ? AppStatusType.active : AppStatusType.inactive,
                size: AppStatusBadgeSize.small,
              ),

              // Menu Popup de Ações
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    controller.selectForEdit(animal);
                    Get.toNamed(AppRoutes.animaisForm, arguments: animal);
                  } else if (val == 'delete') {
                    _confirmarExclusao(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.info),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Excluir',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Rodapé com detalhes: Raça, Sexo, Idade
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Raça
              _buildTag(
                icon: Icons.category_rounded,
                label: racaDesc,
                color: AppColors.categoryAmber,
              ),

              // Sexo
              _buildTag(
                icon: isMacho ? Icons.male_rounded : Icons.female_rounded,
                label: isMacho ? 'Macho' : 'Fêmea',
                color: isMacho ? AppColors.info : const Color(0xFFD946EF),
              ),

              // Idade
              if (animal.idadeAnos != null)
                _buildTag(
                  icon: Icons.cake_outlined,
                  label: '${animal.idadeAnos} ${animal.idadeAnos == 1 ? "ano" : "anos"}',
                  color: AppColors.categoryTeal,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    Get.defaultDialog(
      title: 'Excluir Animal',
      middleText:
          'Deseja realmente excluir o animal ${animal.identificacao}? Se houver manejos ou pesagens vinculadas, a exclusão será impedida.',
      textConfirm: 'Excluir',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.delete(animal.idAnimal);
      },
    );
  }
}
