import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/animal_controller.dart';
import '../utils/app_colors.dart';

/// Lista de Manejos
class ManejoListView extends GetView<ManejoController> {
  const ManejoListView({super.key});

  @override
  Widget build(BuildContext context) {
    final animalController = Get.find<AnimalController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Manejos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.manejos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.manejos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment,
                      size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum manejo cadastrado',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.manejos.length,
            itemBuilder: (context, index) {
              final m = controller.manejos[index];
              final animal = animalController.animais.firstWhereOrNull(
                (a) => a.idAnimal == m.idAnimal,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text(
                    m.tipo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${animal?.identificacao ?? 'Animal ${m.idAnimal}'} • ${m.data.day.toString().padLeft(2, '0')}/${m.data.month.toString().padLeft(2, '0')}/${m.data.year}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () {
                          controller.selectForEdit(m);
                          Get.toNamed('/manejos/form', arguments: m);
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
                              content: Text('Deseja excluir o manejo "${m.tipo}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.delete(m.idManejo);
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
                    controller.selectForEdit(m);
                    Get.toNamed('/manejos/form', arguments: m);
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
          Get.toNamed('/manejos/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}