import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
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
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return _buildDesktopLayout(syncController);
        } else {
          return _buildMobileLayout(syncController);
        }
      },
    );
  }

  Widget _buildDesktopLayout(SyncController syncController) {
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
                onRefresh: () => syncController.syncAll(),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Informações do usuário
                          _buildUserProfile(),
                          const SizedBox(height: AppSpacing.xl),

                          // Cards de resumo
                          _buildSummaryCards(),
                          const SizedBox(height: AppSpacing.xl),

                          // Ações rápidas
                          _buildQuickActions(),
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

  Widget _buildMobileLayout(SyncController syncController) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(syncController),
      drawer: const SidebarNavigation(
        selectedIndex: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => syncController.syncAll(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Informações do usuário
                  _buildUserProfile(),
                  const SizedBox(height: AppSpacing.xl),

                  // Cards de resumo
                  _buildSummaryCards(),
                  const SizedBox(height: AppSpacing.xl),

                  // Ações rápidas
                  _buildQuickActions(),
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
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
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
                        ? Icons.cloud_done
                        : Icons.cloud_off,
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

  Widget _buildUserProfile() {
    return Obx(() {
      final user = controller.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      return AppCard(
        padding: AppSpacing.lg,
        gradient: AppColors.cardGradient,
        border: Border.all(color: AppColors.divider),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 32,
              child: Text(
                user.nomePessoa.isNotEmpty
                    ? user.nomePessoa[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nomePessoa,
                    style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '@${user.nomeUsuario}',
                    style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final user = controller.currentUser.value;
      final syncController = Get.find<SyncController>();

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 700 ? 2 : 4;
          return GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SummaryCard(
                title: 'Grupo',
                value: user?.grupo?.nome ?? 'N/A',
                icon: Icons.business,
                color: AppColors.primary,
                trend: null,
              ),
              _SummaryCard(
                title: 'Propriedades',
                value: '0',
                icon: Icons.landscape,
                color: Colors.teal.shade700,
                trend: null,
              ),
              _SummaryCard(
                title: 'Animais',
                value: '0',
                icon: Icons.pets,
                color: Colors.brown.shade600,
                trend: null,
              ),
              _SummaryCard(
                title: 'Sincronização',
                value: syncController.isConnected.value ? 'Online' : 'Offline',
                icon: Icons.cloud,
                color: syncController.isConnected.value
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                trend: syncController.isConnected.value ? 'Conectado' : 'Sem conexão',
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flash_on_outlined, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Ações Rápidas',
                style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600
                ? 3
                : constraints.maxWidth < 900
                    ? 4
                    : constraints.maxWidth < 1200
                        ? 5
                        : 6;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ActionCard(
                  icon: Icons.business_outlined,
                  title: 'Grupos / Empresas',
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(AppRoutes.grupos),
                ),
                _ActionCard(
                  icon: Icons.landscape_outlined,
                  title: 'Propriedades',
                  color: Colors.teal.shade700,
                  onTap: () => Get.toNamed(AppRoutes.propriedades),
                ),
                _ActionCard(
                  icon: Icons.people_outline,
                  title: 'Pessoas',
                  color: Colors.blue.shade700,
                  onTap: () => Get.snackbar(
                    'Em desenvolvimento',
                    'Funcionalidade em breve',
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    colorText: AppColors.info,
                  ),
                ),
                _ActionCard(
                  icon: Icons.pets_outlined,
                  title: 'Animais',
                  color: Colors.brown.shade600,
                  onTap: () => Get.toNamed(AppRoutes.animais),
                ),
                _ActionCard(
                  icon: Icons.category_outlined,
                  title: 'Raças',
                  color: Colors.amber.shade700,
                  onTap: () => Get.toNamed(AppRoutes.racas),
                  customIcon: const CowHeadIcon(size: 28),
                ),
                _ActionCard(
                  icon: Icons.assignment_outlined,
                  title: 'Manejos',
                  color: Colors.orange.shade700,
                  onTap: () => Get.toNamed(AppRoutes.manejos),
                ),
                _ActionCard(
                  icon: Icons.monitor_weight_outlined,
                  title: 'Pesagens',
                  color: Colors.blue.shade700,
                  onTap: () => Get.toNamed(AppRoutes.pesagens),
                ),
                _ActionCard(
                  icon: Icons.medical_services_outlined,
                  title: 'Vacinações',
                  color: Colors.red.shade700,
                  onTap: () => Get.toNamed(AppRoutes.vacinacoes),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Card de resumo do dashboard
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      padding: AppSpacing.sm,
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const Spacer(),
              if (trend != null)
                AppStatusBadge(
                  label: trend!,
                  type: color == Colors.green.shade700
                      ? AppStatusType.active
                      : color == Colors.red.shade700
                          ? AppStatusType.error
                          : AppStatusType.info,
                  size: AppStatusBadgeSize.small,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: textTheme.displaySmall.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: textTheme.labelMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de ação rápida
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.customIcon,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final Widget? customIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return AppCard(
      padding: AppSpacing.xs,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: customIcon ??
                Icon(
                  icon,
                  size: 22,
                  color: color,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}