import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/raca_controller.dart';
import '../models/raca.dart';
import '../utils/app_colors.dart';
import '../utils/cow_head_icon.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Raças com busca e visual moderno
class RacaListView extends GetView<RacaController> {
  const RacaListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Raças & Genética'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              label: 'Buscar raça',
              hint: 'Ex: Nelore, Angus, Gir...',
              icon: Icons.search_rounded,
              onChanged: (value) => controller.searchDebounced(value),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.racas.isEmpty) {
                  return _buildLoadingSkeleton();
                }
                if (controller.racas.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhuma raça cadastrada',
                    subtitle: 'Cadastre a primeira raça do seu rebanho',
                    actionLabel: 'Nova Raça',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.racasForm);
                    },
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                  itemCount: controller.racas.length,
                  itemBuilder: (context, index) {
                    final raca = controller.racas[index];
                    return _RacaCard(raca: raca, controller: controller);
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
          Get.toNamed(AppRoutes.racasForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nova Raça',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: AppElevation.level3,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
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
                        borderRadius: AppRadius.sm),
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(
                        width: 80, height: 14, borderRadius: AppRadius.sm),
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

class _RacaCard extends StatelessWidget {
  const _RacaCard({
    required this.raca,
    required this.controller,
  });

  final Raca raca;
  final RacaController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(raca);
        Get.toNamed(AppRoutes.racasForm, arguments: raca);
      },
      child: Row(
        children: [
          // Ícone em squircle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.categoryAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(child: CowHeadIcon(size: 26)),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações da Raça
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  raca.descricao,
                  style: textTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                      'Código #${raca.idRaca}',
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
                controller.selectForEdit(raca);
                Get.toNamed(AppRoutes.racasForm, arguments: raca);
              } else if (val == 'delete') {
                _showDeleteDialog(raca);
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

  void _showDeleteDialog(Raca raca) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Excluir raça?'),
        content: Text(
          'Deseja excluir a raça "${raca.descricao}"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(raca.idRaca);
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
