import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/raca_controller.dart';
import '../models/raca.dart';
import '../utils/app_colors.dart';

class RacaFormView extends GetView<RacaController> {
  const RacaFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Raca?;
    final isEdit = args != null;

    final descricaoController = TextEditingController(text: args?.descricao ?? '');
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Raça' : 'Nova Raça',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: descricaoController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Descrição da Raça*',
                  hint: 'Ex: Nelore, Gir, Holandês',
                  icon: Icons.pets,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    final raca = Raca(
                                      idRaca: isEdit ? args.idRaca : 0,
                                      descricao: descricaoController.text.trim(),
                                    );
                                    final ok = isEdit
                                        ? await controller.updateRaca(
                                            args.idRaca, raca)
                                        : await controller.create(raca);

                                    if (ok && !isEdit) {
                                      descricaoController.clear();
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Salvando...'),
                                  ],
                                )
                              : Text(
                                  isEdit ? 'Atualizar' : 'Criar',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
    );
  }
}