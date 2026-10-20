import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/categoria_financeira_controller.dart';
import '../models/categoria_financeira.dart';
import '../utils/app_colors.dart';
import '../widgets/app_components.dart';
import '../theme/app_theme.dart';

/// Formulário para criar ou editar uma Categoria Financeira
class CategoriaFinanceiraFormView extends StatefulWidget {
  const CategoriaFinanceiraFormView({super.key});

  @override
  State<CategoriaFinanceiraFormView> createState() =>
      _CategoriaFinanceiraFormViewState();
}

class _CategoriaFinanceiraFormViewState
    extends State<CategoriaFinanceiraFormView> {
  final _formKey = GlobalKey<FormState>();
  late final CategoriaFinanceira? _categoria;
  late final CategoriaFinanceiraController _controller;

  late String _tipo; // 'P' ou 'R'
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late bool _ativo;

  bool get _isEdit => _categoria != null;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CategoriaFinanceiraController>()
        ? Get.find<CategoriaFinanceiraController>()
        : Get.put<CategoriaFinanceiraController>(
            CategoriaFinanceiraController());

    _categoria = Get.arguments as CategoriaFinanceira?;

    _tipo = _categoria?.tipo.toUpperCase() ?? 'P';
    if (_tipo != 'P' && _tipo != 'R') _tipo = 'P';

    _nomeController = TextEditingController(text: _categoria?.nome ?? '');
    _descricaoController =
        TextEditingController(text: _categoria?.descricao ?? '');
    _ativo = _categoria?.ativo ?? true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final novaCategoria = CategoriaFinanceira(
      idCategoria: _isEdit ? _categoria!.idCategoria : 0,
      nome: _nomeController.text.trim(),
      tipo: _tipo,
      descricao: _descricaoController.text.trim().isEmpty
          ? null
          : _descricaoController.text.trim(),
      ativo: _ativo,
    );

    if (_isEdit) {
      await _controller.updateCategoria(_categoria!.idCategoria, novaCategoria);
    } else {
      await _controller.create(novaCategoria);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Categoria' : 'Nova Categoria'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Seletor Tipo: Despesa ('P') vs Receita ('R')
                _buildTipoSelector(),
                const SizedBox(height: AppSpacing.lg),

                // Nome da Categoria
                AppInput(
                  label: 'Nome da Categoria *',
                  hint: _tipo == 'P'
                      ? 'Ex: Ração, Vacinas, Manutenção...'
                      : 'Ex: Venda de Bezerros, Leite, Grãos...',
                  controller: _nomeController,
                  icon: Icons.label_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe o nome da categoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Descrição
                AppInput(
                  label: 'Descrição / Finalidade (Opcional)',
                  hint: 'Breve explicação sobre os gastos ou entradas desta categoria',
                  controller: _descricaoController,
                  icon: Icons.notes_rounded,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),

                // Status Ativo
                AppCard(
                  padding: AppSpacing.sm,
                  child: SwitchListTile(
                    title: const Text(
                      'Categoria Ativa',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Categorias ativas aparecem disponíveis para novos lançamentos',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    value: _ativo,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryContainer,
                    onChanged: (val) => setState(() => _ativo = val),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Botão Salvar
                Obx(() => AppButton.primary(
                      label: _isEdit ? 'Atualizar Categoria' : 'Salvar Categoria',
                      icon: const Icon(Icons.check_rounded, color: Colors.white),
                      isLoading: _controller.isSaving.value,
                      onPressed: _controller.isSaving.value ? null : _salvar,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipoSelector() {
    final isDespesa = _tipo == 'P';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tipo = 'P'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDespesa ? AppColors.error : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: isDespesa
                      ? [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: isDespesa ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Despesa (Tipo P)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDespesa ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tipo = 'R'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isDespesa ? AppColors.success : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: !isDespesa
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: !isDespesa ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Receita (Tipo R)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: !isDespesa ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
