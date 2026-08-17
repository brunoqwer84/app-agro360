import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
import '../utils/app_colors.dart';
import '../utils/cow_head_icon.dart';

/// Tela Home - Design moderno com paleta Agro360
class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Agro360',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
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

          // Menu de opções
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'sync') {
                syncController.syncAll();
              } else if (value == 'pull') {
                syncController.pullFromServer();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Sincronizar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pull',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download),
                    SizedBox(width: 8),
                    Text('Baixar dados'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do usuário
            Obx(() {
              final user = controller.currentUser.value;
              if (user == null) {
                return const SizedBox.shrink();
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 24,
                      child: Text(
                        user.nomePessoa.isNotEmpty
                            ? user.nomePessoa[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nomePessoa,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@${user.nomeUsuario}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.isAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),

            // Título do menu
            Row(
              children: [
                Icon(Icons.grid_view, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Menu Principal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grid de opções
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    icon: Icons.people,
                    title: 'Pessoas',
                    color: AppColors.primary,
                    onTap: () {
                      Get.snackbar(
                          'Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.pets,
                    title: 'Animais',
                    color: Colors.brown.shade600,
                    onTap: () {
                      Get.toNamed('/animais');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.eco,
                    title: 'Raças',
                    color: Colors.amber.shade700,
                    onTap: () {
                      Get.toNamed('/racas');
                    },
                    customIcon: const CowHeadIcon(size: 30),
                  ),
_buildMenuCard(
                    icon: Icons.landscape,
                    title: 'Propriedades',
                    color: Colors.teal.shade700,
                    onTap: () {
                      Get.toNamed('/propriedades');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.medical_services,
                    title: 'Manejos',
                    color: Colors.orange.shade700,
                    onTap: () {
                      Get.toNamed('/manejos');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.monitor_weight,
                    title: 'Pesagens',
                    color: Colors.blue.shade700,
                    onTap: () {
                      Get.toNamed('/pesagens');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.vaccines,
                    title: 'Vacinações',
                    color: Colors.red.shade700,
                    onTap: () {
                      Get.toNamed('/vacinacoes');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    Widget? customIcon,
  }) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: customIcon ?? Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sair',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}