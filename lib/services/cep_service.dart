import 'package:dio/dio.dart';

/// Resultado da consulta de CEP (ViaCEP / BrasilAPI)
class EnderecoCepResult {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String cidade;
  final String uf;

  EnderecoCepResult({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.uf,
  });

  factory EnderecoCepResult.fromViaCep(Map<String, dynamic> json) {
    return EnderecoCepResult(
      cep: json['cep'] as String? ?? '',
      logradouro: json['logradouro'] as String? ?? '',
      complemento: json['complemento'] as String? ?? '',
      bairro: json['bairro'] as String? ?? '',
      cidade: (json['localidade'] as String? ?? '').trim(),
      uf: (json['uf'] as String? ?? '').trim().toUpperCase(),
    );
  }

  factory EnderecoCepResult.fromBrasilApi(Map<String, dynamic> json) {
    return EnderecoCepResult(
      cep: json['cep'] as String? ?? '',
      logradouro: json['street'] as String? ?? '',
      complemento: '',
      bairro: json['neighborhood'] as String? ?? '',
      cidade: (json['city'] as String? ?? '').trim(),
      uf: (json['state'] as String? ?? '').trim().toUpperCase(),
    );
  }
}

/// Serviço de consulta pública e gratuita de CEP (ViaCEP com fallback para BrasilAPI)
class CepService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
    validateStatus: (status) => status != null && status < 500,
  ));

  /// Consulta os dados do endereço a partir do CEP informado
  Future<EnderecoCepResult?> buscarCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length != 8) return null;

    // 1. Tenta ViaCEP (API padrão aberta brasileira)
    try {
      final response = await _dio.get('https://viacep.com.br/ws/$cleanCep/json/');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['erro'] == true || data['erro'] == 'true') {
          return null;
        }
        return EnderecoCepResult.fromViaCep(data);
      }
    } catch (_) {
      // Ignora para tentar o fallback
    }

    // 2. Fallback para BrasilAPI caso o ViaCEP oscile
    try {
      final fallbackResponse =
          await _dio.get('https://brasilapi.com.br/api/cep/v1/$cleanCep');
      if (fallbackResponse.statusCode == 200 && fallbackResponse.data is Map) {
        final data = fallbackResponse.data as Map<String, dynamic>;
        return EnderecoCepResult.fromBrasilApi(data);
      }
    } catch (_) {
      // Falha em ambos
    }

    return null;
  }

  // Cache em memória das cidades por UF para evitar requisições repetidas
  final Map<String, List<String>> _cacheCidadesPorUf = {};

  /// Lista os municípios de um determinado estado (UF) em ordem alfabética.
  /// Utiliza cache em memória para resposta instantânea após a primeira consulta.
  Future<List<String>> listarCidadesPorUf(String uf) async {
    final cleanUf = uf.trim().toUpperCase();
    if (cleanUf.length != 2) return [];

    if (_cacheCidadesPorUf.containsKey(cleanUf) &&
        _cacheCidadesPorUf[cleanUf]!.isNotEmpty) {
      return _cacheCidadesPorUf[cleanUf]!;
    }

    // 1. Tenta API oficial de Localidades do IBGE
    try {
      final response = await _dio.get(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$cleanUf/municipios?orderBy=nome',
      );
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((item) {
              if (item is Map) {
                return (item['nome'] as String? ?? '').trim();
              }
              return '';
            })
            .where((nome) => nome.isNotEmpty)
            .toList();

        if (list.isNotEmpty) {
          list.sort((a, b) => a.compareTo(b));
          _cacheCidadesPorUf[cleanUf] = list;
          return list;
        }
      }
    } catch (_) {
      // Ignora para tentar fallback
    }

    // 2. Fallback para BrasilAPI
    try {
      final fallbackResponse = await _dio.get(
        'https://brasilapi.com.br/api/ibge/municipios/v1/$cleanUf',
      );
      if (fallbackResponse.statusCode == 200 && fallbackResponse.data is List) {
        final list = (fallbackResponse.data as List)
            .map((item) {
              if (item is Map) {
                return (item['nome'] as String? ?? '').trim();
              }
              return '';
            })
            .where((nome) => nome.isNotEmpty)
            .toList();

        if (list.isNotEmpty) {
          list.sort((a, b) => a.compareTo(b));
          _cacheCidadesPorUf[cleanUf] = list;
          return list;
        }
      }
    } catch (_) {
      // Falha em ambos
    }

    return _cacheCidadesPorUf[cleanUf] ?? [];
  }
}
