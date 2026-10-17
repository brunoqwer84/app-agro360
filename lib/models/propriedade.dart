import 'grupo.dart';

/// Model de Propriedade
/// Corresponde à entidade Propriedade do backend
class Propriedade {
  final int idPropriedade;
  final String nome;
  final bool ativo;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  Propriedade({
    required this.idPropriedade,
    required this.nome,
    required this.ativo,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Propriedade.fromJson(Map<String, dynamic> json) {
    return Propriedade(
      idPropriedade: json['idPropriedade'] as int,
      nome: json['nome'] as String,
      ativo: json['ativo'] as bool,
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
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
      'nome': nome,
      'ativo': ativo,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_propriedade': idPropriedade,
      'nome': nome,
      'ativo': ativo ? 1 : 0,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
