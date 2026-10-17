import 'animal.dart';
import 'grupo.dart';
import 'manejo.dart';

/// Model de Pesagem
/// Peso de um animal informado dentro de um manejo generico.
class Pesagem {
  final int idPesagem;
  final Manejo? manejo;
  final Animal? animal;
  final double pesoKg;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper fields for backward compatibility with views
  final int idManejo;
  final int idAnimal;

  Pesagem({
    required this.idPesagem,
    this.manejo,
    this.animal,
    required this.pesoKg,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  })  : idManejo = manejo?.idManejo ?? 0,
        idAnimal = animal?.idAnimal ?? 0;

  /// Cria instância a partir de JSON da API
  factory Pesagem.fromJson(Map<String, dynamic> json) {
    return Pesagem(
      idPesagem: json['idPesagem'] as int,
      manejo: json['manejo'] != null ? Manejo.fromJson(json['manejo']) : null,
      animal: json['animal'] != null ? Animal.fromJson(json['animal']) : null,
      pesoKg: (json['pesoKg'] as num).toDouble(),
      grupo: json['grupo'] != null ? Grupo.fromJson(json['grupo']) : null,
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Pesagem.fromDatabase(Map<String, dynamic> map) {
    return Pesagem(
      idPesagem: map['id_pesagem'] as int,
      manejo: null,
      animal: null,
      pesoKg: (map['peso_kg'] as num).toDouble(),
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
      'pesoKg': pesoKg,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_pesagem': idPesagem,
      'id_manejo': idManejo,
      'id_animal': idAnimal,
      'peso_kg': pesoKg,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
