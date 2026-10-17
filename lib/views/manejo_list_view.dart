import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manejo_controller.dart';
import '../models/manejo.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Manejos com busca e visual moderno
class ManejoListView extends StatefulWidget {
  const ManejoListView({super.key});

  @override
  State<ManejoListView> createState() => _ManejoListViewState();
}

class _ManejoListViewState extends State<ManejoListView> {
  final ManejoController controller = Get.find<ManejoController>();
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
        title: const Text('Manejos de Campo'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              label: 'Buscar manejo',
              hint: 'Propriedade ou observação...',
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

          // Lista de manejos
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.manejos.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.manejos.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.assignment_rounded,
                    title: 'Nenhum manejo cadastrado',
                    subtitle: 'Registre o primeiro evento de manejo',
                    actionLabel: 'Novo Manejo',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.manejosForm);
                    },
                  );
                }

                final query = _searchQuery.value.toLowerCase();
                final filtered = controller.manejos.where((m) {
                  if (query.isEmpty) return true;
                  final propName =
                      m.propriedade?.nome.toLowerCase() ?? '';
                  final obs = m.observacao?.toLowerCase() ?? '';
                  final date = Formatters.formatDate(m.data).toLowerCase();
                  return propName.contains(query) ||
                      obs.contains(query) ||
                      date.contains(query);
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
                            'Nenhum manejo encontrado',
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
                    final manejo = filtered[index];
                    return _ManejoCard(
                      manejo: manejo,
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
          Get.toNamed(AppRoutes.manejosForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Novo Manejo',
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

class _ManejoCard extends StatelessWidget {
  const _ManejoCard({
    required this.manejo,
    required this.controller,
  });

  final Manejo manejo;
  final ManejoController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(manejo);
        Get.toNamed(AppRoutes.manejosForm, arguments: manejo);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone em squircle laranja
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.categoryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.assignment_rounded,
                color: AppColors.categoryOrange,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações do Manejo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        manejo.propriedade?.nome ?? 'Propriedade',
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatDate(manejo.data),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  manejo.observacao?.isNotEmpty == true
                      ? manejo.observacao!
                      : 'Sem observações registradas',
                  style: textTheme.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                controller.selectForEdit(manejo);
                Get.toNamed(AppRoutes.manejosForm, arguments: manejo);
              } else if (val == 'delete') {
                _showDeleteDialog(manejo);
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

  void _showDeleteDialog(Manejo manejo) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Excluir manejo?'),
        content: Text(
          'Excluir o manejo de ${Formatters.formatDate(manejo.data)}? Esta ação não pode ser desfeita.\n\nManejos com pesagens ou vacinações vinculadas não podem ser excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(manejo.idManejo);
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
