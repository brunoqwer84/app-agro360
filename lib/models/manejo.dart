import 'animal.dart';
import 'grupo.dart';
import 'propriedade.dart';

/// Model de Manejo
/// Corresponde à entidade Manejo do backend
class Manejo {
  final int idManejo;
  final Animal? animal;
  final Propriedade? propriedade;
  final String tipo;
  final DateTime data;
  final String? observacao;
  final DateTime? criadoEm;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper fields for backward compatibility with views
  final int idAnimal;
  final int idPropriedade;

  Manejo({
    required this.idManejo,
    this.animal,
    this.propriedade,
    required this.tipo,
    required this.data,
    this.observacao,
    this.criadoEm,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  }) : idAnimal = animal?.idAnimal ?? 0,
       idPropriedade = propriedade?.idPropriedade ?? 0;

  /// Cria instância a partir de JSON da API
  factory Manejo.fromJson(Map<String, dynamic> json) {
    return Manejo(
      idManejo: json['idManejo'] as int,
      animal: json['animal'] != null ? Animal.fromJson(json['animal']) : null,
      propriedade: json['propriedade'] != null ? Propriedade.fromJson(json['propriedade']) : null,
      tipo: json['tipo'] as String,
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
      animal: null,
      propriedade: null,
      tipo: map['tipo'] as String,
      data: DateTime.parse(map['data'] as String),
      observacao: map['observacao'] as String?,
      criadoEm: map['criado_em'] != null
          ? DateTime.parse(map['criado_em'] as String)
          : null,
      grupo: map['id_grupo'] != null ? Grupo(idGrupo: map['id_grupo'] as int, nome: '', ativo: true) : null,
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
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
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}