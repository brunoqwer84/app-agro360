import 'package:get/get.dart';
import '../models/pessoa.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

/// Controller de Pessoas (membros da equipe, produtores, contatos) usando GetX
class PessoaController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final pessoas = <Pessoa>[].obs;
  final selectedPessoa = Rxn<Pessoa>();
  final filtroTipo = 'TODOS'.obs; // 'TODOS', 'C', 'F'

  /// Clientes (tipo C ou A)
  List<Pessoa> get clientes => pessoas.where((p) => p.isCliente).toList();

  /// Fornecedores (tipo F ou A)
  List<Pessoa> get fornecedores => pessoas.where((p) => p.isFornecedor).toList();

  /// Altera o filtro de tipo
  void setFiltroTipo(String tipo) {
    filtroTipo.value = tipo;
  }

  /// Lista aplicando o filtro de tipo
  List<Pessoa> get pessoasFiltradas {
    if (filtroTipo.value == 'C') {
      return clientes;
    } else if (filtroTipo.value == 'F') {
      return fornecedores;
    }
    return pessoas;
  }

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Carrega todas as pessoas do grupo
  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllPessoas();
      pessoas.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega apenas pessoas ativas
  Future<void> loadActive() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getPessoasAtivas();
      pessoas.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Busca pessoas por nome
  Future<void> search(String nome) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.searchPessoas(nome);
      pessoas.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cadastra nova pessoa
  Future<bool> create(Pessoa pessoa) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createPessoa(pessoa);
      pessoas.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Pessoa cadastrada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Atualiza pessoa existente
  Future<bool> updatePessoa(int id, Pessoa pessoa) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updatePessoa(id, pessoa);
      final idx = pessoas.indexWhere((p) => p.idPessoa == id);
      if (idx >= 0) pessoas[idx] = updated;
      selectedPessoa.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Pessoa atualizada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta pessoa
  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deletePessoa(id);
      pessoas.removeWhere((p) => p.idPessoa == id);
      Get.snackbar('Sucesso', 'Pessoa excluída com sucesso',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Prepara para edição
  void selectForEdit(Pessoa p) {
    selectedPessoa.value = p;
  }

  /// Limpa seleção
  void clearSelection() {
    selectedPessoa.value = null;
  }
}
