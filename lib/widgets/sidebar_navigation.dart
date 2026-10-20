import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../utils/app_colors.dart';
import '../utils/app_logo.dart';
import '../theme/app_theme.dart';

/// Sidebar de navegação lateral
class SidebarNavigation extends StatelessWidget {
  final int selectedIndex;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
  });

  static const List<_SidebarSection> _sections = [
    _SidebarSection(
      title: 'Principal',
      items: [
        _SidebarItemData(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppRoutes.home,
            index: 0),
      ],
    ),
    _SidebarSection(
      title: 'Cadastros',
      items: [
        _SidebarItemData(
            icon: Icons.business_outlined,
            label: 'Grupos / Empresas',
            route: AppRoutes.grupos,
            index: 1),
        _SidebarItemData(
            icon: Icons.landscape_outlined,
            label: 'Propriedades',
            route: AppRoutes.propriedades,
            index: 2),
      ],
    ),
    _SidebarSection(
      title: 'Produção',
      items: [
        _SidebarItemData(
            icon: Icons.pets_outlined,
            label: 'Animais',
            route: AppRoutes.animais,
            index: 3),
        _SidebarItemData(
            icon: Icons.category_outlined,
            label: 'Raças',
            route: AppRoutes.racas,
            index: 4),
        _SidebarItemData(
            icon: Icons.assignment_outlined,
            label: 'Manejos',
            route: AppRoutes.manejos,
            index: 5),
        _SidebarItemData(
            icon: Icons.monitor_weight_outlined,
            label: 'Pesagens',
            route: AppRoutes.pesagens,
            index: 6),
        _SidebarItemData(
            icon: Icons.medical_services_outlined,
            label: 'Vacinações',
            route: AppRoutes.vacinacoes,
            index: 7),
      ],
    ),
    _SidebarSection(
      title: 'Financeiro',
      items: [
        _SidebarItemData(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Contas & Balanço',
            route: AppRoutes.financeiro,
            index: 8),
        _SidebarItemData(
            icon: Icons.shopping_bag_outlined,
            label: 'Compras & Despesas',
            route: AppRoutes.compraDespesa,
            index: 9),
        _SidebarItemData(
            icon: Icons.category_outlined,
            label: 'Categorias',
            route: AppRoutes.categoriasFinanceiras,
            index: 10),
        _SidebarItemData(
            icon: Icons.people_outline,
            label: 'Clientes & Fornecedores',
            route: AppRoutes.pessoas,
            index: 11),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put<AuthController>(AuthController(), permanent: true);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF0F301B),
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header com logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A2213), Color(0xFF154427)],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Agro360LogoLogin(size: 48),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agro360',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                        Text(
                          'Gestão Agropecuária',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu de navegação
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              children: [
                for (final section in _sections) ...[
                  // Section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      section.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                    ),
                  ),
                  // Section items
                  ...section.items.map((item) => _SidebarItem(
                        data: item,
                        isSelected: selectedIndex == item.index,
                        onTap: item.route != null
                            ? () => Get.toNamed(item.route!)
                            : () => Get.snackbar(
                                  'Em desenvolvimento',
                                  'Funcionalidade em breve',
                                  backgroundColor:
                                      AppColors.info.withValues(alpha: 0.1),
                                  colorText: AppColors.info,
                                ),
                      )),
                ],
              ],
            ),
          ),

          // Rodapé com usuário e logout
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0A2213),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Obx(() {
                  final user = authController.currentUser.value;
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          child: user?.nomePessoa.isNotEmpty == true
                              ? Text(
                                  user!.nomePessoa[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nomePessoa ?? 'Usuário',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              user != null ? '@${user.nomeUsuario}' : '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            size: 20, color: Colors.white70),
                        tooltip: 'Sair da conta',
                        onPressed: () => authController.logout(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Item do sidebar
class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _SidebarItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            data.icon,
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.7),
            size: 21,
          ),
          title: Text(
            data.label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedTileColor: const Color(0xFF237A4B),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: isSelected
                ? BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  )
                : BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 2,
          ),
          dense: true,
          visualDensity: VisualDensity.compact,
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: Colors.white.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}

class _SidebarSection {
  final String title;
  final List<_SidebarItemData> items;

  const _SidebarSection({required this.title, required this.items});
}

class _SidebarItemData {
  final IconData icon;
  final String label;
  final String? route;
  final int index;

  const _SidebarItemData({
    required this.icon,
    required this.label,
    required this.route,
    required this.index,
  });
}
