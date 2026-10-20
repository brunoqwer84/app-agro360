import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/financeiro_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Tela Home - Layout limpo e essencial com foco na operação do produtor
class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  Future<void> _refreshAll() async {
    final syncController = Get.find<SyncController>();
    final futures = <Future>[
      syncController.syncAll(),
      Get.find<PropriedadeController>().loadAll(),
      Get.find<AnimalController>().loadAll(),
    ];

    if (Get.isRegistered<ManejoController>()) {
      futures.add(Get.find<ManejoController>().loadAll());
    }
    if (Get.isRegistered<FinanceiroController>()) {
      futures.add(Get.find<FinanceiroController>().loadAll());
    }

    await Future.wait(futures);
  }

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
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SidebarNavigation(selectedIndex: 0),
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: _buildAppBar(syncController),
              body: RefreshIndicator(
                onRefresh: _refreshAll,
                child: _buildHomeBody(context),
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
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(syncController),
      drawer: const SidebarNavigation(selectedIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: _buildHomeBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(SyncController syncController) {
    return AppBar(
      title: const Text('Agro360'),
      elevation: 0,
      actions: [
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
                ? 'Sincronizado na nuvem'
                : 'Modo offline',
          );
        }),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Cabeçalho do Produtor (Saudação limpa)
              _buildUserProfile(context),
              const SizedBox(height: AppSpacing.md),

              // 2. Apontamentos Rápidos (1-tap para novos registros)
              _buildQuickShortcuts(context),
              const SizedBox(height: AppSpacing.lg),

              // 3. Indicadores Operacionais Essenciais
              _buildKeyMetrics(context),
              const SizedBox(height: AppSpacing.xl),

              // 4. Módulos Essenciais de Operação
              _buildEssentialModules(context),
              const SizedBox(height: AppSpacing.xl),
            ]),
          ),
        ),
      ],
    );
  }

  /// Cabeçalho acolhedor com nome do usuário e grupo ativo
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
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(
                user.nomePessoa.isNotEmpty
                    ? user.nomePessoa[0].toUpperCase()
                    : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $firstName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.business_rounded,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.grupo?.nome ?? 'Agropecuária',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Atalhos diretos para novos lançamentos rápidos no campo
  Widget _buildQuickShortcuts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'Novo Registro Rápido',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _buildShortcutButton(
                label: 'Manejo',
                icon: Icons.assignment_add,
                color: AppColors.categoryOrange,
                onTap: () => Get.toNamed(AppRoutes.manejosForm),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildShortcutButton(
                label: 'Animal',
                icon: Icons.pets_rounded,
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.animaisForm),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildShortcutButton(
                label: 'Financeiro',
                icon: Icons.attach_money_rounded,
                color: AppColors.success,
                onTap: () => Get.toNamed(AppRoutes.financeiroForm),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4 Indicadores Essenciais da Operação (Rebanho, Manejos, Saldo Financeiro, Fazendas)
  Widget _buildKeyMetrics(BuildContext context) {
    return Obx(() {
      final animalController = Get.find<AnimalController>();
      final propriedadeController = Get.find<PropriedadeController>();

      final animaisCount = animalController.animais.length;
      final propriedadesCount = propriedadeController.properties.length;

      final manejoCount = Get.isRegistered<ManejoController>()
          ? Get.find<ManejoController>().manejos.length
          : 0;

      final balanco = Get.isRegistered<FinanceiroController>()
          ? Get.find<FinanceiroController>().balanco.value
          : null;
      final saldoFinanceiro = balanco?.saldo ?? 0.0;
      final isSaldoPositivo = saldoFinanceiro >= 0;

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount =
              constraints.maxWidth < AppBreakpoints.tablet ? 2 : 4;

          return GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              mainAxisExtent: 108,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _MetricCard(
                title: 'Rebanho',
                value: '$animaisCount',
                subtitle: animaisCount == 1 ? '1 animal' : '$animaisCount animais',
                icon: Icons.pets_rounded,
                color: AppColors.primary,
                onTap: () => Get.toNamed(AppRoutes.animais),
              ),
              _MetricCard(
                title: 'Manejos',
                value: '$manejoCount',
                subtitle: 'Eventos de campo',
                icon: Icons.assignment_outlined,
                color: AppColors.categoryOrange,
                onTap: () => Get.toNamed(AppRoutes.manejos),
              ),
              _MetricCard(
                title: 'Balanço',
                value: Formatters.formatCurrency(saldoFinanceiro),
                subtitle: isSaldoPositivo ? 'Saldo positivo' : 'Saldo devedor',
                icon: Icons.account_balance_wallet_outlined,
                color: isSaldoPositivo ? AppColors.success : AppColors.error,
                onTap: () => Get.toNamed(AppRoutes.financeiro),
              ),
              _MetricCard(
                title: 'Propriedades',
                value: '$propriedadesCount',
                subtitle: propriedadesCount == 1
                    ? '1 fazenda ativa'
                    : '$propriedadesCount fazendas',
                icon: Icons.landscape_outlined,
                color: AppColors.categoryTeal,
                onTap: () => Get.toNamed(AppRoutes.propriedades),
              ),
            ],
          );
        },
      );
    });
  }

  /// 4 Módulos Centrais (Sem poluição de cadastros auxiliares)
  Widget _buildEssentialModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.dashboard_customize_outlined,
                size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Módulos Principais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                constraints.maxWidth < AppBreakpoints.tablet ? 1 : 2;

            return GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                mainAxisExtent: 76,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ModuleCard(
                  title: 'Manejos & Sanidade',
                  subtitle: 'Manejos de campo, pesagens e vacinações',
                  icon: Icons.agriculture_rounded,
                  color: AppColors.categoryOrange,
                  onTap: () => Get.toNamed(AppRoutes.manejos),
                ),
                _ModuleCard(
                  title: 'Controle do Rebanho',
                  subtitle: 'Fichas dos animais, lotes e raças',
                  icon: Icons.pets_rounded,
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(AppRoutes.animais),
                ),
                _ModuleCard(
                  title: 'Gestão Financeira',
                  subtitle: 'Contas a pagar, a receber e balanço',
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  onTap: () => Get.toNamed(AppRoutes.financeiro),
                ),
                _ModuleCard(
                  title: 'Fazendas & Pastos',
                  subtitle: 'Propriedades rurais e divisões',
                  icon: Icons.landscape_rounded,
                  color: AppColors.categoryTeal,
                  onTap: () => Get.toNamed(AppRoutes.propriedades),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Card de Métrica Operacional compacto e limpo
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
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

/// Card de Módulo Essencial limpo e refinado
class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.md,
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
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.textHint,
          ),
        ],
      ),
    );
  }
}
