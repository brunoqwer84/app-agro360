import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/sync_service.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

/// Controller de sincronização usando GetX
class SyncController extends GetxController {
  late final SyncService _syncService;

  // Estados observáveis
  final isSyncing = false.obs;
  final isConnected = false.obs;
  final lastSyncTime = Rx<DateTime?>(null);
  final syncMessage = ''.obs;
  final syncProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSyncService();
  }

  /// Inicializa o serviço de sincronização
  Future<void> _initializeSyncService() async {
    final apiService = Get.find<ApiService>();
    final databaseService = Get.find<DatabaseService>();

    _syncService = SyncService(
      apiService: apiService,
      databaseService: databaseService,
    );

    await _syncService.initialize();

    // Verificar conectividade inicial
    await checkConnectivity();

    // Iniciar sincronização automática
    _syncService.startAutoSync();
  }

  /// Verifica conectividade com a API
  Future<void> checkConnectivity() async {
    try {
      final connected = await _syncService.hasConnection();
      isConnected.value = connected;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade: $e');
      isConnected.value = false;
    }
  }

  /// Verifica apenas conectividade de rede (sem validar API)
  Future<void> checkNetworkConnectivity() async {
    try {
      final connected = await _syncService.checkNetworkConnectivity();
      isConnected.value = connected;
    } catch (e) {
      debugPrint('Erro ao verificar conectividade de rede: $e');
      isConnected.value = false;
    }
  }

  /// Sincroniza todos os dados
  Future<void> syncAll() async {
    // Evita sincronização duplicada (ex.: gatilho pós-login + evento de
    // conectividade): se já está sincronizando, ignora silenciosamente.
    if (isSyncing.value) return;
    isSyncing.value = true;

    try {
      syncMessage.value = 'Sincronizando...';
      syncProgress.value = 0.0;

      final result = await _syncService.syncAll();

      syncMessage.value = result.message;
      lastSyncTime.value = DateTime.now();

      if (result.success) {
        syncProgress.value = 1.0;
        Get.snackbar(
          'Sincronização',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Erro',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      syncMessage.value = 'Erro: $e';
      Get.snackbar(
        'Erro',
        'Erro ao sincronizar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
      // Verificar conectividade após sincronização
      await checkConnectivity();
    }
  }

  /// Baixa dados do servidor
  Future<void> pullFromServer() async {
    try {
      isSyncing.value = true;
      syncMessage.value = 'Baixando dados...';
      syncProgress.value = 0.0;

      final result = await _syncService.pullFromServer();

      syncMessage.value = result.message;
      lastSyncTime.value = DateTime.now();

      if (result.success) {
        syncProgress.value = 1.0;
        Get.snackbar(
          'Download',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Erro',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      syncMessage.value = 'Erro: $e';
      Get.snackbar(
        'Erro',
        'Erro ao baixar dados: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSyncing.value = false;
      // Verificar conectividade após download
      await checkConnectivity();
    }
  }

  @override
  void onClose() {
    _syncService.dispose();
    super.onClose();
  }
}
