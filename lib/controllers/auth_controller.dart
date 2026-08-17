import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/first_access_request.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

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
    checkAuthStatus();
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
        } catch (e) {
          // Token inválido, fazer logout
          await logout();
        }
      } else {
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('Erro ao verificar status de autenticação: $e');
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
      final authResponse = await _apiService.login(request);

      // Salvar informações do usuário
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.usernameKey, username);

      // Carregar dados do usuário
      await loadUserData(username);

      // Salvar ID do usuário
      if (currentUser.value != null) {
        await prefs.setInt(AppConfig.userIdKey, currentUser.value!.idUsuario);
      }

      isAuthenticated.value = true;
      
      // Navegar para home
      Get.offAllNamed('/home');
      
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
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
      
      // Salvar no banco local
      await _databaseService.saveUsuario(usuario);
    } catch (e) {
      // Se falhar, tentar carregar do banco local
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
      errorMessage.value = e.toString();
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
      Get.offAllNamed('/login');
    } catch (e) {
      print('Erro ao fazer logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpa mensagem de erro
  void clearError() {
    errorMessage.value = '';
  }
}
