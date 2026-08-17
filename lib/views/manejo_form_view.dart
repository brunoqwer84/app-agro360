import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/animal_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../models/manejo.dart';
import '../utils/app_colors.dart';

/// Formulário de Manejo (criar/editar)
class ManejoFormView extends GetView<ManejoController> {
  const ManejoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Manejo?;
    final isEdit = args != null;

    final idAnimal = (args?.idAnimal ?? 0).obs;
    final idPropriedade = (args?.idPropriedade ?? 0).obs;
    final tipo = (args?.tipo ?? 'PESAGEM').obs;
    final data = (args?.data ?? DateTime.now()).obs;
    final observacao = (args?.observacao ?? '').obs;
    final formKey = GlobalKey<FormState>();

    final animalController = Get.find<AnimalController>();
    final propriedadeController = Get.find<PropriedadeController>();

    Future<void> _selectDate() async {
      final picked = await showDatePicker(
        context: context,
        locale: const Locale('pt', 'BR'),
        initialDate: data.value,
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      );
      if (picked != null) {
        data.value = picked;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Manejo' : 'Novo Manejo',
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
                    value: idAnimal.value > 0 ? idAnimal.value : null,
                    decoration: _inputDecoration(
                      label: 'Animal*',
                      hint: 'Selecione',
                      icon: Icons.pets,
                    ),
                    items: animalController.animais
                        .map((a) => DropdownMenuItem(
                              value: a.idAnimal,
                              child: Text(a.identificacao),
                            ))
                        .toList(),
                    onChanged: animalController.animais.isEmpty
                        ? null
                        : (v) => idAnimal.value = v!,
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return 'Animal é obrigatório';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<int>(
                    value: idPropriedade.value > 0 ? idPropriedade.value : null,
                    decoration: _inputDecoration(
                      label: 'Propriedade*',
                      hint: 'Selecione',
                      icon: Icons.landscape,
                    ),
                    items: propriedadeController.properties
                        .map((p) => DropdownMenuItem(
                              value: p.idPropriedade,
                              child: Text(p.nome),
                            ))
                        .toList(),
                    onChanged: propriedadeController.properties.isEmpty
                        ? null
                        : (v) => idPropriedade.value = v!,
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return 'Propriedade é obrigatória';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                    value: tipo.value,
                    decoration: _inputDecoration(
                      label: 'Tipo*',
                      hint: 'Selecione',
                      icon: Icons.category,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PESAGEM', child: Text('Pesagem')),
                      DropdownMenuItem(value: 'VACINACAO', child: Text('Vacinação')),
                      DropdownMenuItem(value: 'INSEMINACAO', child: Text('Inseminação')),
                      DropdownMenuItem(value: 'TRATAMENTO', child: Text('Tratamento')),
                    ],
                    onChanged: (v) => tipo.value = v!,
                  )),
              const SizedBox(height: 16),

              Obx(() => InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        label: 'Data*',
                        hint: 'Selecione a data',
                        icon: Icons.calendar_today,
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(data.value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: isEdit ? args.observacao : '',
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Descrição',
                  hint: 'Detalhes do manejo...',
                  icon: Icons.description,
                ),
                onChanged: (v) => observacao.value = v,
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
                                    final manejo = Manejo(
                                      idManejo: isEdit ? args.idManejo : 0,
                                      idAnimal: idAnimal.value,
                                      idPropriedade: idPropriedade.value,
                                      tipo: tipo.value,
                                      data: data.value,
                                      observacao: observacao.value.isEmpty
                                          ? null
                                          : observacao.value,
                                    );
                                    if (isEdit) {
                                      await controller.updateManejo(
                                          args.idManejo, manejo);
                                    } else {
                                      await controller.create(manejo);
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