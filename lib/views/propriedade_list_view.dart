import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/propriedade_controller.dart';
import '../utils/app_colors.dart';

/// Lista de Propriedades
class PropriedadeListView extends GetView<PropriedadeController> {
  const PropriedadeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Propriedades',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.properties.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.properties.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.landscape,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma propriedade cadastrada',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.properties.length,
            itemBuilder: (context, index) {
              final p = controller.properties[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.landscape, color: Colors.white),
                  ),
                  title: Text(
                    p.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'ID: ${p.idPropriedade} • ${p.ativo ? 'Ativa' : 'Inativa'}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () {
                          controller.selectForEdit(p);
                          Get.toNamed('/propriedades/form', arguments: p);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () async {
                          await Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Confirmar exclusão'),
                              content: Text('Deseja excluir "${p.nome}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.delete(p.idPropriedade);
                                  },
                                  child: const Text('Excluir',
                                      style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    controller.selectForEdit(p);
                    Get.toNamed('/propriedades/form', arguments: p);
                  },
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearSelection();
          Get.toNamed('/propriedades/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}