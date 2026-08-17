import 'package:get/get.dart';
import '../models/vacinacao.dart';
import '../services/api_service.dart';

/// Controller de Vacinações usando GetX
class VacinacaoController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final vacinacoes = <Vacinacao>[].obs;
  final selectedVacinacao = Rxn<Vacinacao>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllVacinacoes();
      vacinacoes.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar vacinações',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByManejo(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getVacinacoesPorManejo(id);
      vacinacoes.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar vacinações do manejo',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Vacinacao vacinacao) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createVacinacao(vacinacao);
      vacinacoes.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Vacinação criada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateVacinacao(int id, Vacinacao vacinacao) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateVacinacao(id, vacinacao);
      final idx = vacinacoes.indexWhere((v) => v.idVacinacao == id);
      if (idx >= 0) vacinacoes[idx] = updated;
      selectedVacinacao.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Vacinação atualizada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteVacinacao(id);
      vacinacoes.removeWhere((v) => v.idVacinacao == id);
      Get.snackbar('Sucesso', 'Vacinação deletada',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Vacinacao v) {
    selectedVacinacao.value = v;
  }

  void clearSelection() {
    selectedVacinacao.value = null;
  }
}