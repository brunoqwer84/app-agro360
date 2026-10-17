import 'grupo.dart';
import 'propriedade.dart';

/// Model de Manejo
/// Manejo generico: evento de campo em uma propriedade (data + observacao).
/// Nao possui animal nem tipo - pesagens/vacinacoes de varios animais
/// sao vinculadas ao manejo por suas proprias entidades.
class Manejo {
  final int idManejo;
  final Propriedade? propriedade;
  final DateTime data;
  final String? observacao;
  final DateTime? criadoEm;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper field for backward compatibility with views
  final int idPropriedade;

  Manejo({
    required this.idManejo,
    this.propriedade,
    required this.data,
    this.observacao,
    this.criadoEm,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  }) : idPropriedade = propriedade?.idPropriedade ?? 0;

  /// Cria instância a partir de JSON da API
  factory Manejo.fromJson(Map<String, dynamic> json) {
    return Manejo(
      idManejo: json['idManejo'] as int,
      propriedade: json['propriedade'] != null
          ? Propriedade.fromJson(json['propriedade'])
          : null,
      data: DateTime.parse(json['data'] as String),
      observacao: json['observacao'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : null,
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Manejo.fromDatabase(Map<String, dynamic> map) {
    return Manejo(
      idManejo: map['id_manejo'] as int,
      propriedade: null,
      data: DateTime.parse(map['data'] as String),
      observacao: map['observacao'] as String?,
      criadoEm: map['criado_em'] != null
          ? DateTime.parse(map['criado_em'] as String)
          : null,
      grupo: map['id_grupo'] != null
          ? Grupo(idGrupo: map['id_grupo'] as int, nome: '', ativo: true)
          : null,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON (payload da API)
  Map<String, dynamic> toJson() {
    return {
      'idPropriedade': idPropriedade,
      'data': data.toIso8601String(),
      'observacao': observacao,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_manejo': idManejo,
      'id_propriedade': idPropriedade,
      'data': data.toIso8601String(),
      'observacao': observacao,
      'criado_em': criadoEm?.toIso8601String(),
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
