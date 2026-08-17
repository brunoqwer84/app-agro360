import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/propriedade.dart';
import '../utils/app_colors.dart';

/// Formulário de Propriedade (criar/editar)
class PropriedadeFormView extends GetView<PropriedadeController> {
  const PropriedadeFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Propriedade?;
    final isEdit = args != null;

    final nomeController = TextEditingController(text: args?.nome ?? '');
    final ativo = (args?.ativo ?? true).obs;
    final formKey = GlobalKey<FormState>();

    final authController = Get.find<AuthController>();
    final usuarioLogado = authController.currentUser.value;

    final idPessoa = usuarioLogado?.idPessoa ?? 0;
    final nomePessoa = usuarioLogado?.nomePessoa ?? 'Carregando...';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Propriedade' : 'Nova Propriedade',
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
              // Nome da Propriedade
              TextFormField(
                controller: nomeController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Nome da Propriedade*',
                  hint: 'Ex: Fazenda Santa Clara',
                  icon: Icons.landscape,
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

              // Proprietário (automático)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proprietário',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nomePessoa,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isEdit)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ID: $idPessoa',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ativo switch
              Obx(() => SwitchListTile(
                    title: const Text('Propriedade ativa'),
                    subtitle: Text(
                        ativo.value ? 'Disponível para uso' : 'Desativada'),
                    value: ativo.value,
                    onChanged: (value) => ativo.value = value,
                    activeThumbColor: AppColors.primary,
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
                                    final propriedade = Propriedade(
                                      idPropriedade: isEdit ? args.idPropriedade : 0,
                                      nome: nomeController.text.trim(),
                                      ativo: ativo.value,
                                      idPessoa: idPessoa,
                                    );

                                    final ok = isEdit
                                        ? await controller.updatePropriedade(
                                            args.idPropriedade, propriedade)
                                        : await controller.create(propriedade);

                                    if (ok && !isEdit) {
                                      nomeController.clear();
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