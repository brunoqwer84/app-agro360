import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/grupo_controller.dart';
import '../models/grupo.dart';
import '../utils/app_colors.dart';

/// Formulário de Grupo/Empresa (criar/editar)
class GrupoFormView extends GetView<GrupoController> {
  const GrupoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Grupo?;
    final isEdit = args != null;

    final nomeController = TextEditingController(text: args?.nome ?? '');
    final cnpjController = TextEditingController(text: args?.cnpj ?? '');
    final ativo = (args?.ativo ?? true).obs;
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Grupo' : 'Novo Grupo',
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
              // Nome do Grupo
              TextFormField(
                controller: nomeController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Nome do Grupo/Empresa*',
                  hint: 'Ex: Fazenda São João Ltda',
                  icon: Icons.business,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CNPJ (opcional)
              TextFormField(
                controller: cnpjController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'CNPJ (opcional)',
                  hint: 'Apenas números',
                  icon: Icons.badge,
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length != 14) {
                    return 'CNPJ deve ter 14 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ativo switch
              Obx(() => SwitchListTile(
                    title: const Text('Grupo ativo'),
                    subtitle: Text(
                        ativo.value ? 'Disponível para uso' : 'Desativado'),
                    value: ativo.value,
                    onChanged: (value) => ativo.value = value,
                    activeThumbColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
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
                                    final grupo = Grupo(
                                      idGrupo: isEdit ? args.idGrupo : 0,
                                      nome: nomeController.text.trim(),
                                      cnpj: cnpjController.text.trim().isEmpty ? null : cnpjController.text.trim(),
                                      ativo: ativo.value,
                                    );

                                    final ok = isEdit
                                        ? await controller.updateGrupo(args.idGrupo, grupo)
                                        : await controller.create(grupo);

                                    if (ok && !isEdit) {
                                      nomeController.clear();
                                      cnpjController.clear();
                                      ativo.value = true;
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