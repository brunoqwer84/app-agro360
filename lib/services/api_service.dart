import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';
import '../models/first_access_request.dart';
import '../models/propriedade.dart';
import '../models/raca.dart';
import '../models/propriedade.dart';
import '../models/animal.dart';
import '../models/manejo.dart';
import '../models/pesagem.dart';
import '../models/vacinacao.dart';
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

  /// Realiza o primeiro acesso (cadastro de Pessoa + Usuário)
  /// POST /api/auth/first-access
  Future<FirstAccessResponse> firstAccess(FirstAccessRequest request) async {
    try {
      final response = await _dio.post(
        AppConfig.authFirstAccess,
        data: request.toJson(),
      );
      return FirstAccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Tenta extrair mensagem estruturada do backend
      if (e.response?.data is Map) {
        try {
          return FirstAccessResponse.fromJson(
              e.response!.data as Map<String, dynamic>);
        } catch (_) {
          // ignora e cai no fluxo padrão
        }
      }
      throw _handleError(e);
    }
  }

  // ========== PROPRIEDADES ==========

  /// Lista todas as propriedades
  /// GET /api/propriedade
  Future<List<Propriedade>> getAllPropriedades() async {
    try {
      final response = await _dio.get(AppConfig.propriedades);
      return (response.data as List)
          .map((json) => Propriedade.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lista apenas propriedades ativas
  /// GET /api/propriedade/ativo
  Future<List<Propriedade>> getPropriedadesAtivas() async {
    try {
      final response = await _dio.get(AppConfig.propriedadesAtivas);
      return (response.data as List)
          .map((json) => Propriedade.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lista propriedades por pessoa
  /// GET /api/propriedade/pessoa/{idPessoa}
  Future<List<Propriedade>> getPropriedadesByPessoa(int idPessoa) async {
    try {
      final response = await _dio.get('${AppConfig.propriedades}/pessoa/$idPessoa');
      return (response.data as List)
          .map((json) => Propriedade.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca propriedade por ID
  /// GET /api/propriedade/{id}
  Future<Propriedade> getPropriedadeById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.propriedades}/$id');
      return Propriedade.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cria nova propriedade
  /// POST /api/propriedade
  Future<Propriedade> createPropriedade(Propriedade propriedade) async {
    try {
      final response = await _dio.post(
        AppConfig.propriedades,
        data: propriedade.toJson(),
      );
      return Propriedade.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Atualiza propriedade
  /// PUT /api/propriedade/{id}
  Future<Propriedade> updatePropriedade(int id, Propriedade propriedade) async {
    try {
      final response = await _dio.put(
        '${AppConfig.propriedades}/$id',
        data: propriedade.toJson(),
      );
      return Propriedade.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deleta propriedade
  /// DELETE /api/propriedade/{id}
  Future<void> deletePropriedade(int id) async {
    try {
      await _dio.delete('${AppConfig.propriedades}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== RAÇAS ==========

  /// Lista todas as raças
  /// GET /api/raca
  Future<List<Raca>> getAllRacas() async {
    try {
      final response = await _dio.get(AppConfig.racas);
      return (response.data as List)
          .map((json) => Raca.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca raças por descrição
  /// GET /api/raca/buscar?descricao=...
  Future<List<Raca>> searchRacas(String descricao) async {
    try {
      final response = await _dio.get(
        AppConfig.racasBuscar,
        queryParameters: {'descricao': descricao},
      );
      return (response.data as List)
          .map((json) => Raca.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Busca raça por ID
  /// GET /api/raca/{id}
  Future<Raca> getRacaById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.racas}/$id');
      return Raca.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cria raça
  /// POST /api/raca
  Future<Raca> createRaca(Raca raca) async {
    try {
      final response = await _dio.post(
        AppConfig.racas,
        data: raca.toJson(),
      );
      return Raca.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Atualiza raça
  /// PUT /api/raca/{id}
  Future<Raca> updateRaca(int id, Raca raca) async {
    try {
      final response = await _dio.put(
        '${AppConfig.racas}/$id',
        data: raca.toJson(),
      );
      return Raca.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Deleta raça
  /// DELETE /api/raca/{id}
  Future<void> deleteRaca(int id) async {
    try {
      await _dio.delete('${AppConfig.racas}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ========== ANIMAIS ==========

  /// Lista todos os animais
  Future<List<Animal>> getAllAnimais() async {
    try {
      final response = await _dio.get(AppConfig.animais);
      return (response.data as List).map((json) => Animal.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista animais por propriedade
  Future<List<Animal>> getAnimaisPorPropriedade(int idPropriedade) async {
    try {
      final response = await _dio.get('${AppConfig.animaisPorPropriedade}/$idPropriedade');
      return (response.data as List).map((json) => Animal.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista animais por raça
  Future<List<Animal>> getAnimaisPorRaca(int idRaca) async {
    try {
      final response = await _dio.get('${AppConfig.animaisPorRaca}/$idRaca');
      return (response.data as List).map((json) => Animal.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista animais por status
  Future<List<Animal>> getAnimaisPorStatus(String status) async {
    try {
      final response = await _dio.get('${AppConfig.animaisPorStatus}/$status');
      return (response.data as List).map((json) => Animal.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Busca animal por ID
  Future<Animal> getAnimalById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.animais}/$id');
      return Animal.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Cria animal
  Future<Animal> createAnimal(Animal animal) async {
    try {
      final response = await _dio.post(AppConfig.animais, data: animal.toJson());
      return Animal.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Atualiza animal
  Future<Animal> updateAnimal(int id, Animal animal) async {
    try {
      final response = await _dio.put('${AppConfig.animais}/$id', data: animal.toJson());
      return Animal.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Deleta animal
  Future<void> deleteAnimal(int id) async {
    try {
      await _dio.delete('${AppConfig.animais}/$id');
    } on DioException catch (e) { throw _handleError(e); }
  }

  // ========== MANEJOS ==========

  /// Lista todos os manejos
  Future<List<Manejo>> getAllManejos() async {
    try {
      final response = await _dio.get(AppConfig.manejos);
      return (response.data as List).map((json) => Manejo.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista manejos por animal
  Future<List<Manejo>> getManejosPorAnimal(int idAnimal) async {
    try {
      final response = await _dio.get('${AppConfig.manejosPorAnimal}/$idAnimal');
      return (response.data as List).map((json) => Manejo.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista manejos por propriedade
  Future<List<Manejo>> getManejosPorPropriedade(int idPropriedade) async {
    try {
      final response = await _dio.get('${AppConfig.manejosPorPropriedade}/$idPropriedade');
      return (response.data as List).map((json) => Manejo.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista manejos por tipo
  Future<List<Manejo>> getManejosPorTipo(String tipo) async {
    try {
      final response = await _dio.get('${AppConfig.manejosPorTipo}/$tipo');
      return (response.data as List).map((json) => Manejo.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Busca manejo por ID
  Future<Manejo> getManejoById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.manejos}/$id');
      return Manejo.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Cria manejo
  Future<Manejo> createManejo(Manejo manejo) async {
    try {
      final response = await _dio.post(AppConfig.manejos, data: manejo.toJson());
      return Manejo.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Atualiza manejo
  Future<Manejo> updateManejo(int id, Manejo manejo) async {
    try {
      final response = await _dio.put('${AppConfig.manejos}/$id', data: manejo.toJson());
      return Manejo.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Deleta manejo
  Future<void> deleteManejo(int id) async {
    try {
      await _dio.delete('${AppConfig.manejos}/$id');
    } on DioException catch (e) { throw _handleError(e); }
  }

  // ========== PESAGENS ==========

  /// Lista todas as pesagens
  Future<List<Pesagem>> getAllPesagens() async {
    try {
      final response = await _dio.get(AppConfig.pesagens);
      return (response.data as List).map((json) => Pesagem.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista pesagens por manejo
  Future<List<Pesagem>> getPesagensPorManejo(int idManejo) async {
    try {
      final response = await _dio.get('${AppConfig.pesagensPorManejo}/$idManejo');
      return (response.data as List).map((json) => Pesagem.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Busca pesagem por ID
  Future<Pesagem> getPesagemById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.pesagens}/$id');
      return Pesagem.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Cria pesagem
  Future<Pesagem> createPesagem(Pesagem pesagem) async {
    try {
      final response = await _dio.post(AppConfig.pesagens, data: pesagem.toJson());
      return Pesagem.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Atualiza pesagem
  Future<Pesagem> updatePesagem(int id, Pesagem pesagem) async {
    try {
      final response = await _dio.put('${AppConfig.pesagens}/$id', data: pesagem.toJson());
      return Pesagem.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Deleta pesagem
  Future<void> deletePesagem(int id) async {
    try {
      await _dio.delete('${AppConfig.pesagens}/$id');
    } on DioException catch (e) { throw _handleError(e); }
  }

  // ========== VACINAÇÕES ==========

  /// Lista todas as vacinações
  Future<List<Vacinacao>> getAllVacinacoes() async {
    try {
      final response = await _dio.get(AppConfig.vacinacoes);
      return (response.data as List).map((json) => Vacinacao.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Lista vacinações por manejo
  Future<List<Vacinacao>> getVacinacoesPorManejo(int idManejo) async {
    try {
      final response = await _dio.get('${AppConfig.vacinacoesPorManejo}/$idManejo');
      return (response.data as List).map((json) => Vacinacao.fromJson(json)).toList();
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Busca vacinação por ID
  Future<Vacinacao> getVacinacaoById(int id) async {
    try {
      final response = await _dio.get('${AppConfig.vacinacoes}/$id');
      return Vacinacao.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Cria vacinação
  Future<Vacinacao> createVacinacao(Vacinacao vacinacao) async {
    try {
      final response = await _dio.post(AppConfig.vacinacoes, data: vacinacao.toJson());
      return Vacinacao.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Atualiza vacinação
  Future<Vacinacao> updateVacinacao(int id, Vacinacao vacinacao) async {
    try {
      final response = await _dio.put('${AppConfig.vacinacoes}/$id', data: vacinacao.toJson());
      return Vacinacao.fromJson(response.data);
    } on DioException catch (e) { throw _handleError(e); }
  }

  /// Deleta vacinação
  Future<void> deleteVacinacao(int id) async {
    try {
      await _dio.delete('${AppConfig.vacinacoes}/$id');
    } on DioException catch (e) { throw _handleError(e); }
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
