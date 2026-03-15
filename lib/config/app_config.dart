/// Configurações do aplicativo
class AppConfig {
  // URL base da API - AJUSTE CONFORME SEU AMBIENTE
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Endpoints de autenticação
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authValidate = '/auth/validate';
  
  // Endpoints de usuário
  static const String usuarios = '/usuarios';
  static const String usuariosAtivos = '/usuarios/ativos';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Chaves de armazenamento local
  static const String tokenKey = 'auth_token';
  static const String tokenTypeKey = 'token_type';
  static const String usernameKey = 'username';
  static const String userIdKey = 'user_id';
  
  // Banco de dados
  static const String databaseName = 'agro360.db';
  static const int databaseVersion = 1;
  
  // Intervalo de sincronização automática (em minutos)
  static const int autoSyncInterval = 15;
}
