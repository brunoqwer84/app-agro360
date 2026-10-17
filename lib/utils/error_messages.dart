import 'package:dio/dio.dart';

/// Traduz exceções (rede/API/parse) em mensagens amigáveis ao usuário.
class AppError {
  AppError._();

  /// Retorna mensagem amigável para exibição em snackbars/banners.
  static String getErrorMessage(Object error) {
    if (error is String && error.trim().isNotEmpty) {
      return error.trim();
    }
    if (error is DioException) {
      return _fromDio(error);
    }
    if (error is FormatException) {
      return 'Dados inválidos';
    }
    if (error is TypeError || error is StateError) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
    final str = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return str.isNotEmpty ? str : 'Ocorreu um erro inesperado. Tente novamente.';
  }

  static String _fromDio(DioException error) {
    final response = error.response;

    if (response != null) {
      final message = _extractMessage(response.data);
      switch (response.statusCode) {
        case 400:
          return message ?? 'Dados inválidos';
        case 401:
          return message ?? 'Credenciais inválidas ou token expirado';
        case 403:
          return message ?? 'Você não tem permissão para esta ação';
        case 404:
          return message ?? 'Recurso não encontrado';
        case 409:
          return message ?? 'Registro duplicado ou operação não permitida';
        case 500:
          return message ?? 'Erro interno do servidor';
        default:
          return message ?? 'Erro desconhecido';
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo de conexão esgotado';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Tempo de resposta esgotado';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique sua internet.';
      case DioExceptionType.cancel:
        return 'Operação cancelada';
      default:
        return 'Erro de conexão. Tente novamente.';
    }
  }

  /// Extrai mensagem de erros estruturados do backend.
  /// Suporta o ErrorResponse da API ({"mensagem": ...}) e o formato
  /// padrão do Spring ({"message": ...} / {"error": ...}).
  static String? _extractMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      for (final key in ['mensagem', 'message', 'error']) {
        if (data.containsKey(key)) {
          final value = data[key];
          if (value is String && value.trim().isNotEmpty) return value;
          if (value is Map) return _extractMessage(value);
          if (value is List && value.isNotEmpty) {
            return _extractMessage(value.first);
          }
        }
      }
      if (data.containsKey('errors')) {
        return _extractMessage(data['errors']);
      }
      if (data.values.isNotEmpty) {
        return _extractMessage(data.values.first);
      }
    }
    if (data is List && data.isNotEmpty) {
      return _extractMessage(data.first);
    }
    return null;
  }
}
