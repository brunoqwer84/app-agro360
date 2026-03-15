/// Model de Propriedade
/// Corresponde à entidade Propriedade do backend
class Propriedade {
  final int idPropriedade;
  final String nome;
  final bool ativo;
  final int idPessoa;
  bool synced;
  DateTime? updatedAt;

  Propriedade({
    required this.idPropriedade,
    required this.nome,
    required this.ativo,
    required this.idPessoa,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Propriedade.fromJson(Map<String, dynamic> json) {
    return Propriedade(
      idPropriedade: json['idPropriedade'] as int,
      nome: json['nome'] as String,
      ativo: json['ativo'] as bool,
      idPessoa: json['idPessoa'] as int,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Propriedade.fromDatabase(Map<String, dynamic> map) {
    return Propriedade(
      idPropriedade: map['id_propriedade'] as int,
      nome: map['nome'] as String,
      ativo: (map['ativo'] as int) == 1,
      idPessoa: map['id_pessoa'] as int,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idPropriedade': idPropriedade,
      'nome': nome,
      'ativo': ativo,
      'idPessoa': idPessoa,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_propriedade': idPropriedade,
      'nome': nome,
      'ativo': ativo ? 1 : 0,
      'id_pessoa': idPessoa,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
