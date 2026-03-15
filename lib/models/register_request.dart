/// Model para requisição de registro de novo usuário
/// Corresponde ao RegisterRequest do backend
class RegisterRequest {
  final String nomeUsuario;
  final String senha;
  final String email;
  final String idPessoa;

  RegisterRequest({
    required this.nomeUsuario,
    required this.senha,
    required this.email,
    required this.idPessoa,
  });

  /// Converte para JSON para envio na API
  Map<String, dynamic> toJson() {
    return {
      'nomeUsuario': nomeUsuario,
      'senha': senha,
      'email': email,
      'idPessoa': idPessoa,
    };
  }

  /// Valida os campos obrigatórios
  bool isValid() {
    return nomeUsuario.length >= 3 &&
        nomeUsuario.length <= 20 &&
        senha.length >= 6 &&
        email.isNotEmpty &&
        idPessoa.isNotEmpty;
  }
}
