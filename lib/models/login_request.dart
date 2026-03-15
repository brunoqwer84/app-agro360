/// Model para requisição de login
/// Corresponde ao LoginRequest do backend
class LoginRequest {
  final String nomeUsuario;
  final String senha;

  LoginRequest({
    required this.nomeUsuario,
    required this.senha,
  });

  /// Converte para JSON para envio na API
  Map<String, dynamic> toJson() {
    return {
      'nomeUsuario': nomeUsuario,
      'senha': senha,
    };
  }

  /// Valida os campos obrigatórios
  bool isValid() {
    return nomeUsuario.isNotEmpty && senha.isNotEmpty;
  }
}
