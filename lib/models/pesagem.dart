import 'grupo.dart';
import 'manejo.dart';

/// Model de Pesagem
/// Corresponde à entidade Pesagem do backend
class Pesagem {
  final int idPesagem;
  final Manejo? manejo;
  final double pesoKg;
  final Grupo? grupo;
  bool synced;
  DateTime? updatedAt;

  // Helper field for backward compatibility with views
  final int idManejo;

  Pesagem({
    required this.idPesagem,
    this.manejo,
    required this.pesoKg,
    this.grupo,
    this.synced = false,
    this.updatedAt,
  }) : idManejo = manejo?.idManejo ?? 0;

  /// Cria instância a partir de JSON da API
  factory Pesagem.fromJson(Map<String, dynamic> json) {
    return Pesagem(
      idPesagem: json['idPesagem'] as int,
      manejo: json['manejo'] != null ? Manejo.fromJson(json['manejo']) : null,
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
      pesoKg: (map['peso_kg'] as num).toDouble(),
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
      'idManejo': idManejo,
      'pesoKg': pesoKg,
    };
  }

  /// Converte para Map para salvar no SQLite
  Map<String, dynamic> toDatabase() {
    return {
      'id_pesagem': idPesagem,
      'id_manejo': idManejo,
      'peso_kg': pesoKg,
      'id_grupo': grupo?.idGrupo,
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}