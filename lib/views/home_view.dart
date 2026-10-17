import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/animal_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/cow_head_icon.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Tela Home - Layout com sidebar lateral (desktop) ou drawer (mobile)
class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.tablet;

        if (isDesktop) {
          return _buildDesktopLayout(context, syncController);
        } else {
          return _buildMobileLayout(context, syncController);
        }
      },
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, SyncController syncController) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Sidebar
          const SidebarNavigation(
            selectedIndex: 0,
          ),

          // Conteúdo principal
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.surface,
              appBar: _buildAppBar(syncController),
              body: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    syncController.syncAll(),
                    Get.find<PropriedadeController>().loadAll(),
                    Get.find<AnimalController>().loadAll(),
                  ]);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Informações do usuário
                          _buildUserProfile(context),
                          const SizedBox(height: AppSpacing.xl),

                          // Cards de resumo
                          _buildSummaryCards(),
                          const SizedBox(height: AppSpacing.xl),

                          // Ações rápidas
                          _buildQuickActions(context),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, SyncController syncController) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(syncController),
      drawer: const SidebarNavigation(
        selectedIndex: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            syncController.syncAll(),
            Get.find<PropriedadeController>().loadAll(),
            Get.find<AnimalController>().loadAll(),
          ]);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Informações do usuário
                  _buildUserProfile(context),
                  const SizedBox(height: AppSpacing.xl),

                  // Cards de resumo
                  _buildSummaryCards(),
                  const SizedBox(height: AppSpacing.xl),

                  // Ações rápidas
                  _buildQuickActions(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SyncController syncController) {
    return AppBar(
      title: const Text('Dashboard'),
      elevation: 0,
      actions: [
        // Botão de sincronização
        Obx(() {
          return IconButton(
            icon: syncController.isSyncing.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    syncController.isConnected.value
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                  ),
            onPressed: syncController.isSyncing.value
                ? null
                : () => syncController.syncAll(),
            tooltip: syncController.isConnected.value
                ? 'Online - Sincronizar'
                : 'Offline',
          );
        }),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? 'Bom dia'
          : hour < 18
              ? 'Boa tarde'
              : 'Boa noite';
      final firstName = user.nomePessoa.isNotEmpty
          ? user.nomePessoa.split(' ').first
          : 'Produtor';

      return Container(
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Avatar com borda destacada
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    user.nomePessoa.isNotEmpty
                        ? user.nomePessoa[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Informações do produtor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Grupo / Empresa
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius:
                                BorderRadius.circular(AppRadius.round),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.business_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.grupo?.nome ?? 'Agro360',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge Admin
                        if (user.isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE68A),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.round),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final user = controller.currentUser.value;
      final syncController = Get.find<SyncController>();
      final propriedadeController = Get.find<PropriedadeController>();
      final animalController = Get.find<AnimalController>();

      final propriedadesCount = propriedadeController.properties.length;
      final animaisCount = animalController.animais.length;
      final grupoNome = user?.grupo?.nome ?? 'N/A';
      final isConnected = syncController.isConnected.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              constraints.maxWidth < AppBreakpoints.tablet ? 2 : 4;
          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              mainAxisExtent: 136,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SummaryCard(
                title: 'Propriedades',
                value: propriedadesCount.toString(),
                subtitle: propriedadesCount == 1
                    ? '1 fazenda ativa'
                    : '$propriedadesCount fazendas',
                icon: Icons.landscape_rounded,
                color: AppColors.categoryTeal,
                onTap: () => Get.toNamed(AppRoutes.propriedades),
              ),
              _SummaryCard(
                title: 'Animais',
                value: animaisCount.toString(),
                subtitle: animaisCount == 1
                    ? '1 animal ativo'
                    : '$animaisCount no rebanho',
                icon: Icons.pets_rounded,
                color: AppColors.categoryBrown,
                onTap: () => Get.toNamed(AppRoutes.animais),
              ),
              _SummaryCard(
                title: 'Grupo / Empresa',
                value: grupoNome,
                subtitle: 'Unidade produtiva',
                icon: Icons.business_rounded,
                color: AppColors.categoryPurple,
                onTap: () => Get.toNamed(AppRoutes.grupos),
              ),
              _SummaryCard(
                title: 'Sincronização',
                value: isConnected ? 'Online' : 'Offline',
                subtitle: isConnected ? 'Dados na nuvem' : 'Modo local',
                icon: isConnected
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                color: isConnected ? AppColors.success : AppColors.error,
                badgeType:
                    isConnected ? AppStatusType.active : AppStatusType.error,
                onTap: () => syncController.syncAll(),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Módulos & Gestão',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < AppBreakpoints.mobile
                ? 2
                : constraints.maxWidth < AppBreakpoints.tablet
                    ? 3
                    : 4;
            return GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                mainAxisExtent: 88,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionCard(
                  icon: Icons.landscape_rounded,
                  title: 'Propriedades',
                  subtitle: 'Fazendas & pastos',
                  color: AppColors.categoryTeal,
                  onTap: () => Get.toNamed(AppRoutes.propriedades),
                ),
                _ActionCard(
                  icon: Icons.pets_rounded,
                  title: 'Animais',
                  subtitle: 'Rebanho & lotes',
                  color: AppColors.categoryBrown,
                  onTap: () => Get.toNamed(AppRoutes.animais),
                ),
                _ActionCard(
                  icon: Icons.category_rounded,
                  title: 'Raças',
                  subtitle: 'Genética & raças',
                  color: AppColors.categoryAmber,
                  onTap: () => Get.toNamed(AppRoutes.racas),
                  customIcon: const CowHeadIcon(size: 24),
                ),
                _ActionCard(
                  icon: Icons.assignment_rounded,
                  title: 'Manejos',
                  subtitle: 'Eventos de campo',
                  color: AppColors.categoryOrange,
                  onTap: () => Get.toNamed(AppRoutes.manejos),
                ),
                _ActionCard(
                  icon: Icons.monitor_weight_rounded,
                  title: 'Pesagens',
                  subtitle: 'Ganho de peso',
                  color: AppColors.categoryBlue,
                  onTap: () => Get.toNamed(AppRoutes.pesagens),
                ),
                _ActionCard(
                  icon: Icons.medical_services_rounded,
                  title: 'Vacinações',
                  subtitle: 'Sanidade & doses',
                  color: AppColors.categoryRed,
                  onTap: () => Get.toNamed(AppRoutes.vacinacoes),
                ),
                _ActionCard(
                  icon: Icons.business_rounded,
                  title: 'Grupos',
                  subtitle: 'Empresas & filiais',
                  color: AppColors.categoryPurple,
                  onTap: () => Get.toNamed(AppRoutes.grupos),
                ),
                _ActionCard(
                  icon: Icons.people_rounded,
                  title: 'Pessoas',
                  subtitle: 'Equipe & contatos',
                  color: AppColors.info,
                  onTap: () => Get.snackbar(
                    'Em desenvolvimento',
                    'Funcionalidade em breve',
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    colorText: AppColors.info,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Card de resumo métrico do dashboard
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.badgeType,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final AppStatusType? badgeType;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      padding: AppSpacing.md,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              if (badgeType != null)
                AppStatusBadge(
                  label: value,
                  type: badgeType!,
                  size: AppStatusBadgeSize.small,
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle ?? title,
                style: textTheme.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de ação rápida com design refinado
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.customIcon,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      padding: AppSpacing.sm + 2,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: customIcon ??
                  Icon(
                    icon,
                    size: 22,
                    color: color,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
