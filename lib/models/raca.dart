import 'grupo.dart';

/// Model de Raça
/// Corresponde à entidade Raca do backend
class Raca {
  final int idRaca;
  final String descricao;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  Raca({
    required this.idRaca,
    required this.descricao,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Raca.fromJson(Map<String, dynamic> json) {
    return Raca(
      idRaca: json['idRaca'] as int,
      descricao: json['descricao'] as String,
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Raca.fromDatabase(Map<String, dynamic> map) {
    return Raca(
      idRaca: map['id_raca'] as int,
      descricao: map['descricao'] as String,
      grupo: map['id_grupo'] != null
          ? Grupo(idGrupo: map['id_grupo'] as int, nome: '', ativo: true)
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
      'descricao': descricao,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_raca': idRaca,
      'descricao': descricao,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
