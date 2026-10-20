import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pessoa_controller.dart';
import '../models/pessoa.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Clientes & Fornecedores do Módulo Financeiro
class PessoaListView extends StatefulWidget {
  const PessoaListView({super.key});

  @override
  State<PessoaListView> createState() => _PessoaListViewState();
}

class _PessoaListViewState extends State<PessoaListView> {
  late final PessoaController controller;
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PessoaController>()
        ? Get.find<PessoaController>()
        : Get.put<PessoaController>(PessoaController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip({
    required String label,
    required String code,
    IconData? icon,
  }) {
    return Obx(() {
      final isSelected = controller.filtroTipo.value == code;
      return FilterChip(
        avatar: icon != null
            ? Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.primary,
              )
            : null,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.setFiltroTipo(code),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clientes & Fornecedores'),
      ),
      body: Column(
        children: [
          // Barra de busca e filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: AppInput(
              label: 'Buscar cliente ou fornecedor',
              hint: 'Nome, CPF/CNPJ, e-mail...',
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

          // Chips de filtro por tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Todos',
                    code: 'TODOS',
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterChip(
                    label: 'Clientes',
                    code: 'C',
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterChip(
                    label: 'Fornecedores',
                    code: 'F',
                    icon: Icons.local_shipping_outlined,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Lista de contatos
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.pessoas.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.pessoas.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'Nenhum cliente ou fornecedor',
                    subtitle:
                        'Cadastre parceiros comerciais para vincular às contas e despesas',
                    actionLabel: 'Novo Cadastro',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.pessoasForm);
                    },
                  );
                }

                final query = _searchQuery.value.toLowerCase();
                final baseList = controller.pessoasFiltradas;
                final filtered = baseList.where((p) {
                  if (query.isEmpty) return true;
                  final nome = p.nome.toLowerCase();
                  final cpfCnpj = p.cpfCnpj.toLowerCase();
                  final email = p.email?.toLowerCase() ?? '';
                  final fone = p.fone?.toLowerCase() ?? '';
                  final end = p.endereco?.resumo.toLowerCase() ?? '';
                  final cidade = p.endereco?.cidade?.toLowerCase() ?? '';
                  return nome.contains(query) ||
                      cpfCnpj.contains(query) ||
                      email.contains(query) ||
                      fone.contains(query) ||
                      end.contains(query) ||
                      cidade.contains(query);
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
                            'Nenhum cadastro encontrado',
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
                    final pessoa = filtered[index];
                    return _PessoaCard(pessoa: pessoa, controller: controller);
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
          Get.toNamed(AppRoutes.pessoasForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text(
          'Novo Cadastro',
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

class _PessoaCard extends StatelessWidget {
  const _PessoaCard({
    required this.pessoa,
    required this.controller,
  });

  final Pessoa pessoa;
  final PessoaController controller;

  Widget _buildTipoBadge() {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    if (pessoa.tipo == 'C') {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
      icon = Icons.person_rounded;
      label = 'Cliente';
    } else if (pessoa.tipo == 'F') {
      bg = AppColors.categoryOrange.withValues(alpha: 0.12);
      fg = AppColors.categoryOrange;
      icon = Icons.local_shipping_outlined;
      label = 'Fornecedor';
    } else {
      bg = AppColors.primary.withValues(alpha: 0.12);
      fg = AppColors.primary;
      icon = Icons.swap_horiz_rounded;
      label = 'Cliente & Fornecedor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
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

    final isActive = pessoa.ativo;
    final initial = pessoa.nome.isNotEmpty
        ? pessoa.nome.trim()[0].toUpperCase()
        : 'P';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(pessoa);
        Get.toNamed(AppRoutes.pessoasForm, arguments: pessoa);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar em squircle com inicial
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: pessoa.tipo == 'C'
                  ? AppColors.success.withValues(alpha: 0.12)
                  : pessoa.tipo == 'F'
                      ? AppColors.categoryOrange.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: pessoa.tipo == 'C'
                      ? AppColors.success
                      : pessoa.tipo == 'F'
                          ? AppColors.categoryOrange
                          : AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Informações da Pessoa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pessoa.nome,
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
                const SizedBox(height: 4),

                // Badge de tipo (Cliente / Fornecedor)
                _buildTipoBadge(),
                const SizedBox(height: 6),

                // CPF/CNPJ
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      Formatters.formatCpfCnpj(pessoa.cpfCnpj),
                      style: textTheme.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Telefone (se informado)
                if (pessoa.fone != null && pessoa.fone!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        Formatters.formatPhone(pessoa.fone!),
                        style: textTheme.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],

                // E-mail (se informado)
                if (pessoa.email != null && pessoa.email!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          pessoa.email!,
                          style: textTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Endereço (se informado)
                if (pessoa.endereco != null && pessoa.endereco!.hasEndereco) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          pessoa.endereco!.resumo,
                          style: textTheme.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            onSelected: (action) {
              if (action == 'edit') {
                controller.selectForEdit(pessoa);
                Get.toNamed(AppRoutes.pessoasForm, arguments: pessoa);
              } else if (action == 'delete') {
                _confirmarExclusao(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.textPrimary),
                    SizedBox(width: AppSpacing.sm),
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
                    SizedBox(width: AppSpacing.sm),
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

  void _confirmarExclusao(BuildContext context) {
    Get.defaultDialog(
      title: 'Excluir Cadastro',
      middleText:
          'Deseja realmente excluir ${pessoa.nome}? Se houver lançamentos vinculados, a exclusão será impedida.',
      textConfirm: 'Excluir',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.delete(pessoa.idPessoa);
      },
    );
  }
}
