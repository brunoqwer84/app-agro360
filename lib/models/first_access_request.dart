/// Model para requisição de primeiro acesso
/// Cria Grupo + Pessoa + Usuário em uma única transação no backend
class FirstAccessRequest {
  final String nome;
  final String cpfCnpj;
  final String? fone;
  final String email;
  final String nomeUsuario;
  final String senha;
  final int? idGrupo;
  final String? nomeGrupo;
  final String? cnpjGrupo;
  final String? nomePropriedade;

  FirstAccessRequest({
    required this.nome,
    required this.cpfCnpj,
    this.fone,
    required this.email,
    required this.nomeUsuario,
    required this.senha,
    this.idGrupo,
    this.nomeGrupo,
    this.cnpjGrupo,
    this.nomePropriedade,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      'fone': fone,
      'email': email,
      'nomeUsuario': nomeUsuario,
      'senha': senha,
      'idGrupo': idGrupo,
      'nomeGrupo': nomeGrupo,
      'cnpjGrupo': cnpjGrupo,
      'nomePropriedade': nomePropriedade,
    };
  }

  bool isValid() {
    return nome.isNotEmpty &&
        cpfCnpj.isNotEmpty &&
        email.isNotEmpty &&
        nomeUsuario.length >= 3 &&
        senha.length >= 6;
  }
}

/// Model para resposta do primeiro acesso
class FirstAccessResponse {
  final bool sucesso;
  final String mensagem;
  final int? idPessoa;
  final int? idUsuario;
  final String? nomeUsuario;
  final int? idGrupo;

  FirstAccessResponse({
    required this.sucesso,
    required this.mensagem,
    this.idPessoa,
    this.idUsuario,
    this.nomeUsuario,
    this.idGrupo,
  });

  factory FirstAccessResponse.fromJson(Map<String, dynamic> json) {
    return FirstAccessResponse(
      sucesso: json['sucesso'] as bool? ?? false,
      mensagem: json['mensagem'] as String? ?? '',
      idPessoa: json['idPessoa'] != null ? (json['idPessoa'] as num).toInt() : null,
      idUsuario: json['idUsuario'] != null ? (json['idUsuario'] as num).toInt() : null,
      nomeUsuario: json['nomeUsuario'] as String?,
      idGrupo: json['idGrupo'] != null ? (json['idGrupo'] as num).toInt() : null,
    );
  }
}