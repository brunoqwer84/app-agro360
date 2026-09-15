import 'grupo.dart';
import 'propriedade.dart';
import 'raca.dart';

/// Model de Animal
/// Corresponde à entidade Animal do backend
class Animal {
  final int idAnimal;
  final String identificacao;
  final String sexo; // 'M' ou 'F'
  final DateTime? dataNascimento;
  final String? tipoProducao;
  final String? status;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;
  final Propriedade propriedade;
  final Raca raca;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper fields for backward compatibility with views
  final int idPropriedade;
  final int idRaca;

  Animal({
    required this.idAnimal,
    required this.identificacao,
    required this.sexo,
    this.dataNascimento,
    this.tipoProducao,
    this.status,
    this.criadoEm,
    this.atualizadoEm,
    required this.propriedade,
    required this.raca,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  }) : idPropriedade = propriedade.idPropriedade,
       idRaca = raca.idRaca;

  /// Cria instância a partir de JSON da API
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      idAnimal: json['idAnimal'] as int,
      identificacao: json['identificacao'] as String,
      sexo: json['sexo'] as String,
      dataNascimento: json['dataNascimento'] != null
          ? DateTime.parse(json['dataNascimento'] as String)
          : null,
      tipoProducao: json['tipoProducao'] as String?,
      status: json['status'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.parse(json['criadoEm'] as String)
          : null,
      atualizadoEm: json['atualizadoEm'] != null
          ? DateTime.parse(json['atualizadoEm'] as String)
          : null,
      propriedade: json['propriedade'] != null ? Propriedade.fromJson(json['propriedade']) : Propriedade(idPropriedade: 0, nome: '', ativo: true, grupo: null),
      raca: json['raca'] != null ? Raca.fromJson(json['raca']) : Raca(idRaca: 0, descricao: '', grupo: null),
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Animal.fromDatabase(Map<String, dynamic> map) {
    return Animal(
      idAnimal: map['id_animal'] as int,
      identificacao: map['identificacao'] as String,
      sexo: map['sexo'] as String,
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.parse(map['data_nascimento'] as String)
          : null,
      tipoProducao: map['tipo_producao'] as String?,
      status: map['status'] as String?,
      criadoEm: map['criado_em'] != null
          ? DateTime.parse(map['criado_em'] as String)
          : null,
      atualizadoEm: map['atualizado_em'] != null
          ? DateTime.parse(map['atualizado_em'] as String)
          : null,
      propriedade: Propriedade(idPropriedade: map['id_propriedade'] as int, nome: '', ativo: true, grupo: null),
      raca: Raca(idRaca: map['id_raca'] as int, descricao: '', grupo: null),
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
      'identificacao': identificacao,
      'sexo': sexo,
      'dataNascimento': dataNascimento?.toIso8601String(),
      'tipoProducao': tipoProducao,
      'status': status,
      'idPropriedade': propriedade.idPropriedade,
      'idRaca': raca.idRaca,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_animal': idAnimal,
      'identificacao': identificacao,
      'sexo': sexo,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'tipo_producao': tipoProducao,
      'status': status,
      'criado_em': criadoEm?.toIso8601String(),
      'atualizado_em': atualizadoEm?.toIso8601String(),
      'id_propriedade': propriedade.idPropriedade,
      'id_raca': raca.idRaca,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Retorna idade do animal em anos
  int? get idadeAnos {
    if (dataNascimento == null) return null;
    final hoje = DateTime.now();
    final diferenca = hoje.difference(dataNascimento!);
    return (diferenca.inDays / 365).floor();
  }
}