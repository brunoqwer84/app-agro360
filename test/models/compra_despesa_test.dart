import 'package:flutter_test/flutter_test.dart';
import 'package:agro360/models/compra_despesa.dart';

void main() {
  group('CompraDespesa Model Tests', () {
    test('Deve serializar e deserializar CompraDespesa com sucesso via fromJson e toJson', () {
      final json = {
        'idCompraDespesa': 10,
        'descricao': 'Compra de Medicamentos',
        'valorTotal': 350.50,
        'dataCompra': '2026-10-15',
        'numeroDocumento': '54321',
        'chaveAcesso': '35230900000000000000550010000123451000123456',
        'tipoDocumento': 'NFE',
        'anexoImagemUrl': 'uploads/notas/anexo123.jpg',
        'formaPagamento': 'Boleto',
        'status': 'CONCLUIDA',
        'observacao': 'Obs teste',
        'idFornecedor': 2,
        'nomeFornecedor': 'Vet Distribuidora',
        'cpfCnpjFornecedor': '12.345.678/0001-99',
        'idPropriedade': 5,
        'nomePropriedade': 'Fazenda Modelo',
        'idCategoria': 7,
        'nomeCategoria': 'Saúde Animal',
        'idLancamento': 99,
        'statusLancamento': 'PENDENTE',
        'dataVencimentoLancamento': '2026-11-15',
        'temLancamentoFinanceiro': true,
        'itens': [
          {'descricao': 'Vacina Aftosa', 'quantidade': 10, 'valorUnitario': 35.05, 'valorTotal': 350.50}
        ],
        'parcelas': [
          {'numeroParcela': 1, 'dataVencimento': '2026-11-15', 'valor': 350.50}
        ],
      };

      final model = CompraDespesa.fromJson(json);

      expect(model.idCompraDespesa, 10);
      expect(model.descricao, 'Compra de Medicamentos');
      expect(model.valorTotal, 350.50);
      expect(model.dataCompra, DateTime(2026, 10, 15));
      expect(model.chaveAcesso, '35230900000000000000550010000123451000123456');
      expect(model.tipoDocumento, 'NFE');
      expect(model.anexoImagemUrl, 'uploads/notas/anexo123.jpg');
      expect(model.isConcluida, true);
      expect(model.isPendente, false);
      expect(model.isCancelada, false);
      expect(model.temLancamentoFinanceiro, true);
      expect(model.isPendenteNoFinanceiro, true);
      expect(model.isPagoNoFinanceiro, false);
      expect(model.itens?.length, 1);
      expect(model.parcelas?.length, 1);

      final convertedJson = model.toJson();
      expect(convertedJson['idCompraDespesa'], 10);
      expect(convertedJson['descricao'], 'Compra de Medicamentos');
      expect(convertedJson['valorTotal'], 350.50);
      expect(convertedJson['dataCompra'], '2026-10-15');
      expect(convertedJson['chaveAcesso'], '35230900000000000000550010000123451000123456');
      expect(convertedJson['tipoDocumento'], 'NFE');
      expect(convertedJson['anexoImagemUrl'], 'uploads/notas/anexo123.jpg');
    });

    test('Deve identificar status de pagamento do financeiro corretamente', () {
      final pago = CompraDespesa(
        idCompraDespesa: 1,
        descricao: 'Teste',
        valorTotal: 100.0,
        dataCompra: DateTime.now(),
        status: 'CONCLUIDA',
        idFornecedor: 1,
        idPropriedade: 1,
        statusLancamento: 'PAGO',
        temLancamentoFinanceiro: true,
      );

      expect(pago.isPagoNoFinanceiro, true);
      expect(pago.isPendenteNoFinanceiro, false);
    });
  });
}
