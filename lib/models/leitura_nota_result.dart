class ItemNotaModel {
  int? idItem;
  String descricao;
  double quantidade;
  double valorUnitario;
  double valorTotal;

  ItemNotaModel({
    this.idItem,
    required this.descricao,
    this.quantidade = 1.0,
    this.valorUnitario = 0.0,
    this.valorTotal = 0.0,
  });

  factory ItemNotaModel.fromJson(Map<String, dynamic> json) {
    return ItemNotaModel(
      idItem: json['idItem'] as int?,
      descricao: json['descricao'] as String? ?? '',
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 1.0,
      valorUnitario: (json['valorUnitario'] as num?)?.toDouble() ?? 0.0,
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idItem != null) 'idItem': idItem,
      'descricao': descricao,
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
    };
  }
}

class ParcelaNotaModel {
  int? idParcela;
  int numeroParcela;
  DateTime? dataVencimento;
  double valor;
  int? idLancamento;

  ParcelaNotaModel({
    this.idParcela,
    this.numeroParcela = 1,
    this.dataVencimento,
    this.valor = 0.0,
    this.idLancamento,
  });

  factory ParcelaNotaModel.fromJson(Map<String, dynamic> json) {
    return ParcelaNotaModel(
      idParcela: json['idParcela'] as int?,
      numeroParcela: json['numeroParcela'] as int? ?? 1,
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.tryParse(json['dataVencimento'].toString())
          : null,
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      idLancamento: json['idLancamento'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idParcela != null) 'idParcela': idParcela,
      'numeroParcela': numeroParcela,
      if (dataVencimento != null)
        'dataVencimento': dataVencimento!.toIso8601String().split('T')[0],
      'valor': valor,
      if (idLancamento != null) 'idLancamento': idLancamento,
    };
  }
}

class LeituraNotaResult {
  final String? tipoDocumento;
  final String? fornecedor;
  final String? cnpj;
  final String? numero;
  final String? chaveAcesso;
  final DateTime? dataEmissao;
  final double? total;
  final String? categoriaSugerida;
  final int? idCategoriaSugerida;
  final List<ItemNotaModel> itens;
  final List<ParcelaNotaModel> vencimentos;
  final Map<String, dynamic>? confianca;
  final List<String> avisos;
  final int? idDespesaDuplicada;
  final String? anexoTempPath;

  LeituraNotaResult({
    this.tipoDocumento,
    this.fornecedor,
    this.cnpj,
    this.numero,
    this.chaveAcesso,
    this.dataEmissao,
    this.total,
    this.categoriaSugerida,
    this.idCategoriaSugerida,
    this.itens = const [],
    this.vencimentos = const [],
    this.confianca,
    this.avisos = const [],
    this.idDespesaDuplicada,
    this.anexoTempPath,
  });

  bool get temDuplicidade => idDespesaDuplicada != null;
  bool get temAvisos => avisos.isNotEmpty;

  factory LeituraNotaResult.fromJson(Map<String, dynamic> json) {
    return LeituraNotaResult(
      tipoDocumento: json['tipoDocumento'] as String?,
      fornecedor: json['fornecedor'] as String?,
      cnpj: json['cnpj'] as String?,
      numero: json['numero'] as String?,
      chaveAcesso: json['chaveAcesso'] as String?,
      dataEmissao: json['dataEmissao'] != null
          ? DateTime.tryParse(json['dataEmissao'].toString())
          : null,
      total: (json['total'] as num?)?.toDouble(),
      categoriaSugerida: json['categoriaSugerida'] as String?,
      idCategoriaSugerida: json['idCategoriaSugerida'] as int?,
      itens: (json['itens'] as List<dynamic>?)
              ?.map((e) => ItemNotaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vencimentos: (json['vencimentos'] as List<dynamic>?)
              ?.map((e) => ParcelaNotaModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confianca: json['confianca'] as Map<String, dynamic>?,
      avisos: (json['avisos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      idDespesaDuplicada: json['idDespesaDuplicada'] as int?,
      anexoTempPath: json['anexoTempPath'] as String?,
    );
  }
}
