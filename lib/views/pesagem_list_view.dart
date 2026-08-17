import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pesagem_controller.dart';
import '../controllers/manejo_controller.dart';
import '../utils/app_colors.dart';

/// Lista de Pesagens
class PesagemListView extends GetView<PesagemController> {
  const PesagemListView({super.key});

  @override
  Widget build(BuildContext context) {
    final manejoController = Get.find<ManejoController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Pesagens',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.pesagens.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.pesagens.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monitor_weight,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma pesagem cadastrada',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pesagens.length,
            itemBuilder: (context, index) {
              final p = controller.pesagens[index];
              final manejo = manejoController.manejos.firstWhereOrNull(
                (m) => m.idManejo == p.idManejo,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.info,
                    child: Icon(Icons.monitor_weight, color: Colors.white),
                  ),
                  title: Text(
                    '${p.pesoKg} kg',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Manejo ${p.idManejo}${manejo != null ? ' - ${manejo.tipo}' : ''}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () {
                          controller.selectForEdit(p);
                          Get.toNamed('/pesagens/form', arguments: p);
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
                              content: Text('Deseja excluir a pesagem de ${p.pesoKg} kg?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.delete(p.idPesagem);
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
                    Get.toNamed('/pesagens/form', arguments: p);
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
          Get.toNamed('/pesagens/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}