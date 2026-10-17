import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/grupo_controller.dart';
import '../models/grupo.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Grupos/Empresas com busca e visual moderno
class GrupoListView extends StatefulWidget {
  const GrupoListView({super.key});

  @override
  State<GrupoListView> createState() => _GrupoListViewState();
}

class _GrupoListViewState extends State<GrupoListView> {
  final GrupoController controller = Get.find<GrupoController>();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

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
        title: const Text('Grupos & Empresas'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              label: 'Buscar grupo',
              hint: 'Nome ou CNPJ...',
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
          ),

          // Lista de grupos
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.groups.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.groups.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.business_rounded,
                    title: 'Nenhum grupo cadastrado',
                    subtitle: 'Crie o primeiro grupo ou empresa',
                    actionLabel: 'Novo Grupo',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.gruposForm);
                    },
                  );
                }

                final query = _searchQuery.value.toLowerCase();
                final filtered = controller.groups.where((g) {
                  if (query.isEmpty) return true;
                  final nome = g.nome.toLowerCase();
                  final cnpj = g.cnpj?.toLowerCase() ?? '';
                  return nome.contains(query) || cnpj.contains(query);
                }).toList();

                if (filtered.isEmpty) {
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
                            'Nenhum grupo encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
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
                    AppSpacing.md,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final grupo = filtered[index];
                    return _GrupoCard(grupo: grupo, controller: controller);
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
          Get.toNamed(AppRoutes.gruposForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Novo Grupo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: AppElevation.level3,
      ),
    );
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
                      width: 180,
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

class _GrupoCard extends StatelessWidget {
  const _GrupoCard({
    required this.grupo,
    required this.controller,
  });

  final Grupo grupo;
  final GrupoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isActive = grupo.ativo;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(grupo);
        Get.toNamed(AppRoutes.gruposForm, arguments: grupo);
      },
      child: Row(
        children: [
          // Ícone em squircle roxo/indigo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.categoryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.business_rounded,
                color: AppColors.categoryPurple,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações do Grupo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        grupo.nome,
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusBadge(
                      label: isActive ? 'Ativo' : 'Inativo',
                      type: isActive
                          ? AppStatusType.active
                          : AppStatusType.inactive,
                      size: AppStatusBadgeSize.small,
                    ),
                  ],
                ),
                if (grupo.cnpj != null && grupo.cnpj!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatCnpj(grupo.cnpj!),
                        style: textTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
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
                controller.selectForEdit(grupo);
                Get.toNamed(AppRoutes.gruposForm, arguments: grupo);
              } else if (val == 'delete') {
                _showDeleteDialog(grupo);
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

  void _showDeleteDialog(Grupo grupo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Excluir grupo?'),
        content: Text(
          'Deseja excluir "${grupo.nome}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(grupo.idGrupo);
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
