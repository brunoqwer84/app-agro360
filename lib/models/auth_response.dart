/// Model para resposta de autenticação
/// Corresponde ao AuthResponse do backend
class AuthResponse {
  final String token;
  final String type;

  AuthResponse({
    required this.token,
    required this.type,
  });

  /// Cria instância a partir de JSON da API
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
    };
  }

  /// Retorna o header de autorização completo
  String get authorizationHeader => '$type $token';
}
