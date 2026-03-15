/// Model de Manejo
/// Corresponde à entidade Manejo do backend
class Manejo {
  final int idManejo;
  final int idAnimal;
  final int idPropriedade;
  final String tipo;
  final DateTime data;
  final String? observacao;
  final DateTime? criadoEm;
  bool synced;
  DateTime? updatedAt;

  Manejo({
    required this.idManejo,
    required this.idAnimal,
    required this.idPropriedade,
    required this.tipo,
    required this.data,
    this.observacao,
    this.criadoEm,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Manejo.fromJson(Map<String, dynamic> json) {
    return Manejo(
      idManejo: json['idManejo'] as int,
      idAnimal: json['idAnimal'] as int,
      idPropriedade: json['idPropriedade'] as int,
      tipo: json['tipo'] as String,
      data: DateTime.parse(json['data'] as String),
      observacao: json['observacao'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Manejo.fromDatabase(Map<String, dynamic> map) {
    return Manejo(
      idManejo: map['id_manejo'] as int,
      idAnimal: map['id_animal'] as int,
      idPropriedade: map['id_propriedade'] as int,
      tipo: map['tipo'] as String,
      data: DateTime.parse(map['data'] as String),
      observacao: map['observacao'] as String?,
      criadoEm: map['criado_em'] != null
          ? DateTime.parse(map['criado_em'] as String)
          : null,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idManejo': idManejo,
      'idAnimal': idAnimal,
      'idPropriedade': idPropriedade,
      'tipo': tipo,
      'data': data.toIso8601String(),
      'observacao': observacao,
      'criadoEm': criadoEm?.toIso8601String(),
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_manejo': idManejo,
      'id_animal': idAnimal,
      'id_propriedade': idPropriedade,
      'tipo': tipo,
      'data': data.toIso8601String(),
      'observacao': observacao,
      'criado_em': criadoEm?.toIso8601String(),
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
