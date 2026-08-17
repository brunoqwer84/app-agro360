import 'package:get/get.dart';
import '../models/animal.dart';
import '../models/propriedade.dart';
import '../models/raca.dart';
import '../services/api_service.dart';

/// Controller de Animais usando GetX
class AnimalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final animais = <Animal>[].obs;

  // Dropdowns
  final propriedades = <Propriedade>[].obs;
  final racas = <Raca>[].obs;
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
      final racaList = await _apiService.getAllRacas();
      racas.assignAll(racaList);
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
      final lista = await _apiService.getAllAnimais();
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAtivos() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorStatus('ATIVO');
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais ativos',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByPropriedade(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorPropriedade(id);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais da propriedade',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByRaca(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorRaca(id);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais da raça',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByStatus(String status) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorStatus(status);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais por status',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> create(Animal animal) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createAnimal(animal);
      animais.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Animal criado com sucesso!',
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

  Future<bool> updateAnimal(int id, Animal animal) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateAnimal(id, animal);
      final idx = animais.indexWhere((a) => a.idAnimal == id);
      if (idx >= 0) animais[idx] = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Animal atualizado com sucesso!',
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
      await _apiService.deleteAnimal(id);
      animais.removeWhere((a) => a.idAnimal == id);
      Get.snackbar('Sucesso', 'Animal deletado',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Animal a) {
    selectedAnimal.value = a;
  }

  void clearSelection() {
    selectedAnimal.value = null;
  }

  final selectedAnimal = Rxn<Animal>();
}