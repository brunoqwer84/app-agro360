/// Model de Categoria Financeira
/// tipo: 'P' para despesas (contas a pagar), 'R' para receitas (contas a receber)
class CategoriaFinanceira {
  final int idCategoria;
  final String nome;
  final String tipo; // 'P' ou 'R'
  final String? descricao;
  final bool ativo;
  final DateTime? criadoEm;

  CategoriaFinanceira({
    required this.idCategoria,
    required this.nome,
    required this.tipo,
    this.descricao,
    this.ativo = true,
    this.criadoEm,
  });

  bool get isDespesa =>
      tipo.toUpperCase() == 'P' ||
      tipo.toUpperCase() == 'DESPESA' ||
      tipo.toUpperCase() == 'PAGAR';

  bool get isReceita =>
      tipo.toUpperCase() == 'R' ||
      tipo.toUpperCase() == 'RECEITA' ||
      tipo.toUpperCase() == 'RECEBER';

  String get tipoDescricao => isDespesa ? 'Despesa' : 'Receita';

  factory CategoriaFinanceira.fromJson(Map<String, dynamic> json) {
    return CategoriaFinanceira(
      idCategoria: (json['idCategoria'] as num?)?.toInt() ?? 0,
      nome: json['nome'] as String? ?? '',
      tipo: (json['tipo'] as String?)?.toUpperCase() ?? 'P',
      descricao: json['descricao'] as String?,
      ativo: json['ativo'] as bool? ?? true,
      criadoEm: json['criadoEm'] != null
          ? DateTime.tryParse(json['criadoEm'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idCategoria > 0) 'idCategoria': idCategoria,
      'nome': nome,
      'tipo': isReceita ? 'R' : 'P',
      if (descricao != null) 'descricao': descricao,
      'ativo': ativo,
    };
  }

  CategoriaFinanceira copyWith({
    int? idCategoria,
    String? nome,
    String? tipo,
    String? descricao,
    bool? ativo,
    DateTime? criadoEm,
  }) {
    return CategoriaFinanceira(
      idCategoria: idCategoria ?? this.idCategoria,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
