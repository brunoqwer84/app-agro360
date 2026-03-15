/// Model de Vacinação
/// Corresponde à entidade Vacinacao do backend
class Vacinacao {
  final int idVacinacao;
  final int idManejo;
  final String nome;
  final DateTime proximaDose;
  bool synced;
  DateTime? updatedAt;

  Vacinacao({
    required this.idVacinacao,
    required this.idManejo,
    required this.nome,
    required this.proximaDose,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Vacinacao.fromJson(Map<String, dynamic> json) {
    return Vacinacao(
      idVacinacao: json['idVacinacao'] as int,
      idManejo: json['idManejo'] as int,
      nome: json['nome'] as String,
      proximaDose: DateTime.parse(json['proximaDose'] as String),
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Vacinacao.fromDatabase(Map<String, dynamic> map) {
    return Vacinacao(
      idVacinacao: map['id_vacinacao'] as int,
      idManejo: map['id_manejo'] as int,
      nome: map['nome'] as String,
      proximaDose: DateTime.parse(map['proxima_dose'] as String),
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idVacinacao': idVacinacao,
      'idManejo': idManejo,
      'nome': nome,
      'proximaDose': proximaDose.toIso8601String(),
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_vacinacao': idVacinacao,
      'id_manejo': idManejo,
      'nome': nome,
      'proxima_dose': proximaDose.toIso8601String(),
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica se a vacina está vencida
  bool get isVencida => proximaDose.isBefore(DateTime.now());

  /// Retorna dias restantes até a próxima dose
  int get diasRestantes => proximaDose.difference(DateTime.now()).inDays;
}
