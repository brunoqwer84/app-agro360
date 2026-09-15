import 'package:get/get.dart';
import '../models/propriedade.dart';
import '../services/api_service.dart';

/// Controller de Propriedades usando GetX
class PropriedadeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final properties = <Propriedade>[].obs;
  final selectedPropriedade = Rxn<Propriedade>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Carrega todas as propriedades (minhas propriedades - filtradas por usuário)
  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getMinhasPropriedades();
      properties.assignAll(lista);
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega apenas propriedades ativas
  Future<void> loadActive() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getPropriedadesAtivas();
      properties.assignAll(lista);
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cria nova propriedade
  Future<bool> create(Propriedade propriedade) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createPropriedade(propriedade);
      properties.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Propriedade criada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

/// Atualiza propriedade existente
  Future<bool> updatePropriedade(int id, Propriedade propriedade) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updatePropriedade(id, propriedade);
      final idx = properties.indexWhere((p) => p.idPropriedade == id);
      if (idx >= 0) properties[idx] = updated;
      selectedPropriedade.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Propriedade atualizada com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta propriedade
  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deletePropriedade(id);
      properties.removeWhere((p) => p.idPropriedade == id);
      Get.snackbar('Sucesso', 'Propriedade deletada',
            snackPosition: SnackPosition.BOTTOM);
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Prepara para edição
  void selectForEdit(Propriedade p) {
    selectedPropriedade.value = p;
  }

  void clearSelection() {
    selectedPropriedade.value = null;
  }
}