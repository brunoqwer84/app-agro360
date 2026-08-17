import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/raca_controller.dart';
import '../utils/app_colors.dart';

/// Lista de Animais
class AnimalListView extends GetView<AnimalController> {
  const AnimalListView({super.key});

  @override
  Widget build(BuildContext context) {
    final propriedadeController = Get.find<PropriedadeController>();
    final racaController = Get.find<RacaController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Animais',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.animais.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.animais.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum animal cadastrado',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.animais.length,
            itemBuilder: (context, index) {
              final a = controller.animais[index];
              final prop = propriedadeController.properties.firstWhereOrNull(
                (p) => p.idPropriedade == a.idPropriedade,
              );
              final raca = racaController.racas.firstWhereOrNull(
                (r) => r.idRaca == a.idRaca,
              );
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.pets, color: Colors.white),
                  ),
                  title: Text(
                    a.identificacao,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${prop?.nome ?? 'Propriedade $a.idPropriedade'} • ${raca?.descricao ?? 'Raça $a.idRaca'}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () {
                          controller.selectForEdit(a);
                          Get.toNamed('/animais/form', arguments: a);
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
                              content: Text('Deseja excluir "${a.identificacao}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.delete(a.idAnimal);
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
                    controller.selectForEdit(a);
                    Get.toNamed('/animais/form', arguments: a);
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
          Get.toNamed('/animais/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}