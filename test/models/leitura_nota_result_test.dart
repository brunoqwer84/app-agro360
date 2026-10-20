import 'package:flutter_test/flutter_test.dart';
import 'package:agro360/models/leitura_nota_result.dart';

void main() {
  group('LeituraNotaResult & Submodels Tests', () {
    test('Deve serializar e deserializar ItemNotaModel', () {
      final item = ItemNotaModel(
        idItem: 1,
        descricao: 'Sal Mineral 25kg',
        quantidade: 4,
        valorUnitario: 80.0,
        valorTotal: 320.0,
      );

      final json = item.toJson();
      expect(json['idItem'], 1);
      expect(json['descricao'], 'Sal Mineral 25kg');
      expect(json['quantidade'], 4.0);
      expect(json['valorUnitario'], 80.0);
      expect(json['valorTotal'], 320.0);

      final fromJson = ItemNotaModel.fromJson(json);
      expect(fromJson.descricao, 'Sal Mineral 25kg');
      expect(fromJson.valorTotal, 320.0);
    });

    test('Deve serializar e deserializar ParcelaNotaModel', () {
      final parcela = ParcelaNotaModel(
        idParcela: 1,
        numeroParcela: 2,
        dataVencimento: DateTime(2026, 11, 20),
        valor: 160.0,
      );

      final json = parcela.toJson();
      expect(json['idParcela'], 1);
      expect(json['numeroParcela'], 2);
      expect(json['dataVencimento'], '2026-11-20');
      expect(json['valor'], 160.0);

      final fromJson = ParcelaNotaModel.fromJson(json);
      expect(fromJson.numeroParcela, 2);
      expect(fromJson.dataVencimento, DateTime(2026, 11, 20));
      expect(fromJson.valor, 160.0);
    });

    test('Deve deserializar LeituraNotaResult e calcular flags temDuplicidade e temAvisos', () {
      final json = {
        'tipoDocumento': 'NFE',
        'fornecedor': 'Agropecuária Central',
        'cnpj': '12345678000199',
        'numero': '1234',
        'chaveAcesso': '35230900000000000000550010000123451000123456',
        'dataEmissao': '2026-10-10',
        'total': 500.0,
        'categoriaSugerida': 'Insumos',
        'idCategoriaSugerida': 3,
        'itens': [
          {'descricao': 'Item 1', 'quantidade': 1, 'valorUnitario': 500.0, 'valorTotal': 500.0}
        ],
        'vencimentos': [
          {'numeroParcela': 1, 'dataVencimento': '2026-11-10', 'valor': 500.0}
        ],
        'confianca': {'fornecedor': 0.95, 'total': 0.98},
        'avisos': ['Aviso teste'],
        'idDespesaDuplicada': 45,
        'anexoTempPath': 'temp_nota_123.jpg',
      };

      final res = LeituraNotaResult.fromJson(json);

      expect(res.tipoDocumento, 'NFE');
      expect(res.fornecedor, 'Agropecuária Central');
      expect(res.total, 500.0);
      expect(res.itens.length, 1);
      expect(res.vencimentos.length, 1);
      expect(res.temAvisos, true);
      expect(res.temDuplicidade, true);
      expect(res.idDespesaDuplicada, 45);
      expect(res.anexoTempPath, 'temp_nota_123.jpg');
    });

    test('Deve tratar campos vazios em LeituraNotaResult', () {
      final res = LeituraNotaResult.fromJson({});
      expect(res.temAvisos, false);
      expect(res.temDuplicidade, false);
      expect(res.itens, isEmpty);
      expect(res.vencimentos, isEmpty);
    });
  });
}
