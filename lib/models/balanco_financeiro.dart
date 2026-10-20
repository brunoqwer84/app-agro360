import 'lancamento_financeiro.dart';

/// Model do Balanço Financeiro consolidado por período
class BalancoFinanceiro {
  final double totalReceitas;
  final double totalDespesas;
  final double saldo;

  final double totalReceitasPagas;
  final double totalReceitasPendentes;
  final double totalDespesasPagas;
  final double totalDespesasPendentes;

  final int totalLancamentos;
  final int totalReceitasQtd;
  final int totalDespesasQtd;

  final DateTime? dataInicio;
  final DateTime? dataFim;

  final Map<String, double> despesasPorCategoria;
  final Map<String, double> receitasPorCategoria;

  final List<LancamentoFinanceiro> lancamentos;

  BalancoFinanceiro({
    required this.totalReceitas,
    required this.totalDespesas,
    required this.saldo,
    required this.totalReceitasPagas,
    required this.totalReceitasPendentes,
    required this.totalDespesasPagas,
    required this.totalDespesasPendentes,
    required this.totalLancamentos,
    required this.totalReceitasQtd,
    required this.totalDespesasQtd,
    this.dataInicio,
    this.dataFim,
    required this.despesasPorCategoria,
    required this.receitasPorCategoria,
    required this.lancamentos,
  });

  bool get isPositivo => saldo >= 0;

  factory BalancoFinanceiro.fromJson(Map<String, dynamic> json) {
    Map<String, double> parseMap(dynamic mapObj) {
      if (mapObj is! Map) return {};
      return mapObj.map(
        (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
      );
    }

    return BalancoFinanceiro(
      totalReceitas: (json['totalReceitas'] as num?)?.toDouble() ?? 0.0,
      totalDespesas: (json['totalDespesas'] as num?)?.toDouble() ?? 0.0,
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      totalReceitasPagas:
          (json['totalReceitasPagas'] as num?)?.toDouble() ?? 0.0,
      totalReceitasPendentes:
          (json['totalReceitasPendentes'] as num?)?.toDouble() ?? 0.0,
      totalDespesasPagas:
          (json['totalDespesasPagas'] as num?)?.toDouble() ?? 0.0,
      totalDespesasPendentes:
          (json['totalDespesasPendentes'] as num?)?.toDouble() ?? 0.0,
      totalLancamentos: (json['totalLancamentos'] as num?)?.toInt() ?? 0,
      totalReceitasQtd: (json['totalReceitasQtd'] as num?)?.toInt() ?? 0,
      totalDespesasQtd: (json['totalDespesasQtd'] as num?)?.toInt() ?? 0,
      dataInicio: json['dataInicio'] != null
          ? DateTime.tryParse(json['dataInicio'] as String)
          : null,
      dataFim: json['dataFim'] != null
          ? DateTime.tryParse(json['dataFim'] as String)
          : null,
      despesasPorCategoria: parseMap(json['despesasPorCategoria']),
      receitasPorCategoria: parseMap(json['receitasPorCategoria']),
      lancamentos: (json['lancamentos'] as List<dynamic>?)
              ?.map((item) =>
                  LancamentoFinanceiro.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
