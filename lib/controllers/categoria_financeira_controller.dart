import 'package:get/get.dart';
import '../models/categoria_financeira.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

/// Controller para gestão de Categorias Financeiras (Despesas 'P' e Receitas 'R')
class CategoriaFinanceiraController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final isSaving = false.obs;

  final categorias = <CategoriaFinanceira>[].obs;
  final selectedCategoria = Rxn<CategoriaFinanceira>();

  // Filtros
  final tipoFiltro = Rxn<String>(); // null = todas, 'P' = despesas, 'R' = receitas
  final apenasAtivas = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Carrega todas as categorias conforme filtros
  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllCategoriasFinanceiras(
        tipo: tipoFiltro.value,
        apenasAtivos: apenasAtivas.value,
      );
      categorias.assignAll(lista);
    } catch (e) {
      Get.snackbar(
        'Erro ao carregar categorias',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtra lista de categorias de despesa (tipo P) ativas
  List<CategoriaFinanceira> get categoriasDespesa =>
      categorias.where((c) => c.isDespesa && c.ativo).toList();

  /// Filtra lista de categorias de receita (tipo R) ativas
  List<CategoriaFinanceira> get categoriasReceita =>
      categorias.where((c) => c.isReceita && c.ativo).toList();

  /// Retorna categorias pelo tipo ('P' ou 'R')
  List<CategoriaFinanceira> getCategoriasPorTipo(String tipo) {
    final t = tipo.toUpperCase();
    if (t == 'P' || t == 'DESPESA' || t == 'PAGAR') {
      return categoriasDespesa;
    } else {
      return categoriasReceita;
    }
  }

  /// Cadastra nova categoria
  Future<bool> create(CategoriaFinanceira categoria) async {
    try {
      isSaving.value = true;
      final created = await _apiService.createCategoriaFinanceira(categoria);
      categorias.add(created);
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Categoria "${created.nome}" cadastrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro ao cadastrar',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Atualiza categoria existente
  Future<bool> updateCategoria(int id, CategoriaFinanceira categoria) async {
    try {
      isSaving.value = true;
      final updated = await _apiService.updateCategoriaFinanceira(id, categoria);
      final idx = categorias.indexWhere((c) => c.idCategoria == id);
      if (idx >= 0) {
        categorias[idx] = updated;
      }
      selectedCategoria.value = updated;
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Categoria "${updated.nome}" atualizada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro ao atualizar',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Exclui categoria
  Future<bool> deleteCategoria(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteCategoriaFinanceira(id);
      categorias.removeWhere((c) => c.idCategoria == id);
      Get.snackbar(
        'Sucesso',
        'Categoria excluída com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Não foi possível excluir',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
