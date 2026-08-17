import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/vacinacao_controller.dart';
import '../controllers/manejo_controller.dart';
import '../utils/app_colors.dart';

/// Lista de Vacinações
class VacinacaoListView extends GetView<VacinacaoController> {
  const VacinacaoListView({super.key});

  @override
  Widget build(BuildContext context) {
    final manejoController = Get.find<ManejoController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Vacinações',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadAll(),
        child: Obx(() {
          if (controller.isLoading.value && controller.vacinacoes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (controller.vacinacoes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.vaccines,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma vacinação cadastrada',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.vacinacoes.length,
            itemBuilder: (context, index) {
              final v = controller.vacinacoes[index];
              final manejo = manejoController.manejos.firstWhereOrNull(
                (m) => m.idManejo == v.idManejo,
              );
              final isVencida = v.isVencida;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isVencida
                        ? AppColors.error
                        : AppColors.success,
                    child: Icon(
                      isVencida ? Icons.warning : Icons.vaccines,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    v.nome,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Próxima dose: ${DateFormat('dd/MM/yyyy').format(v.proximaDose)}${manejo != null ? '\nManejo: ${manejo.tipo}' : ''}',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () {
                          controller.selectForEdit(v);
                          Get.toNamed('/vacinacoes/form', arguments: v);
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
                              content: Text('Deseja excluir a vacinação "${v.nome}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.delete(v.idVacinacao);
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
                    controller.selectForEdit(v);
                    Get.toNamed('/vacinacoes/form', arguments: v);
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
          Get.toNamed('/vacinacoes/form');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}