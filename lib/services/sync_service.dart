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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncService({
    required ApiService apiService,
    required DatabaseService databaseService,
  })  : _apiService = apiService,
        _databaseService = databaseService;

  /// Inicializa o serviço de sincronização
  Future<void> initialize() async {
    // Monitorar mudanças de conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _onConnectivityChanged(results);
      } as void Function(ConnectivityResult event)?,
    ) as StreamSubscription<List<ConnectivityResult>>?;
  }

  /// Callback para mudanças de conectividade
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isConnected = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    if (isConnected && !_isSyncing) {
      // Quando conectar, sincronizar automaticamente
      syncAll();
    }
  }

  /// Verifica se há conexão com a internet
Future<bool> hasConnection() async {
  final result = await _connectivity.checkConnectivity();
  return result == ConnectivityResult.mobile ||
         result == ConnectivityResult.wifi ||
         result == ConnectivityResult.ethernet;
}

  /// Sincroniza todos os dados pendentes
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sincronização já em andamento',
      );
    }

    if (!await hasConnection()) {
      return SyncResult(
        success: false,
        message: 'Sem conexão com a internet',
      );
    }

    _isSyncing = true;

    try {
      int syncedCount = 0;
      final errors = <String>[];

      // Sincronizar usuários pendentes
      final unsyncedUsuarios = await _databaseService.getUnsyncedUsuarios();
      for (final usuario in unsyncedUsuarios) {
        try {
          // Aqui você implementaria a lógica de envio para a API
          // Por exemplo: await _apiService.updateUsuario(usuario);
          
          // Marcar como sincronizado
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
      return SyncResult(
        success: false,
        message: 'Erro na sincronização: $e',
      );
    }
  }

  /// Busca dados atualizados da API e salva localmente
  Future<SyncResult> pullFromServer() async {
    if (!await hasConnection()) {
      return SyncResult(
        success: false,
        message: 'Sem conexão com a internet',
      );
    }

    try {
      int downloadedCount = 0;

      // Buscar usuários ativos da API
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
      return SyncResult(
        success: false,
        message: 'Erro ao baixar dados: $e',
      );
    }
  }

  /// Inicia sincronização automática periódica
  void startAutoSync({Duration interval = const Duration(minutes: 15)}) {
    stopAutoSync(); // Para timer anterior se existir
    
    _autoSyncTimer = Timer.periodic(interval, (timer) async {
      if (await hasConnection()) {
        await syncAll();
      }
    });
  }

  /// Para sincronização automática
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }

  /// Verifica se está sincronizando
  bool get isSyncing => _isSyncing;

  /// Libera recursos
  void dispose() {
    stopAutoSync();
    _connectivitySubscription?.cancel();
  }
}

/// Resultado de uma operação de sincronização
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
