import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/raca_controller.dart';
import '../models/animal.dart';
import '../models/propriedade.dart';
import '../models/raca.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';

/// Lista de Animais com busca instantânea e filtros
class AnimalListView extends StatefulWidget {
  const AnimalListView({super.key});

  @override
  State<AnimalListView> createState() => _AnimalListViewState();
}

class _AnimalListViewState extends State<AnimalListView> {
  final AnimalController controller = Get.find<AnimalController>();
  final PropriedadeController propriedadeController =
      Get.find<PropriedadeController>();
  final RacaController racaController = Get.find<RacaController>();

  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _statusFilter = 'TODOS'.obs;

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
        title: const Text('Rebanho & Animais'),
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
                  label: 'Buscar animal',
                  hint: 'Identificação, brinco ou raça...',
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
                  final total = controller.animais.length;
                  final ativos = controller.animais
                      .where((a) => a.status == 'ATIVO')
                      .length;
                  final inativos = total - ativos;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('TODOS', 'Todos ($total)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('ATIVO', 'Ativos ($ativos)'),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('INATIVO', 'Inativos ($inativos)'),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Lista de animais
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadAll(),
              child: Obx(() {
                if (controller.isLoading.value && controller.animais.isEmpty) {
                  return _buildLoadingSkeleton();
                }

                if (controller.animais.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.pets_rounded,
                    title: 'Nenhum animal cadastrado',
                    subtitle: 'Adicione o primeiro animal ao seu rebanho',
                    actionLabel: 'Novo Animal',
                    onAction: () {
                      controller.clearSelection();
                      Get.toNamed(AppRoutes.animaisForm);
                    },
                  );
                }

                // Filtragem reativa
                final query = _searchQuery.value.toLowerCase();
                final filter = _statusFilter.value;

                final filteredList = controller.animais.where((animal) {
                  // Filtro de status
                  if (filter == 'ATIVO' && animal.status != 'ATIVO') {
                    return false;
                  }
                  if (filter == 'INATIVO' && animal.status == 'ATIVO') {
                    return false;
                  }

                  // Filtro de busca
                  if (query.isNotEmpty) {
                    final matchId =
                        animal.identificacao.toLowerCase().contains(query);
                    final raca = racaController.racas.firstWhereOrNull(
                      (r) => r.idRaca == animal.idRaca,
                    );
                    final matchRaca =
                        raca?.descricao.toLowerCase().contains(query) ?? false;
                    final prop =
                        propriedadeController.properties.firstWhereOrNull(
                      (p) => p.idPropriedade == animal.idPropriedade,
                    );
                    final matchProp =
                        prop?.nome.toLowerCase().contains(query) ?? false;
                    return matchId || matchRaca || matchProp;
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
                            'Nenhum animal encontrado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Tente alterar os termos da busca ou filtros',
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
                    final a = filteredList[index];
                    final prop =
                        propriedadeController.properties.firstWhereOrNull(
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearSelection();
          Get.toNamed(AppRoutes.animaisForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Novo Animal',
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
                    SizedBox(height: AppSpacing.xs),
                    AppSkeleton(
                      width: 100,
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

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({
    required this.animal,
    required this.propriedade,
    required this.raca,
    required this.controller,
  });

  final Animal animal;
  final Propriedade? propriedade;
  final Raca? raca;
  final AnimalController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final isActive = animal.status == 'ATIVO';
    final isMacho = animal.sexo == 'M';

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.md,
      onTap: () {
        controller.selectForEdit(animal);
        Get.toNamed(AppRoutes.animaisForm, arguments: animal);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Topo: Ícone + Identificação + Status + Menu de Ações
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge de ícone
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.categoryBrown.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets_rounded,
                    color: AppColors.categoryBrown,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Identificação e Fazenda
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.identificacao,
                      style: textTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (propriedade != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.landscape_rounded,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              propriedade!.nome,
                              style: textTheme.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
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

              // Status Badge
              AppStatusBadge(
                label: isActive ? 'Ativo' : 'Inativo',
                type:
                    isActive ? AppStatusType.active : AppStatusType.inactive,
                size: AppStatusBadgeSize.small,
              ),

              // Menu Popup de Ações
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
                    controller.selectForEdit(animal);
                    Get.toNamed(AppRoutes.animaisForm, arguments: animal);
                  } else if (val == 'delete') {
                    _showDeleteDialog(context, animal);
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

          const SizedBox(height: AppSpacing.sm + 2),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm + 2),

          // Rodapé do Card com Tags (Raça, Sexo, Produção)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Raça
              if (raca != null)
                _buildTag(
                  icon: Icons.category_rounded,
                  label: raca!.descricao,
                  color: AppColors.categoryAmber,
                ),

              // Sexo
              _buildTag(
                icon: isMacho ? Icons.male_rounded : Icons.female_rounded,
                label: isMacho ? 'Macho' : 'Fêmea',
                color: isMacho ? AppColors.info : const Color(0xFFD946EF),
              ),

              // Tipo de Produção
              if (animal.tipoProducao != null &&
                  animal.tipoProducao!.isNotEmpty)
                _buildTag(
                  icon: Icons.inventory_2_outlined,
                  label: animal.tipoProducao!,
                  color: AppColors.categoryTeal,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Animal animal) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        title: const Text('Confirmar exclusão'),
        content: Text(
          'Deseja excluir o animal "${animal.identificacao}"?',
        ),
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
