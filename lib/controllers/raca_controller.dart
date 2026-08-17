import 'package:get/get.dart';
import '../models/raca.dart';
import '../services/api_service.dart';

/// Controller de Raças usando GetX
class RacaController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final racas = <Raca>[].obs;
  final selectedRaca = Rxn<Raca>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllRacas();
      racas.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar raças',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> search(String descricao) async {
    if (descricao.isEmpty) {
      await loadAll();
      return;
    }
    try {
      isLoading.value = true;
      final lista = await _apiService.searchRacas(descricao);
      racas.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível buscar raças',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Raca raca) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createRaca(raca);
      racas.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Raça criada com sucesso!',
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

  Future<bool> updateRaca(int id, Raca raca) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateRaca(id, raca);
      final idx = racas.indexWhere((r) => r.idRaca == id);
      if (idx >= 0) racas[idx] = updated;
      selectedRaca.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Raça atualizada com sucesso!',
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
      await _apiService.deleteRaca(id);
      racas.removeWhere((r) => r.idRaca == id);
      Get.snackbar('Sucesso', 'Raça deletada',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Raca r) {
    selectedRaca.value = r;
  }

  void clearSelection() {
    selectedRaca.value = null;
  }
}