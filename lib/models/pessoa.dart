/// Model de Pessoa
/// Corresponde à entidade Pessoa do backend
class Pessoa {
  final int idPessoa;
  final String nome;
  final String cpfCnpj;
  final String? fone;
  final String? email;
  final bool ativo;
  bool synced;
  DateTime? updatedAt;

  Pessoa({
    required this.idPessoa,
    required this.nome,
    required this.cpfCnpj,
    this.fone,
    this.email,
    required this.ativo,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      idPessoa: json['idPessoa'] as int,
      nome: json['nome'] as String,
      cpfCnpj: json['cpfCnpj'] as String,
      fone: json['fone'] as String?,
      email: json['email'] as String?,
      ativo: json['ativo'] as bool,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Pessoa.fromDatabase(Map<String, dynamic> map) {
    return Pessoa(
      idPessoa: map['id_pessoa'] as int,
      nome: map['nome'] as String,
      cpfCnpj: map['cpf_cnpj'] as String,
      fone: map['fone'] as String?,
      email: map['email'] as String?,
      ativo: (map['ativo'] as int) == 1,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idPessoa': idPessoa,
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      'fone': fone,
      'email': email,
      'ativo': ativo,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_pessoa': idPessoa,
      'nome': nome,
      'cpf_cnpj': cpfCnpj,
      'fone': fone,
      'email': email,
      'ativo': ativo ? 1 : 0,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
