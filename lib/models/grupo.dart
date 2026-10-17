/// Model de Grupo/Empresa
/// Corresponde à entidade Grupo do backend
class Grupo {
  final int idGrupo;
  final String nome;
  final String? cnpj;
  final bool ativo;

  Grupo({
    required this.idGrupo,
    required this.nome,
    this.cnpj,
    required this.ativo,
  });

  /// Cria instância a partir de JSON da API
  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      idGrupo: (json['idGrupo'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      cnpj: json['cnpj'] as String?,
      ativo: json['ativo'] as bool? ?? false,
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cnpj': cnpj,
      'ativo': ativo,
    };
  }
}
