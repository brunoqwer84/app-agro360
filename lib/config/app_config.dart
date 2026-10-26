import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configurações do aplicativo
class AppConfig {
  // URL base da API - Detectada automaticamente por plataforma
  static String get baseUrl {
    // Prioridade: variável de ambiente > detecção automática > fallback
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    if (Platform.isAndroid) {
      // Celular físico na mesma rede Wi-Fi do Mac:
      return 'http://192.168.2.162:8080/api';
      // Fallback para emulador: return 'http://10.0.2.2:8080/api';
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
  static const String authFirstAccess = '/auth/first-access';
  static const String authValidate = '/auth/validate';

  // Endpoints de grupo
  static const String grupos = '/grupo';
  static const String gruposAtivos = '/grupo/ativo';

  // Endpoints de usuário
  static const String usuarios = '/usuarios';
  static const String usuariosAtivos = '/usuarios/ativos';

  // Endpoints de propriedades
  static const String propriedades = '/propriedade';
  static const String propriedadesAtivas = '/propriedade/ativo';
  static const String propriedadesMinhas = '/propriedade/minhas';

  // Endpoints de pessoas / clientes / fornecedores
  static const String pessoas = '/pessoa';
  static const String pessoasAtivas = '/pessoa/ativo';
  static const String pessoasBuscar = '/pessoa/buscar';
  static const String pessoasPorCpfCnpj = '/pessoa/cpf-cnpj';
  static const String clientes = '/pessoa/clientes';
  static const String fornecedores = '/pessoa/fornecedores';

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
  static const String pesagensPorAnimal = '/pesagem/animal';

  // Endpoints de vacinações
  static const String vacinacoes = '/vacinacao';
  static const String vacinacoesPorManejo = '/vacinacao/manejo';
  static const String vacinacoesPorAnimal = '/vacinacao/animal';

  // Endpoints de manejos
  static const String manejos = '/manejo';
  static const String manejosPorPropriedade = '/manejo/propriedade';

  // Endpoints financeiros
  static const String financeiro = '/financeiro';
  static const String financeiroBalanco = '/financeiro/balanco';
  static const String categoriasFinanceiras = '/financeiro/categorias';
  static const String compraDespesa = '/compra-despesa';
  static const String despesaLerNota = '/despesas/ler-nota';

  // Endpoints de municípios (base de dados própria)
  static const String municipios = '/municipio';

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
  static const int databaseVersion = 3;

  // Intervalo de sincronização automática (em minutos)
  static const int autoSyncInterval = 15;
}
