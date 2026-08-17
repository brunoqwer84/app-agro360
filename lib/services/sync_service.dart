import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';
import 'database_service.dart';

/// Service para sincronização assíncrona de dados
class SyncService {
  final ApiService _apiService;
  final DatabaseService _databaseService;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  Timer? _autoSyncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SyncService({
    required ApiService apiService,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _databaseService = databaseService;

  Future<void> initialize() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _onConnectivityChanged(result);
      },
    );
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final hasInternet = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    if (hasInternet && !_isSyncing) {
      syncAll();
    }
  }

  Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sincronização já em andamento');
    }

    if (!await hasConnection()) {
      return SyncResult(success: false, message: 'Sem conexão com a internet');
    }

    _isSyncing = true;

    try {
      int syncedCount = 0;
      final errors = <String>[];

      final unsyncedUsuarios = await _databaseService.getUnsyncedUsuarios();
      for (final usuario in unsyncedUsuarios) {
        try {
          usuario.synced = true;
          usuario.updatedAt = DateTime.now();
          await _databaseService.saveUsuario(usuario);
          syncedCount++;
        } catch (e) {
          errors.add('Erro ao sincronizar usuário ${usuario.idUsuario}: $e');
        }
      }

      _isSyncing = false;

      return SyncResult(
        success: errors.isEmpty,
        message: errors.isEmpty
            ? 'Sincronização concluída: $syncedCount itens'
            : 'Sincronização parcial: $syncedCount itens, ${errors.length} erros',
        syncedCount: syncedCount,
        errors: errors,
      );
    } catch (e) {
      _isSyncing = false;
      return SyncResult(success: false, message: 'Erro na sincronização: $e');
    }
  }

  Future<SyncResult> pullFromServer() async {
    if (!await hasConnection()) {
      return SyncResult(success: false, message: 'Sem conexão com a internet');
    }

    try {
      int downloadedCount = 0;
      final usuarios = await _apiService.getUsuariosAtivos();
      for (final usuario in usuarios) {
        await _databaseService.saveUsuario(usuario);
        downloadedCount++;
      }

      return SyncResult(
        success: true,
        message: 'Download concluído: $downloadedCount itens',
        syncedCount: downloadedCount,
      );
    } catch (e) {
      return SyncResult(success: false, message: 'Erro ao baixar dados: $e');
    }
  }

  void startAutoSync({Duration interval = const Duration(minutes: 15)}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (timer) async {
      if (await hasConnection()) {
        await syncAll();
      }
    });
  }

  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  bool get isSyncing => _isSyncing;

  void dispose() {
    stopAutoSync();
    _connectivitySubscription?.cancel();
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.errors = const [],
  });
}