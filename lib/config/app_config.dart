import 'dart:io';

/// Configurações do aplicativo
class AppConfig {
  // URL base da API - Detectada automaticamente por plataforma
  static String get baseUrl {
    // Prioridade: variável de ambiente > detecção automática > fallback
    final envUrl = const String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (Platform.isAndroid) {
      // Android Emulator: usa 10.0.2.2 para acessar localhost do host
      return 'http://10.0.2.2:8080/api';
    } else if (Platform.isIOS) {
      // iOS Simulator e dispositivo físico: localhost
      return 'http://localhost:8080/api';
    } else if (Platform.isMacOS) {
      // macOS desktop
      return 'http://localhost:8080/api';
    }

    // Fallback (web, linux, windows)
    return 'http://localhost:8080/api';
  }

  // Endpoints de autenticação
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authFirstAccess = '/auth/first-access';
  static const String authValidate = '/auth/validate';

  // Endpoints de usuário
  static const String usuarios = '/usuarios';
  static const String usuariosAtivos = '/usuarios/ativos';

  // Endpoints de propriedades
  static const String propriedades = '/propriedade';
  static const String propriedadesAtivas = '/propriedade/ativo';

  // Endpoints de raças
  static const String racas = '/raca';
  static const String racasBuscar = '/raca/buscar';

  // Endpoints de animais
  static const String animais = '/animal';
  static const String animaisPorPropriedade = '/animal/propriedade';
  static const String animaisPorRaca = '/animal/raca';
  static const String animaisPorStatus = '/animal/status';

  // Endpoints de pesagens
  static const String pesagens = '/pesagem';
  static const String pesagensPorManejo = '/pesagem/manejo';

  // Endpoints de vacinações
  static const String vacinacoes = '/vacinacao';
  static const String vacinacoesPorManejo = '/vacinacao/manejo';

  // Endpoints de manejos
  static const String manejos = '/manejo';
  static const String manejosPorAnimal = '/manejo/animal';
  static const String manejosPorPropriedade = '/manejo/propriedade';
  static const String manejosPorTipo = '/manejo/tipo';

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