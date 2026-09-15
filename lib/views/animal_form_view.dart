import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/animal_controller.dart';
import '../models/animal.dart';
import '../models/propriedade.dart';
import '../models/raca.dart';
import '../utils/app_colors.dart';

/// Formulário de Animal (criar/editar)
class AnimalFormView extends GetView<AnimalController> {
  const AnimalFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Animal?;
    final isEdit = args != null;

    final identificacaoController = TextEditingController(text: args?.identificacao ?? '');
    final sexo = (args?.sexo ?? 'M').obs;
    final dataNascimento = (args?.dataNascimento ?? DateTime.now()).obs;
    final tipoProducao = (args?.tipoProducao ?? 'LEITE').obs;
    final status = (args?.status ?? 'ATIVO').obs;
    final idPropriedade = (args?.idPropriedade ?? 0).obs;
    final idRaca = (args?.idRaca ?? 0).obs;
    final formKey = GlobalKey<FormState>();

    Future<void> selectDate() async {
      final picked = await showDatePicker(
        context: context,
        locale: const Locale('pt', 'BR'),
        initialDate: dataNascimento.value,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        dataNascimento.value = picked;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Animal' : 'Novo Animal',
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
                controller: identificacaoController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Identificação*',
                  hint: 'Ex: 001',
                  icon: Icons.tag,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Identificação é obrigatória';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                    initialValue: sexo.value,
                    decoration: _inputDecoration(
                      label: 'Sexo*',
                      hint: 'Selecione',
                      icon: Icons.pets,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Macho')),
                      DropdownMenuItem(value: 'F', child: Text('Fêmea')),
                    ],
                    onChanged: (v) => sexo.value = v!,
                  )),
              const SizedBox(height: 16),

              Obx(() => InkWell(
                    onTap: selectDate,
                    child: InputDecorator(
                      decoration: _inputDecoration(
                        label: 'Data de Nascimento',
                        hint: 'Selecione a data',
                        icon: Icons.calendar_today,
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(dataNascimento.value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                    initialValue: tipoProducao.value,
                    decoration: _inputDecoration(
                      label: 'Tipo de Produção',
                      hint: 'Selecione',
                      icon: Icons.agriculture,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'LEITE', child: Text('Leite')),
                      DropdownMenuItem(value: 'CORTE', child: Text('Corte')),
                      DropdownMenuItem(value: 'MISTO', child: Text('Misto')),
                    ],
                    onChanged: (v) => tipoProducao.value = v!,
                  )),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<String>(
                    initialValue: status.value,
                    decoration: _inputDecoration(
                      label: 'Status',
                      hint: 'Selecione',
                      icon: Icons.check_circle,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ATIVO', child: Text('Ativo')),
                      DropdownMenuItem(value: 'VENDIDO', child: Text('Vendido')),
                      DropdownMenuItem(value: 'MORTO', child: Text('Morto')),
                    ],
                    onChanged: (v) => status.value = v!,
                  )),
              const SizedBox(height: 16),

              Obx(() => DropdownButtonFormField<int>(
                    initialValue: idPropriedade.value > 0 ? idPropriedade.value : null,
                    decoration: _inputDecoration(
                      label: 'Propriedade*',
                      hint: controller.carregandoDropdowns.value ? 'Carregando...' : 'Selecione',
                      icon: Icons.landscape,
                    ),
                    items: controller.propriedades
                        .map((p) => DropdownMenuItem(
                              value: p.idPropriedade,
                              child: Text(p.nome),
                            ))
                        .toList(),
                    onChanged: controller.propriedades.isEmpty
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

              Obx(() => DropdownButtonFormField<int>(
                      initialValue: idRaca.value > 0 ? idRaca.value : null,
                    decoration: _inputDecoration(
                      label: 'Raça*',
                      hint: controller.carregandoDropdowns.value ? 'Carregando...' : 'Selecione',
                      icon: Icons.pets,
                    ),
                    items: controller.racas
                        .map((r) => DropdownMenuItem(
                              value: r.idRaca,
                              child: Text(r.descricao),
                            ))
                        .toList(),
                    onChanged: controller.racas.isEmpty
                        ? null
                        : (v) => idRaca.value = v!,
                    validator: (value) {
                      if (value == null || value <= 0) {
                        return 'Raça é obrigatória';
                      }
                      return null;
                    },
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
                                      final propriedadeSelecionada = controller.propriedades
                                          .firstWhere((p) => p.idPropriedade == idPropriedade.value);
                                      final racaSelecionada = controller.racas
                                          .firstWhere((r) => r.idRaca == idRaca.value);
                                      final animal = Animal(
                                        idAnimal: isEdit ? args.idAnimal : 0,
                                        identificacao: identificacaoController.text.trim(),
                                        sexo: sexo.value,
                                        dataNascimento: dataNascimento.value,
                                        tipoProducao: tipoProducao.value,
                                        status: status.value,
                                        propriedade: Propriedade(
                                          idPropriedade: propriedadeSelecionada.idPropriedade,
                                          nome: propriedadeSelecionada.nome,
                                          ativo: propriedadeSelecionada.ativo,
                                        ),
                                        raca: Raca(
                                          idRaca: racaSelecionada.idRaca,
                                          descricao: racaSelecionada.descricao,
                                        ),
                                      );
                                      if (isEdit) {
                                        await controller.updateAnimal(
                                            args.idAnimal, animal);
                                      } else {
                                        await controller.create(animal);
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