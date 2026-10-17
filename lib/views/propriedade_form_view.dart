import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/propriedade_controller.dart';
import '../models/propriedade.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Editar Propriedade' : 'Nova Propriedade',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Card do formulário
                AppCard(
                  padding: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              isEdit ? Icons.edit_outlined : Icons.add_outlined,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEdit
                                      ? 'Editar Propriedade'
                                      : 'Nova Propriedade',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  isEdit
                                      ? 'Atualize as informações da propriedade'
                                      : 'Preencha os dados para cadastrar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Nome da Propriedade
                      AppInput(
                        label: 'Nome da Propriedade *',
                        hint: 'Ex: Fazenda Santa Clara',
                        controller: nomeController,
                        icon: Icons.landscape,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
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
                      const SizedBox(height: AppSpacing.md),

                      // Ativo switch
                      Obx(() => SwitchListTile(
                            title: const Text('Propriedade ativa'),
                            subtitle: Text(
                              ativo.value
                                  ? 'Disponível para uso'
                                  : 'Desativada',
                            ),
                            value: ativo.value,
                            onChanged: (value) => ativo.value = value,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primaryContainer,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          )),
                      const SizedBox(height: AppSpacing.xl),

                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: AppButton.outline(
                              label: 'Cancelar',
                              onPressed: () => Get.back(),
                              size: AppButtonSize.large,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Obx(() => AppButton.primary(
                                  label: isEdit ? 'Atualizar' : 'Criar',
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            final propriedade = Propriedade(
                                              idPropriedade: isEdit
                                                  ? args.idPropriedade
                                                  : 0,
                                              nome: nomeController.text.trim(),
                                              ativo: ativo.value,
                                            );

                                            final ok = isEdit
                                                ? await controller
                                                    .updatePropriedade(
                                                        args.idPropriedade,
                                                        propriedade)
                                                : await controller
                                                    .create(propriedade);

                                            if (ok && !isEdit) {
                                              nomeController.clear();
                                              ativo.value = true;
                                            }
                                          }
                                        },
                                  isLoading: controller.isLoading.value,
                                  size: AppButtonSize.large,
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
}
}
