class Municipio {
  final int? idMunicipio;
  final int codigoIbge;
  final String nome;
  final String uf;

  Municipio({
    this.idMunicipio,
    required this.codigoIbge,
    required this.nome,
    required this.uf,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      idMunicipio: json['idMunicipio'] as int? ?? json['id_municipio'] as int?,
      codigoIbge: json['codigoIbge'] as int? ?? json['codigo_ibge'] as int? ?? 0,
      nome: json['nome'] as String? ?? '',
      uf: json['uf'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idMunicipio != null) 'idMunicipio': idMunicipio,
      'codigoIbge': codigoIbge,
      'nome': nome,
      'uf': uf,
    };
  }
}
