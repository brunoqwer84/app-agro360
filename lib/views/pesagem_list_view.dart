import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pesagem_controller.dart';
import '../controllers/manejo_controller.dart';
import '../models/pesagem.dart';
import '../models/manejo.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Pesagens com busca e visual moderno
class PesagemListView extends StatefulWidget {
  const PesagemListView({super.key});

  @override
  State<PesagemListView> createState() => _PesagemListViewState();
}

class _PesagemListViewState extends State<PesagemListView> {
  final PesagemController controller = Get.find<PesagemController>();
  final ManejoController manejoController = Get.find<ManejoController>();
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
        title: const Text('Controle de Pesagens'),
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              label: 'Buscar pesagem',
              hint: 'Identificação do animal...',
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

          // Lista de pesagens
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.pesagens.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.pesagens.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Nenhuma pesagem cadastrada',
                    subtitle: 'Registre a pesagem de um animal do rebanho',
                    actionLabel: 'Nova Pesagem',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.pesagensForm);
                    },
                  );
                }

                final query = _searchQuery.value.toLowerCase();
                final filtered = controller.pesagens.where((p) {
                  if (query.isEmpty) return true;
                  final animalId =
                      p.animal?.identificacao.toLowerCase() ?? '';
                  final pesoStr = p.pesoKg.toString();
                  return animalId.contains(query) || pesoStr.contains(query);
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
                            'Nenhuma pesagem encontrada',
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
                    final pesagem = filtered[index];
                    final manejo = pesagem.manejo ??
                        manejoController.manejos.firstWhereOrNull(
                          (m) => m.idManejo == pesagem.idManejo,
                        );
                    return _PesagemCard(
                      pesagem: pesagem,
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
          Get.toNamed(AppRoutes.pesagensForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Nova Pesagem',
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

class _PesagemCard extends StatelessWidget {
  const _PesagemCard({
    required this.pesagem,
    required this.manejo,
    required this.controller,
  });

  final Pesagem pesagem;
  final Manejo? manejo;
  final PesagemController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(pesagem);
        Get.toNamed(AppRoutes.pesagensForm, arguments: pesagem);
      },
      child: Row(
        children: [
          // Ícone em squircle azul
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.categoryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Icon(
                Icons.monitor_weight_rounded,
                color: AppColors.categoryBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações de Pesagem
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Animal: ${pesagem.animal?.identificacao ?? 'N/A'}',
                        style: textTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Badge de Peso em destaque
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.categoryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                        border: Border.all(
                          color: AppColors.categoryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        Formatters.formatWeight(pesagem.pesoKg),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.categoryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (manejo != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Manejo em ${Formatters.formatDate(manejo!.data)}',
                        style: textTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
                controller.selectForEdit(pesagem);
                Get.toNamed(AppRoutes.pesagensForm, arguments: pesagem);
              } else if (val == 'delete') {
                _showDeleteDialog(pesagem);
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

  void _showDeleteDialog(Pesagem pesagem) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Excluir pesagem?'),
        content: Text(
          'Deseja excluir a pesagem de ${Formatters.formatWeight(pesagem.pesoKg)}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.delete(pesagem.idPesagem);
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
