import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/vacinacao_controller.dart';
import '../controllers/manejo_controller.dart';
import '../models/vacinacao.dart';
import '../models/manejo.dart';
import '../utils/app_colors.dart';

/// Formulário de Vacinação (criar/editar)
class VacinacaoFormView extends GetView<VacinacaoController> {
  const VacinacaoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Vacinacao?;
    final isEdit = args != null;

    final idManejo = (args?.idManejo ?? 0).obs;
    final nome = (args?.nome ?? '').obs;
    final proximaDose = (args?.proximaDose ?? DateTime.now()).obs;
    final formKey = GlobalKey<FormState>();

    final manejoController = Get.find<ManejoController>();
    final nomeController = TextEditingController(text: args?.nome ?? '');

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        locale: const Locale('pt', 'BR'),
        initialDate: proximaDose.value,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      );
      if (picked != null) {
        proximaDose.value = picked;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Vacinação' : 'Nova Vacinação',
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
                controller: nomeController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(
                  label: 'Nome da Vacina*',
                  hint: 'Ex: Vacina Febre Aftosa',
                  icon: Icons.medication,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome da vacina é obrigatório';
                  }
                  return null;
                },
                onChanged: (v) => nome.value = v,
              ),
              const SizedBox(height: 16),

              Obx(() => InkWell(
                    onTap: selectDate,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        label: 'Próxima Dose*',
                        hint: 'Selecione a data',
                        icon: Icons.calendar_today,
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(proximaDose.value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
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
                                      final manejoSelecionado = manejoController.manejos
                                          .firstWhere((m) => m.idManejo == idManejo.value);
                                      final vacinacao = Vacinacao(
                                        idVacinacao: isEdit ? args.idVacinacao : 0,
                                        manejo: Manejo(
                                          idManejo: manejoSelecionado.idManejo,
                                          tipo: manejoSelecionado.tipo,
                                          data: manejoSelecionado.data,
                                        ),
                                        nome: nome.value.trim(),
                                        proximaDose: proximaDose.value,
                                      );
                                      if (isEdit) {
                                        await controller.updateVacinacao(
                                            args.idVacinacao, vacinacao);
                                      } else {
                                        await controller.create(vacinacao);
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