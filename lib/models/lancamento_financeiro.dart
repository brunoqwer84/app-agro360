/// Model de Lançamento Financeiro (Contas a Pagar / Contas a Receber)
/// tipo: 'P' para despesas / a pagar, 'R' para receitas / a receber
class LancamentoFinanceiro {
  final int idLancamento;
  final String tipo; // 'P' ou 'R' (ou DESPESA / RECEITA)
  final String descricao;
  final double valor;
  final DateTime dataVencimento;
  final DateTime? dataPagamento;
  final String status; // PENDENTE, PAGO, CANCELADO
  final int? idCategoria;
  final String? nomeCategoria;
  final String? categoria;
  final String? formaPagamento;
  final String? observacao;
  final int? idManejo;
  final String? resumoManejo;
  final int? idPropriedade;
  final String? nomePropriedade;
  final int? idPessoa;
  final String? nomePessoa;
  final DateTime? criadoEm;

  LancamentoFinanceiro({
    required this.idLancamento,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.dataVencimento,
    this.dataPagamento,
    required this.status,
    this.idCategoria,
    this.nomeCategoria,
    this.categoria,
    this.formaPagamento,
    this.observacao,
    this.idManejo,
    this.resumoManejo,
    this.idPropriedade,
    this.nomePropriedade,
    this.idPessoa,
    this.nomePessoa,
    this.criadoEm,
  });

  bool get isReceita =>
      tipo.toUpperCase() == 'R' ||
      tipo.toUpperCase() == 'RECEITA' ||
      tipo.toUpperCase() == 'RECEBER';

  bool get isDespesa =>
      tipo.toUpperCase() == 'P' ||
      tipo.toUpperCase() == 'DESPESA' ||
      tipo.toUpperCase() == 'PAGAR';

  bool get isPago => status.toUpperCase() == 'PAGO';

  bool get isPendente => status.toUpperCase() == 'PENDENTE';

  bool get isCancelado => status.toUpperCase() == 'CANCELADO';

  bool get isVencido {
    if (!isPendente) return false;
    final hoje = DateTime.now();
    final hojeSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final vencSemHora = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
    );
    return vencSemHora.isBefore(hojeSemHora);
  }

  factory LancamentoFinanceiro.fromJson(Map<String, dynamic> json) {
    return LancamentoFinanceiro(
      idLancamento: (json['idLancamento'] as num).toInt(),
      tipo: json['tipo'] as String? ?? 'P',
      descricao: json['descricao'] as String? ?? '',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'] as String)
          : DateTime.now(),
      dataPagamento: json['dataPagamento'] != null
          ? DateTime.parse(json['dataPagamento'] as String)
          : null,
      status: json['status'] as String? ?? 'PENDENTE',
      idCategoria: (json['idCategoria'] as num?)?.toInt(),
      nomeCategoria: json['nomeCategoria'] as String? ?? json['categoria'] as String?,
      categoria: json['categoria'] as String? ?? json['nomeCategoria'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      observacao: json['observacao'] as String?,
      idManejo: json['idManejo'] != null
          ? (json['idManejo'] as num).toInt()
          : null,
      resumoManejo: json['resumoManejo'] as String?,
      idPropriedade: json['idPropriedade'] != null
          ? (json['idPropriedade'] as num).toInt()
          : null,
      nomePropriedade: json['nomePropriedade'] as String?,
      idPessoa: json['idPessoa'] != null
          ? (json['idPessoa'] as num).toInt()
          : null,
      nomePessoa: json['nomePessoa'] as String?,
      criadoEm: json['criadoEm'] != null
          ? DateTime.tryParse(json['criadoEm'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    String formatData(DateTime dt) =>
        '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

    return {
      'tipo': isReceita ? 'R' : 'P',
      'descricao': descricao,
      'valor': valor,
      'dataVencimento': formatData(dataVencimento),
      if (dataPagamento != null) 'dataPagamento': formatData(dataPagamento!),
      'status': status,
      if (idCategoria != null) 'idCategoria': idCategoria,
      if (nomeCategoria != null && nomeCategoria!.isNotEmpty)
        'categoria': nomeCategoria
      else if (categoria != null && categoria!.isNotEmpty)
        'categoria': categoria,
      if (formaPagamento != null && formaPagamento!.isNotEmpty)
        'formaPagamento': formaPagamento,
      if (observacao != null && observacao!.isNotEmpty)
        'observacao': observacao,
      if (idManejo != null) 'idManejo': idManejo,
      if (idPropriedade != null) 'idPropriedade': idPropriedade,
      if (idPessoa != null) 'idPessoa': idPessoa,
    };
  }

  LancamentoFinanceiro copyWith({
    int? idLancamento,
    String? tipo,
    String? descricao,
    double? valor,
    DateTime? dataVencimento,
    DateTime? dataPagamento,
    String? status,
    int? idCategoria,
    String? nomeCategoria,
    String? categoria,
    String? formaPagamento,
    String? observacao,
    int? idManejo,
    String? resumoManejo,
    int? idPropriedade,
    String? nomePropriedade,
    int? idPessoa,
    String? nomePessoa,
    DateTime? criadoEm,
  }) {
    return LancamentoFinanceiro(
      idLancamento: idLancamento ?? this.idLancamento,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      dataPagamento: dataPagamento ?? this.dataPagamento,
      status: status ?? this.status,
      idCategoria: idCategoria ?? this.idCategoria,
      nomeCategoria: nomeCategoria ?? this.nomeCategoria,
      categoria: categoria ?? this.categoria,
      formaPagamento: formaPagamento ?? this.formaPagamento,
      observacao: observacao ?? this.observacao,
      idManejo: idManejo ?? this.idManejo,
      resumoManejo: resumoManejo ?? this.resumoManejo,
      idPropriedade: idPropriedade ?? this.idPropriedade,
      nomePropriedade: nomePropriedade ?? this.nomePropriedade,
      idPessoa: idPessoa ?? this.idPessoa,
      nomePessoa: nomePessoa ?? this.nomePessoa,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
