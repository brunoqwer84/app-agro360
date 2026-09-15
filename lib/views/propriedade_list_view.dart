import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/propriedade_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Lista de Propriedades
class PropriedadeListView extends GetView<PropriedadeController> {
  const PropriedadeListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text(
          'Propriedades',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.properties.isEmpty) {
            return _buildLoadingSkeleton();
          }
          if (controller.properties.isEmpty) {
            return AppEmptyState(
              icon: Icons.landscape,
              title: 'Nenhuma propriedade cadastrada',
              subtitle: 'Comece criando sua primeira propriedade',
              actionLabel: 'Nova Propriedade',
              onAction: () {
                controller.clearSelection();
                Get.toNamed('/propriedades/form');
              },
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: controller.properties.length,
            itemBuilder: (context, index) {
              final p = controller.properties[index];
              return _PropertyCard(property: p, controller: controller);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearSelection();
          Get.toNamed('/propriedades/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              AppSkeleton(width: 48, height: 48, borderRadius: AppRadius.round),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: double.infinity, height: 18, borderRadius: AppRadius.sm),
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(width: 120, height: 14, borderRadius: AppRadius.sm),
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

  final dynamic property;
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
        Get.toNamed('/propriedades/form', arguments: property);
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.landscape, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
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
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusBadge(
                      label: isActive ? 'Ativa' : 'Inativa',
                      type: isActive ? AppStatusType.active : AppStatusType.inactive,
                      size: AppStatusBadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ID: ${property.idPropriedade}',
                  style: textTheme.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined, color: colorScheme.info, size: 20),
                onPressed: () {
                  controller.selectForEdit(property);
                  Get.toNamed('/propriedades/form', arguments: property);
                },
                tooltip: 'Editar',
                padding: const EdgeInsets.all(AppSpacing.sm),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                onPressed: () => _showDeleteDialog(property),
                tooltip: 'Excluir',
                padding: const EdgeInsets.all(AppSpacing.sm),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic property) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}