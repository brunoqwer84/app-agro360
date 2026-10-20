import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/categoria_financeira_controller.dart';
import '../models/categoria_financeira.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Tela de listagem e gerenciamento de Categorias Financeiras (Despesas 'P' e Receitas 'R')
class CategoriaFinanceiraListView extends StatefulWidget {
  const CategoriaFinanceiraListView({super.key});

  @override
  State<CategoriaFinanceiraListView> createState() =>
      _CategoriaFinanceiraListViewState();
}

class _CategoriaFinanceiraListViewState
    extends State<CategoriaFinanceiraListView> {
  late final CategoriaFinanceiraController controller;
  String? _filtroTipo; // null = Todas, 'P', 'R'

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CategoriaFinanceiraController>()
        ? Get.find<CategoriaFinanceiraController>()
        : Get.put<CategoriaFinanceiraController>(
            CategoriaFinanceiraController());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categorias Financeiras'),
      ),
      body: Column(
        children: [
          // Barra de filtros por tipo
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _buildFilterChip('Todas', null),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('Despesas (P)', 'P', color: AppColors.error),
                const SizedBox(width: AppSpacing.xs),
                _buildFilterChip('Receitas (R)', 'R', color: AppColors.success),
              ],
            ),
          ),

          // Lista de categorias
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.categorias.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                var lista = controller.categorias.toList();
                if (_filtroTipo != null) {
                  lista = lista
                      .where((c) =>
                          c.tipo.toUpperCase() == _filtroTipo!.toUpperCase())
                      .toList();
                }

                if (lista.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.category_outlined,
                    title: 'Nenhuma categoria encontrada',
                    subtitle:
                        'Cadastre categorias para organizar seus lançamentos a pagar e a receber.',
                    actionLabel: 'Nova Categoria',
                    onAction: () =>
                        Get.toNamed(AppRoutes.categoriasFinanceirasForm),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    return _buildCategoriaCard(item);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'btnNovaCategoria',
        onPressed: () => Get.toNamed(AppRoutes.categoriasFinanceirasForm),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Nova Categoria',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? tipo, {Color? color}) {
    final selected = _filtroTipo == tipo;
    final chipColor = color ?? AppColors.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          color: selected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      onSelected: (_) {
        setState(() => _filtroTipo = tipo);
      },
      selectedColor: chipColor,
      backgroundColor: AppColors.card,
      checkmarkColor: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 0),
      visualDensity: VisualDensity.compact,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.round),
      ),
    );
  }

  Widget _buildCategoriaCard(CategoriaFinanceira item) {
    final isDespesa = item.isDespesa;
    final color = isDespesa ? AppColors.error : AppColors.success;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.md,
      onTap: () =>
          Get.toNamed(AppRoutes.categoriasFinanceirasForm, arguments: item),
      child: Row(
        children: [
          // Badge tipo P / R
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                item.tipo.toUpperCase(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações da categoria
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nome,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.ativo)
                      const AppStatusBadge(
                        label: 'INATIVO',
                        type: AppStatusType.inactive,
                        size: AppStatusBadgeSize.small,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  isDespesa ? 'Despesa (A Pagar)' : 'Receita (A Receber)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (item.descricao != null && item.descricao!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.descricao!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Menu de opções
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onSelected: (val) {
              if (val == 'edit') {
                Get.toNamed(AppRoutes.categoriasFinanceirasForm,
                    arguments: item);
              } else if (val == 'delete') {
                _confirmarExclusao(item);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(CategoriaFinanceira item) {
    Get.defaultDialog(
      title: 'Excluir Categoria',
      middleText: 'Deseja excluir a categoria "${item.nome}"?',
      textConfirm: 'Excluir',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.deleteCategoria(item.idCategoria);
      },
    );
  }
}
