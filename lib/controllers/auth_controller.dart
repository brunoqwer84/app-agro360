import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/first_access_request.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../controllers/sync_controller.dart';
import '../routes/app_routes.dart';
import '../utils/error_messages.dart';

/// Controller de autenticação usando GetX
class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Estados observáveis
  final isLoading = false.obs;
  final isAuthenticated = false.obs;
  final Rx<Usuario?> currentUser = Rx<Usuario?>(null);
  final errorMessage = ''.obs;
  final isSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    _apiService.setOnTokenExpired(_onTokenExpired);
    checkAuthStatus();
  }

  void _onTokenExpired() {
    // Token expirou - fazer logout e redirecionar para login
    logout();
  }

  /// Verifica se o usuário já está autenticado
  Future<void> checkAuthStatus() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString(AppConfig.usernameKey);
      final userId = prefs.getInt(AppConfig.userIdKey);

      if (username != null && userId != null && _apiService.hasToken) {
        // Tentar validar o token
        try {
          await _apiService.validateToken();

          // Token válido, carregar dados do usuário
          await loadUserData(username);
          isAuthenticated.value = true;

          // Trigger sync after auto-login
          _triggerPostLoginSync();
        } catch (e) {
          // Token inválido, fazer logout
          await logout();
        }
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      debugPrint('Erro ao verificar status de autenticação: $e');
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza login
  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validar campos
      if (username.isEmpty || password.isEmpty) {
        errorMessage.value = 'Preencha todos os campos';
        return false;
      }

      // Criar requisição de login
      final request = LoginRequest(
        nomeUsuario: username,
        senha: password,
      );

      // Fazer login na API
      await _apiService.login(request);

      // Salvar informações do usuário
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.usernameKey, username);

      // Carregar dados do usuário
      await loadUserData(username);

      // Salvar ID do usuário
      if (currentUser.value != null) {
        await prefs.setInt(AppConfig.userIdKey, currentUser.value!.idUsuario);
      } else {
        // Fallback seguro se busca na API falhar
        currentUser.value = Usuario(
          idUsuario: 0,
          nomeUsuario: username,
          ativo: true,
          roles: const ['ROLE_USER'],
          idPessoa: 0,
          nomePessoa: username,
        );
      }

      isAuthenticated.value = true;
      isLoading.value = false;

      // Navegar para home
      Get.offAllNamed(AppRoutes.home);

      // Trigger sync after login
      _triggerPostLoginSync();

      return true;
    } catch (e) {
      errorMessage.value = AppError.getErrorMessage(e);
      isAuthenticated.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega dados do usuário
  Future<void> loadUserData(String username) async {
    try {
      // Tentar carregar da API
      final usuario = await _apiService.getUsuarioByUsername(username);
      currentUser.value = usuario;

      // Cache local é best-effort: uma falha ao salvar NÃO deve substituir
      // os dados válidos obtidos da API (evita exibir usuário desatualizado).
      try {
        await _databaseService.saveUsuario(usuario);
      } catch (e) {
        debugPrint('Falha ao salvar usuário no cache local: $e');
      }
    } catch (e) {
      // API indisponível: tentar carregar do banco local
      final usuarios = await _databaseService.getAllUsuarios();
      final usuario = usuarios.firstWhereOrNull(
        (u) => u.nomeUsuario == username,
      );
      currentUser.value = usuario;
    }
  }

  /// Realiza o primeiro acesso (cadastro de Pessoa + Usuário)
  /// Retorna true em caso de sucesso.
  Future<bool> register(FirstAccessRequest request) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      isSuccess.value = false;

      final response = await _apiService.firstAccess(request);

      if (response.sucesso) {
        isSuccess.value = true;
        return true;
      } else {
        errorMessage.value = response.mensagem;
        return false;
      }
    } catch (e) {
      errorMessage.value = AppError.getErrorMessage(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Limpar token
      await _apiService.clearToken();

      // Limpar dados do usuário
      currentUser.value = null;
      isAuthenticated.value = false;

      // Navegar para login
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    errorMessage.value = '';
  }

  /// Trigger sync after login (fire and forget)
  void _triggerPostLoginSync() {
    // Use a small delay to allow home view to initialize
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final syncController = Get.find<SyncController>();
        syncController.syncAll();
      } catch (e) {
        debugPrint('Erro ao iniciar sincronização pós-login: $e');
      }
    });
  }
}
