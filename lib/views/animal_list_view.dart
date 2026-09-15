import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/raca_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Lista de Animais
class AnimalListView extends GetView<AnimalController> {
  const AnimalListView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final propriedadeController = Get.find<PropriedadeController>();
    final racaController = Get.find<RacaController>();

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant,
      appBar: AppBar(
        title: const Text(
          'Animais',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.animais.isEmpty) {
            return _buildLoadingSkeleton();
          }
          if (controller.animais.isEmpty) {
            return AppEmptyState(
              icon: Icons.pets,
              title: 'Nenhum animal cadastrado',
              subtitle: 'Adicione o primeiro animal ao seu rebanho',
              actionLabel: 'Novo Animal',
              onAction: () {
                controller.clearSelection();
                Get.toNamed('/animais/form');
              },
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: controller.animais.length,
            itemBuilder: (context, index) {
              final a = controller.animais[index];
              final prop = propriedadeController.properties.firstWhereOrNull(
                (p) => p.idPropriedade == a.idPropriedade,
              );
              final raca = racaController.racas.firstWhereOrNull(
                (r) => r.idRaca == a.idRaca,
              );
              return _AnimalCard(
                animal: a,
                propriedade: prop,
                raca: raca,
                controller: controller,
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearSelection();
          Get.toNamed('/animais/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    AppSkeleton(width: 180, height: 14, borderRadius: AppRadius.sm),
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(width: 140, height: 14, borderRadius: AppRadius.sm),
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

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.propriedade,
    required this.raca,
    required this.controller,
  });

  final dynamic animal;
  final dynamic propriedade;
  final dynamic raca;
  final AnimalController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isActive = animal.status == 'ATIVO';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(animal);
        Get.toNamed('/animais/form', arguments: animal);
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.pets, color: Colors.brown.shade600, size: 24),
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
                        animal.identificacao,
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppStatusBadge(
                      label: isActive ? 'Ativo' : 'Inativo',
                      type: isActive ? AppStatusType.active : AppStatusType.inactive,
                      size: AppStatusBadgeSize.small,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (propriedade != null)
                  Text(
                    propriedade.nome,
                    style: textTheme.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (raca != null)
                  Text(
                    raca.descricao,
                    style: textTheme.bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
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
                  controller.selectForEdit(animal);
                  Get.toNamed('/animais/form', arguments: animal);
                },
                tooltip: 'Editar',
                padding: const EdgeInsets.all(AppSpacing.sm),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: colorScheme.error, size: 20),
                onPressed: () => _showDeleteDialog(animal),
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

  void _showDeleteDialog(dynamic animal) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja excluir "${animal.identificacao}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(animal.idAnimal);
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