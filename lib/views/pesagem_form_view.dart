import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pesagem_controller.dart';
import '../controllers/manejo_controller.dart';
import '../models/pesagem.dart';
import '../models/manejo.dart';
import '../utils/app_colors.dart';

/// Formulário de Pesagem (criar/editar)
class PesagemFormView extends GetView<PesagemController> {
  const PesagemFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Pesagem?;
    final isEdit = args != null;

    final idManejo = (args?.idManejo ?? 0).obs;
    final pesoKg = (args?.pesoKg ?? 0.0).obs;
    final formKey = GlobalKey<FormState>();

    final manejoController = Get.find<ManejoController>();
    final pesoController = TextEditingController(
      text: isEdit ? args.pesoKg.toString() : '',
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Pesagem' : 'Nova Pesagem',
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
              Obx(() => DropdownButtonFormField<int>(
                    initialValue: idManejo.value > 0 ? idManejo.value : null,
                    decoration: _inputDecoration(
                      label: 'Manejo*',
                      hint: 'Selecione',
                      icon: Icons.assignment,
                    ),
                    items: manejoController.manejos
                        .map((m) => DropdownMenuItem(
                              value: m.idManejo,
                              child: Text(m.tipo),
                            ))
                        .toList(),
                    onChanged: manejoController.manejos.isEmpty
                        ? null
                        : (v) => idManejo.value = v!,
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return 'Manejo é obrigatório';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),

              TextFormField(
                controller: pesoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                  label: 'Peso (kg)*',
                  hint: 'Ex: 450.5',
                  icon: Icons.monitor_weight,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Peso é obrigatório';
                  }
                  final peso = double.tryParse(value.replaceAll(',', '.'));
                  if (peso == null || peso <= 0) {
                    return 'Peso inválido';
                  }
                  return null;
                },
                onChanged: (v) {
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed != null) pesoKg.value = parsed;
                },
              ),
              const SizedBox(height: 16),

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
                                      final manejoSelecionado = manejoController.manejos
                                          .firstWhere((m) => m.idManejo == idManejo.value);
                                      final pesagem = Pesagem(
                                        idPesagem: isEdit ? args.idPesagem : 0,
                                        manejo: Manejo(
                                          idManejo: manejoSelecionado.idManejo,
                                          tipo: manejoSelecionado.tipo,
                                          data: manejoSelecionado.data,
                                        ),
                                        pesoKg: pesoKg.value,
                                      );
                                      if (isEdit) {
                                        await controller.updatePesagem(
                                            args.idPesagem, pesagem);
                                      } else {
                                        await controller.create(pesagem);
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
                        child: const Text(
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