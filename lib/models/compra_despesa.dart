/// Model de Compra / Despesa
/// Vinculado a um fornecedor, propriedade e opcionalmente a uma categoria e lançamento a pagar no financeiro.
class CompraDespesa {
  final int idCompraDespesa;
  final String descricao;
  final double valorTotal;
  final DateTime dataCompra;
  final String? numeroDocumento;
  final String? chaveAcesso;
  final String? tipoDocumento;
  final String? anexoImagemUrl;
  final String? formaPagamento;
  final String status; // CONCLUIDA, PENDENTE, CANCELADA
  final String? observacao;

  final List<dynamic>? itens;
  final List<dynamic>? parcelas;

  final int idFornecedor;
  final String? nomeFornecedor;
  final String? cpfCnpjFornecedor;

  final int idPropriedade;
  final String? nomePropriedade;

  final int? idCategoria;
  final String? nomeCategoria;

  final int? idLancamento;
  final String? statusLancamento;
  final DateTime? dataVencimentoLancamento;
  final DateTime? dataPagamentoLancamento;
  final bool temLancamentoFinanceiro;

  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  CompraDespesa({
    required this.idCompraDespesa,
    required this.descricao,
    required this.valorTotal,
    required this.dataCompra,
    this.numeroDocumento,
    this.chaveAcesso,
    this.tipoDocumento,
    this.anexoImagemUrl,
    this.formaPagamento,
    required this.status,
    this.observacao,
    this.itens,
    this.parcelas,
    required this.idFornecedor,
    this.nomeFornecedor,
    this.cpfCnpjFornecedor,
    required this.idPropriedade,
    this.nomePropriedade,
    this.idCategoria,
    this.nomeCategoria,
    this.idLancamento,
    this.statusLancamento,
    this.dataVencimentoLancamento,
    this.dataPagamentoLancamento,
    this.temLancamentoFinanceiro = false,
    this.criadoEm,
    this.atualizadoEm,
  });

  bool get isConcluida => status.toUpperCase() == 'CONCLUIDA';
  bool get isPendente => status.toUpperCase() == 'PENDENTE';
  bool get isCancelada => status.toUpperCase() == 'CANCELADA';

  bool get isPagoNoFinanceiro =>
      statusLancamento != null && statusLancamento!.toUpperCase() == 'PAGO';

  bool get isPendenteNoFinanceiro =>
      statusLancamento != null && statusLancamento!.toUpperCase() == 'PENDENTE';

  factory CompraDespesa.fromJson(Map<String, dynamic> json) {
    return CompraDespesa(
      idCompraDespesa: json['idCompraDespesa'] as int? ?? 0,
      descricao: json['descricao'] as String? ?? '',
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      dataCompra: json['dataCompra'] != null
          ? DateTime.parse(json['dataCompra'].toString())
          : DateTime.now(),
      numeroDocumento: json['numeroDocumento'] as String?,
      chaveAcesso: json['chaveAcesso'] as String?,
      tipoDocumento: json['tipoDocumento'] as String?,
      anexoImagemUrl: json['anexoImagemUrl'] as String?,
      formaPagamento: json['formaPagamento'] as String?,
      status: json['status'] as String? ?? 'CONCLUIDA',
      observacao: json['observacao'] as String?,
      itens: json['itens'] as List<dynamic>?,
      parcelas: json['parcelas'] as List<dynamic>?,
      idFornecedor: json['idFornecedor'] as int? ?? 0,
      nomeFornecedor: json['nomeFornecedor'] as String?,
      cpfCnpjFornecedor: json['cpfCnpjFornecedor'] as String?,
      idPropriedade: json['idPropriedade'] as int? ?? 0,
      nomePropriedade: json['nomePropriedade'] as String?,
      idCategoria: json['idCategoria'] as int?,
      nomeCategoria: json['nomeCategoria'] as String?,
      idLancamento: json['idLancamento'] as int?,
      statusLancamento: json['statusLancamento'] as String?,
      dataVencimentoLancamento: json['dataVencimentoLancamento'] != null
          ? DateTime.parse(json['dataVencimentoLancamento'].toString())
          : null,
      dataPagamentoLancamento: json['dataPagamentoLancamento'] != null
          ? DateTime.parse(json['dataPagamentoLancamento'].toString())
          : null,
      temLancamentoFinanceiro:
          json['temLancamentoFinanceiro'] as bool? ?? (json['idLancamento'] != null),
      criadoEm: json['criadoEm'] != null
          ? DateTime.tryParse(json['criadoEm'].toString())
          : null,
      atualizadoEm: json['atualizadoEm'] != null
          ? DateTime.tryParse(json['atualizadoEm'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCompraDespesa': idCompraDespesa,
      'descricao': descricao,
      'valorTotal': valorTotal,
      'dataCompra': dataCompra.toIso8601String().split('T')[0],
      if (numeroDocumento != null) 'numeroDocumento': numeroDocumento,
      if (chaveAcesso != null) 'chaveAcesso': chaveAcesso,
      if (tipoDocumento != null) 'tipoDocumento': tipoDocumento,
      if (anexoImagemUrl != null) 'anexoImagemUrl': anexoImagemUrl,
      if (formaPagamento != null) 'formaPagamento': formaPagamento,
      'status': status,
      if (observacao != null) 'observacao': observacao,
      if (itens != null) 'itens': itens,
      if (parcelas != null) 'parcelas': parcelas,
      'idFornecedor': idFornecedor,
      'idPropriedade': idPropriedade,
      if (idCategoria != null) 'idCategoria': idCategoria,
      if (idLancamento != null) 'idLancamento': idLancamento,
    };
  }
}
