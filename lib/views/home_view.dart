import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';

/// Tela Home
class HomeView extends GetView<AuthController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.find<SyncController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agro360'),
        backgroundColor: Colors.green.shade700,
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
              
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade700,
                            child: Text(
                              user.nomePessoa[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '@${user.nomeUsuario}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (user.isAdmin)
                            Chip(
                              label: const Text(
                                'Admin',
                                style: TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.green.shade100,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            
            // Título
            Text(
              'Menu Principal',
              style: Theme.of(context).textTheme.headlineSmall,
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
                    color: Colors.blue,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.pets,
                    title: 'Animais',
                    color: Colors.orange,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.landscape,
                    title: 'Propriedades',
                    color: Colors.green,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.medical_services,
                    title: 'Manejos',
                    color: Colors.red,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.monitor_weight,
                    title: 'Pesagens',
                    color: Colors.purple,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.vaccines,
                    title: 'Vacinações',
                    color: Colors.teal,
                    onTap: () {
                      Get.snackbar('Em desenvolvimento', 'Funcionalidade em breve');
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
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sair'),
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
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
