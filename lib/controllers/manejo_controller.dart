import 'package:get/get.dart';
import '../models/manejo.dart';
import '../models/animal.dart';
import '../models/propriedade.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

/// Controller de Manejos usando GetX
class ManejoController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final manejos = <Manejo>[].obs;
  final selectedManejo = Rxn<Manejo>();

  // Dropdowns
  final animais = <Animal>[].obs;
  final propriedades = <Propriedade>[].obs;
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
      final propList = await _apiService.getAllPropriedades();
      propriedades.assignAll(propList);
      final animalList = await _apiService.getAllAnimais();
      animais.assignAll(animalList);
    } catch (e) {
      Get.snackbar('Aviso', 'Não foi possível carregar listas para seleção',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      carregandoDropdowns.value = false;
    }
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllManejos();
      manejos.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar manejos',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByPropriedade(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getManejosPorPropriedade(id);
      manejos.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar manejos da propriedade',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Manejo manejo) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createManejo(manejo);
      manejos.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Manejo criado com sucesso!',
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

  Future<bool> updateManejo(int id, Manejo manejo) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateManejo(id, manejo);
      final idx = manejos.indexWhere((m) => m.idManejo == id);
      if (idx >= 0) manejos[idx] = updated;
      selectedManejo.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Manejo atualizado com sucesso!',
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

  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteManejo(id);
      manejos.removeWhere((m) => m.idManejo == id);
      Get.snackbar('Sucesso', 'Manejo deletado',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Manejo m) {
    selectedManejo.value = m;
  }

  void clearSelection() {
    selectedManejo.value = null;
  }
}
