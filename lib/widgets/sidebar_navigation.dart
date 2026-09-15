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
  final Function(int)? onItemTapped;

  const SidebarNavigation({
    super.key,
    required this.selectedIndex,
    this.onItemTapped,
  });

  static const List<_SidebarSection> _sections = [
    _SidebarSection(
      title: 'Principal',
      items: [
        _SidebarItemData(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.home, index: 0),
      ],
    ),
    _SidebarSection(
      title: 'Cadastros',
      items: [
        _SidebarItemData(icon: Icons.business_outlined, label: 'Grupos / Empresas', route: AppRoutes.grupos, index: 1),
        _SidebarItemData(icon: Icons.landscape_outlined, label: 'Propriedades', route: AppRoutes.propriedades, index: 2),
        _SidebarItemData(icon: Icons.people_outline, label: 'Pessoas', route: null, index: 3),
      ],
    ),
    _SidebarSection(
      title: 'Produção',
      items: [
        _SidebarItemData(icon: Icons.pets_outlined, label: 'Animais', route: AppRoutes.animais, index: 4),
        _SidebarItemData(icon: Icons.category_outlined, label: 'Raças', route: AppRoutes.racas, index: 5),
        _SidebarItemData(icon: Icons.assignment_outlined, label: 'Manejos', route: AppRoutes.manejos, index: 6),
        _SidebarItemData(icon: Icons.monitor_weight_outlined, label: 'Pesagens', route: AppRoutes.pesagens, index: 7),
        _SidebarItemData(icon: Icons.medical_services_outlined, label: 'Vacinações', route: AppRoutes.vacinacoes, index: 8),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Container(
      width: 280,
      color: AppColors.primaryDark,
      child: Column(
        children: [
          // Header com logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Agro360LogoLogin(size: 56),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Agro360',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Gerenciamento Agropecuário',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
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
                        color: Colors.white.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Section items
                  ...section.items.map((item) => _SidebarItem(
                        data: item,
                        isSelected: selectedIndex == item.index,
                        onTap: item.route != null
                            ? () => onItemTapped?.call(item.index)
                            : () => Get.snackbar(
                                  'Em desenvolvimento',
                                  'Funcionalidade em breve',
                                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
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
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Column(
              children: [
                Obx(() {
                  final user = authController.currentUser.value;
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: user?.nomePessoa.isNotEmpty == true
                            ? Text(
                                user!.nomePessoa[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 20,
                                color: AppColors.primary,
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
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
                              user?.nomeUsuario ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.find<AuthController>().logout();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sair'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                ),
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
    return ListTile(
      leading: Icon(
        data.icon,
        color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
        size: 22,
      ),
      title: Text(
        data.label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.2),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      dense: true,
      visualDensity: VisualDensity.compact,
      hoverColor: Colors.white.withValues(alpha: 0.1),
      focusColor: Colors.white.withValues(alpha: 0.1),
      splashColor: Colors.white.withValues(alpha: 0.15),
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