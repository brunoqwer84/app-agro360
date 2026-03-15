import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';
import '../models/usuario.dart';

/// Service para comunicação com a API REST
class ApiService {
  late final Dio _dio;
  String? _token;
  String? _tokenType;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor para adicionar token automaticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Adiciona token se estiver disponível
          if (_token != null && _tokenType != null) {
            options.headers['Authorization'] = '$_tokenType $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Tratamento de erros
          if (error.response?.statusCode == 401) {
            // Token inválido ou expirado - limpar token
            await clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Inicializa o serviço carregando o token salvo
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConfig.tokenKey);
    _tokenType = prefs.getString(AppConfig.tokenTypeKey);
  }

  /// Define o token de autenticação
  Future<void> setToken(String token, String type) async {
    _token = token;
    _tokenType = type;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.tokenKey, token);
    await prefs.setString(AppConfig.tokenTypeKey, type);
  }

  /// Limpa o token de autenticação
  Future<void> clearToken() async {
    _token = null;
    _tokenType = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.tokenKey);
    await prefs.remove(AppConfig.tokenTypeKey);
    await prefs.remove(AppConfig.usernameKey);
    await prefs.remove(AppConfig.userIdKey);
  }

  /// Verifica se o token está disponível
  bool get hasToken => _token != null && _token!.isNotEmpty;

  // ========== AUTENTICAÇÃO ==========

  /// Realiza login
  /// POST /api/auth/login
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        AppConfig.authLogin,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await setToken(authResponse.token, authResponse.type);
      
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Valida o token atual
  /// GET /api/auth/validate
  Future<Map<String, dynamic>> validateToken() async {
    try {
      final response = await _dio.get(AppConfig.authValidate);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== USUÁRIOS ==========

  /// Busca usuário por nome de usuário
  /// GET /api/usuarios/buscar/{nomeUsuario}
  Future<Usuario> getUsuarioByUsername(String username) async {
    try {
      final response = await _dio.get('${AppConfig.usuarios}/buscar/$username');
      return Usuario.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lista todos os usuários
  /// GET /api/usuarios
  Future<List<Usuario>> getAllUsuarios() async {
    try {
      final response = await _dio.get(AppConfig.usuarios);
      return (response.data as List)
          .map((json) => Usuario.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lista usuários ativos
  /// GET /api/usuarios/ativos
  Future<List<Usuario>> getUsuariosAtivos() async {
    try {
      final response = await _dio.get(AppConfig.usuariosAtivos);
      return (response.data as List)
          .map((json) => Usuario.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== TRATAMENTO DE ERROS ==========

  /// Trata erros da API e retorna mensagem apropriada
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return data is String ? data : 'Dados inválidos';
        case 401:
          return 'Credenciais inválidas ou token expirado';
        case 404:
          return 'Recurso não encontrado';
        case 500:
          return 'Erro interno do servidor';
        default:
          return data is String ? data : 'Erro desconhecido';
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Tempo de conexão esgotado';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de resposta esgotado';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Erro de conexão. Verifique sua internet.';
    } else {
      return 'Erro de conexão: ${error.message}';
    }
  }
}
