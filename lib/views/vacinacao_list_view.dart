import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vacinacao_controller.dart';
import '../models/vacinacao.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Vacinações com busca e filtros
class VacinacaoListView extends StatefulWidget {
  const VacinacaoListView({super.key});

  @override
  State<VacinacaoListView> createState() => _VacinacaoListViewState();
}

class _VacinacaoListViewState extends State<VacinacaoListView> {
  final VacinacaoController controller = Get.find<VacinacaoController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _statusFilter = 'TODAS'.obs;

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
        title: const Text('Sanidade & Vacinações'),
      ),
      body: Column(
        children: [
          // Barra de busca e filtros rápidos
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              children: [
                // Campo de busca
                AppInput(
                  label: 'Buscar vacinação',
                  hint: 'Nome da vacina ou animal...',
                  controller: _searchController,
                  icon: Icons.search_rounded,
                  onChanged: (val) => _searchQuery.value = val.trim(),
                  suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _searchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Filtros de status de vacinação
                Obx(() {
                  final total = controller.vacinacoes.length;
                  final vencidas =
                      controller.vacinacoes.where((v) => v.isVencida).length;
                  final emDia = total - vencidas;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('TODAS', 'Todas ($total)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('EM_DIA', 'Em dia ($emDia)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('VENCIDAS', 'Vencidas ($vencidas)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista de vacinações
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.vacinacoes.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.vacinacoes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.vaccines_rounded,
                    title: 'Nenhuma vacinação cadastrada',
                    subtitle: 'Registre a primeira vacina do seu rebanho',
                    actionLabel: 'Nova Vacinação',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.vacinacoesForm);
                    },
                  );
                }

                final query = _searchQuery.value.toLowerCase();
                final filter = _statusFilter.value;

                final filteredList = controller.vacinacoes.where((vac) {
                  if (filter == 'VENCIDAS' && !vac.isVencida) {
                    return false;
                  }
                  if (filter == 'EM_DIA' && vac.isVencida) {
                    return false;
                  }

                  if (query.isNotEmpty) {
                    final matchName = vac.nome.toLowerCase().contains(query);
                    final matchAnimal = vac.animal?.identificacao
                            .toLowerCase()
                            .contains(query) ??
                        false;
                    return matchName || matchAnimal;
                  }
                  return true;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textHint,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Nenhuma vacinação encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tente alterar os filtros de busca',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final vacinacao = filteredList[index];
                    return _VacinacaoCard(
                      vacinacao: vacinacao,
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
        onPressed: () {
          controller.clearSelection();
          Get.toNamed(AppRoutes.vacinacoesForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nova Vacinação',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: AppElevation.level3,
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    return Obx(() {
      final isSelected = _statusFilter.value == key;
      return FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.round),
        ),
        onSelected: (_) => _statusFilter.value = key,
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
              AppSkeleton(width: 48, height: 48, borderRadius: AppRadius.md),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(
                      width: 140,
                      height: 18,
                      borderRadius: AppRadius.sm,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(
                      width: double.infinity,
                      height: 14,
                      borderRadius: AppRadius.sm,
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
}

class _VacinacaoCard extends StatelessWidget {
  const _VacinacaoCard({
    required this.vacinacao,
    required this.controller,
  });

  final Vacinacao vacinacao;
  final VacinacaoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isVencida = vacinacao.isVencida;
    final diasRestantes = vacinacao.diasRestantes;
    final badgeLabel = isVencida
        ? 'Vencida'
        : diasRestantes == 0
            ? 'Em dia'
            : 'Em $diasRestantes dia${diasRestantes == 1 ? '' : 's'}';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(vacinacao);
        Get.toNamed(AppRoutes.vacinacoesForm, arguments: vacinacao);
      },
      child: Row(
        children: [
          // Ícone em squircle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isVencida
                  ? colorScheme.error.withValues(alpha: 0.12)
                  : AppColors.categoryRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              isVencida ? Icons.warning_amber_rounded : Icons.vaccines_rounded,
              color: isVencida ? colorScheme.error : AppColors.categoryRed,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações da Vacinação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vacinacao.nome,
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusBadge(
                      label: badgeLabel,
                      type: isVencida
                          ? AppStatusType.error
                          : AppStatusType.pending,
                      size: AppStatusBadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.pets_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Animal: ${vacinacao.animal?.identificacao ?? 'N/A'}',
                      style: textTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat_rounded,
                      size: 13,
                      color: isVencida
                          ? colorScheme.error
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Próxima dose: ${Formatters.formatDate(vacinacao.proximaDose)}',
                      style: textTheme.bodySmall.copyWith(
                        color: isVencida
                            ? colorScheme.error
                            : AppColors.textSecondary,
                        fontWeight:
                            isVencida ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu de Ações
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
                controller.selectForEdit(vacinacao);
                Get.toNamed(AppRoutes.vacinacoesForm, arguments: vacinacao);
              } else if (val == 'delete') {
                _showDeleteDialog(vacinacao);
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
    );
  }

  void _showDeleteDialog(Vacinacao vacinacao) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Excluir vacinação?'),
        content: Text(
          'Deseja excluir a vacinação "${vacinacao.nome}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(vacinacao.idVacinacao);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
