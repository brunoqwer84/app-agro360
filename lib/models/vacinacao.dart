import 'animal.dart';
import 'grupo.dart';
import 'manejo.dart';

/// Model de Vacinação
/// Vacina aplicada a um animal dentro de um manejo generico.
class Vacinacao {
  final int idVacinacao;
  final Manejo? manejo;
  final Animal? animal;
  final String nome;
  final DateTime proximaDose;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper fields for backward compatibility with views
  final int idManejo;
  final int idAnimal;

  Vacinacao({
    required this.idVacinacao,
    this.manejo,
    this.animal,
    required this.nome,
    required this.proximaDose,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  })  : idManejo = manejo?.idManejo ?? 0,
        idAnimal = animal?.idAnimal ?? 0;

  /// Cria instância a partir de JSON da API
  factory Vacinacao.fromJson(Map<String, dynamic> json) {
    return Vacinacao(
      idVacinacao: json['idVacinacao'] as int,
      manejo: json['manejo'] != null ? Manejo.fromJson(json['manejo']) : null,
      animal: json['animal'] != null ? Animal.fromJson(json['animal']) : null,
      nome: json['nome'] as String,
      proximaDose: DateTime.parse(json['proximaDose'] as String),
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Vacinacao.fromDatabase(Map<String, dynamic> map) {
    return Vacinacao(
      idVacinacao: map['id_vacinacao'] as int,
      manejo: null,
      animal: null,
      nome: map['nome'] as String,
      proximaDose: DateTime.parse(map['proxima_dose'] as String),
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
      'idManejo': idManejo,
      'idAnimal': idAnimal,
      'nome': nome,
      'proximaDose': proximaDose.toIso8601String(),
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_vacinacao': idVacinacao,
      'id_manejo': idManejo,
      'id_animal': idAnimal,
      'nome': nome,
      'proxima_dose': proximaDose.toIso8601String(),
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Verifica se a vacina está vencida
  bool get isVencida => proximaDose.isBefore(DateTime.now());

  /// Retorna dias restantes até a próxima dose
  int get diasRestantes => proximaDose.difference(DateTime.now()).inDays;
}
