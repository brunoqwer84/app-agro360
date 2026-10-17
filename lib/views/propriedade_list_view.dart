import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/propriedade_controller.dart';
import '../models/propriedade.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Propriedades com busca e filtros
class PropriedadeListView extends StatefulWidget {
  const PropriedadeListView({super.key});

  @override
  State<PropriedadeListView> createState() => _PropriedadeListViewState();
}

class _PropriedadeListViewState extends State<PropriedadeListView> {
  final PropriedadeController controller = Get.find<PropriedadeController>();
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
        title: const Text('Fazendas & Propriedades'),
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
                  label: 'Buscar propriedade',
                  hint: 'Nome da fazenda...',
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

                // Filtros de status
                Obx(() {
                  final total = controller.properties.length;
                  final ativas = controller.properties
                      .where((p) => p.ativo == true)
                      .length;
                  final inativas = total - ativas;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('TODAS', 'Todas ($total)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('ATIVAS', 'Ativas ($ativas)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('INATIVAS', 'Inativas ($inativas)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista de propriedades
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.properties.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.properties.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.landscape_rounded,
                    title: 'Nenhuma propriedade cadastrada',
                    subtitle: 'Comece criando sua primeira fazenda',
                    actionLabel: 'Nova Propriedade',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.propriedadesForm);
                    },
                  );
                }

                // Filtragem reativa
                final query = _searchQuery.value.toLowerCase();
                final filter = _statusFilter.value;

                final filteredList = controller.properties.where((prop) {
                  if (filter == 'ATIVAS' && prop.ativo != true) {
                    return false;
                  }
                  if (filter == 'INATIVAS' && prop.ativo == true) {
                    return false;
                  }
                  if (query.isNotEmpty) {
                    return prop.nome.toLowerCase().contains(query);
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
                            'Nenhuma propriedade encontrada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tente buscar por outro termo',
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
                    final p = filteredList[index];
                    return _PropertyCard(property: p, controller: controller);
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
          Get.toNamed(AppRoutes.propriedadesForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nova Fazenda',
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

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({
    required this.property,
    required this.controller,
  });

  final Propriedade property;
  final PropriedadeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isActive = property.ativo == true;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(property);
        Get.toNamed(AppRoutes.propriedadesForm, arguments: property);
      },
      child: Row(
        children: [
          // Ícone em squircle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.categoryTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.landscape_rounded,
                color: AppColors.categoryTeal,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações da propriedade
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        property.nome,
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusBadge(
                      label: isActive ? 'Ativa' : 'Inativa',
                      type: isActive
                          ? AppStatusType.active
                          : AppStatusType.inactive,
                      size: AppStatusBadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.tag_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Código #${property.idPropriedade}',
                      style: textTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
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
                controller.selectForEdit(property);
                Get.toNamed(AppRoutes.propriedadesForm, arguments: property);
              } else if (val == 'delete') {
                _showDeleteDialog(property);
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

  void _showDeleteDialog(Propriedade property) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${property.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(property.idPropriedade);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
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
