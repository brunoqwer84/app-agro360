import 'package:get/get.dart';
import '../models/pesagem.dart';
import '../models/manejo.dart';
import '../services/api_service.dart';

/// Controller de Pesagens usando GetX
class PesagemController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final pesagens = <Pesagem>[].obs;
  final selectedPesagem = Rxn<Pesagem>();

  // Dropdown
  final manejos = <Manejo>[].obs;
  final carregandoDropdowns = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    loadDropdowns();
  }

  Future<void> loadDropdowns() async {
    try {
      carregandoDropdowns.value = true;
      final lista = await _apiService.getAllManejos();
      manejos.assignAll(lista);
    } catch (e) {
      Get.snackbar('Aviso', 'Não foi possível carregar manejos',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      carregandoDropdowns.value = false;
    }
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllPesagens();
      pesagens.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar pesagens',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByManejo(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getPesagensPorManejo(id);
      pesagens.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar pesagens do manejo',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Pesagem pesagem) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createPesagem(pesagem);
      pesagens.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Pesagem criada com sucesso!',
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

  Future<bool> updatePesagem(int id, Pesagem pesagem) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updatePesagem(id, pesagem);
      final idx = pesagens.indexWhere((p) => p.idPesagem == id);
      if (idx >= 0) pesagens[idx] = updated;
      selectedPesagem.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Pesagem atualizada com sucesso!',
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
      await _apiService.deletePesagem(id);
      pesagens.removeWhere((p) => p.idPesagem == id);
      Get.snackbar('Sucesso', 'Pesagem deletada',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Pesagem p) {
    selectedPesagem.value = p;
  }

  void clearSelection() {
    selectedPesagem.value = null;
  }
}