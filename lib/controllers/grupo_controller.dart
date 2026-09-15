import 'package:get/get.dart';
import '../models/grupo.dart';
import '../services/api_service.dart';

/// Controller de Grupos/Empresas usando GetX
class GrupoController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final groups = <Grupo>[].obs;
  final selectedGrupo = Rxn<Grupo>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Carrega todos os grupos
  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllGrupos();
      groups.assignAll(lista);
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega apenas grupos ativos
  Future<void> loadActive() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getGruposAtivos();
      groups.assignAll(lista);
    } on String catch (e) {
      Get.snackbar('Erro', e, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Cria novo grupo
  Future<bool> create(Grupo grupo) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createGrupo(grupo);
      groups.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Grupo criado com sucesso!',
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

  /// Atualiza grupo existente
  Future<bool> updateGrupo(int id, Grupo grupo) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateGrupo(id, grupo);
      final idx = groups.indexWhere((g) => g.idGrupo == id);
      if (idx >= 0) groups[idx] = updated;
      selectedGrupo.value = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Grupo atualizado com sucesso!',
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

  /// Deleta grupo
  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteGrupo(id);
      groups.removeWhere((g) => g.idGrupo == id);
      Get.snackbar('Sucesso', 'Grupo deletado',
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
  void selectForEdit(Grupo g) {
    selectedGrupo.value = g;
  }

  void clearSelection() {
    selectedGrupo.value = null;
  }
}