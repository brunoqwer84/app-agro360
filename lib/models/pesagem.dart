/// Model de Pesagem
/// Corresponde à entidade Pesagem do backend
class Pesagem {
  final int idPesagem;
  final int idManejo;
  final double pesoKg;
  bool synced;
  DateTime? updatedAt;

  Pesagem({
    required this.idPesagem,
    required this.idManejo,
    required this.pesoKg,
    this.synced = false,
    this.updatedAt,
  });

  /// Cria instância a partir de JSON da API
  factory Pesagem.fromJson(Map<String, dynamic> json) {
    return Pesagem(
      idPesagem: json['idPesagem'] as int,
      idManejo: json['idManejo'] as int,
      pesoKg: (json['pesoKg'] as num).toDouble(),
      synced: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cria instância a partir de banco de dados local (SQLite)
  factory Pesagem.fromDatabase(Map<String, dynamic> map) {
    return Pesagem(
      idPesagem: map['id_pesagem'] as int,
      idManejo: map['id_manejo'] as int,
      pesoKg: (map['peso_kg'] as num).toDouble(),
      synced: (map['synced'] as int?) == 1,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'idPesagem': idPesagem,
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
      'synced': synced ? 1 : 0,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
