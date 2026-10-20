import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agro360/controllers/compra_despesa_controller.dart';
import 'package:agro360/controllers/financeiro_controller.dart' show PeriodoExercicio;
import 'package:agro360/models/categoria_financeira.dart';
import 'package:agro360/models/compra_despesa.dart';
import 'package:agro360/models/leitura_nota_result.dart';
import 'package:agro360/models/pessoa.dart';
import 'package:agro360/models/propriedade.dart';
import 'package:agro360/services/api_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:image/image.dart' as img;

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

class MockApiServiceForController extends GetxService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  final List<CompraDespesa> mockLista = [];

  @override
  Future<List<CompraDespesa>> getComprasDespesas({
    int? idFornecedor,
    int? idPropriedade,
    int? idCategoria,
    String? status,
    DateTime? inicio,
    DateTime? fim,
  }) async =>
      mockLista;

  @override
  Future<List<Pessoa>> getFornecedoresAtivos() async => [
        Pessoa(idPessoa: 1, nome: 'Fornecedor A', cpfCnpj: '000', ativo: true, tipo: 'F'),
      ];

  @override
  Future<List<Propriedade>> getPropriedadesAtivas() async => [
        Propriedade(idPropriedade: 1, nome: 'Fazenda A', ativo: true),
      ];

  @override
  Future<List<CategoriaFinanceira>> getAllCategoriasFinanceiras({String? tipo, bool? apenasAtivos}) async => [];

  @override
  Future<CompraDespesa> createCompraDespesa(Map<String, dynamic> data) async {
    final c = CompraDespesa(
      idCompraDespesa: 101,
      descricao: data['descricao'] as String,
      valorTotal: (data['valorTotal'] as num).toDouble(),
      dataCompra: DateTime.parse(data['dataCompra'].toString()),
      status: 'CONCLUIDA',
      idFornecedor: data['idFornecedor'] as int,
      idPropriedade: data['idPropriedade'] as int,
    );
    mockLista.insert(0, c);
    return c;
  }

  @override
  Future<CompraDespesa> updateCompraDespesa(int id, Map<String, dynamic> data) async {
    final updated = CompraDespesa(
      idCompraDespesa: id,
      descricao: data['descricao'] as String,
      valorTotal: (data['valorTotal'] as num).toDouble(),
      dataCompra: DateTime.now(),
      status: 'CONCLUIDA',
      idFornecedor: 1,
      idPropriedade: 1,
    );
    final idx = mockLista.indexWhere((c) => c.idCompraDespesa == id);
    if (idx != -1) mockLista[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteCompraDespesa(int id) async {
    mockLista.removeWhere((c) => c.idCompraDespesa == id);
  }

  @override
  Future<LeituraNotaResult> lerNotaFiscal(File imageFile) async {
    return LeituraNotaResult(
      tipoDocumento: 'NFE',
      fornecedor: 'Agro Teste',
      total: 250.0,
      itens: [ItemNotaModel(descricao: 'Item 1', valorTotal: 250.0)],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockApiServiceForController mockApi;
  late CompraDespesaController controller;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    PathProviderPlatform.instance = FakePathProviderPlatform();

    mockApi = MockApiServiceForController();
    Get.put<ApiService>(mockApi);

    controller = CompraDespesaController();
  });

  group('CompraDespesaController Tests', () {
    test('Deve aplicar filtros de período corretamente', () {
      controller.aplicarPeriodo(PeriodoExercicio.dias30, reload: false);
      expect(controller.periodoSelecionado.value, PeriodoExercicio.dias30);
      expect(controller.dataInicio.value, isNotNull);
      expect(controller.dataFim.value, isNotNull);

      controller.aplicarPeriodo(PeriodoExercicio.todos, reload: false);
      expect(controller.periodoSelecionado.value, PeriodoExercicio.todos);
      expect(controller.dataInicio.value, isNull);
      expect(controller.dataFim.value, isNull);

      controller.aplicarPeriodo(
        PeriodoExercicio.customizado,
        customInicio: DateTime(2026, 1, 1),
        customFim: DateTime(2026, 1, 31),
        reload: false,
      );
      expect(controller.periodoSelecionado.value, PeriodoExercicio.customizado);
      expect(controller.dataInicio.value, DateTime(2026, 1, 1));
      expect(controller.dataFim.value, DateTime(2026, 1, 31, 23, 59, 59));
    });

    test('Deve calcular totalizadores de valores e financeiro com precisão', () {
      controller.compras.assignAll([
        CompraDespesa(
          idCompraDespesa: 1,
          descricao: 'Item 1',
          valorTotal: 100.0,
          dataCompra: DateTime.now(),
          status: 'CONCLUIDA',
          idFornecedor: 1,
          idPropriedade: 1,
          statusLancamento: 'PAGO',
          temLancamentoFinanceiro: true,
        ),
        CompraDespesa(
          idCompraDespesa: 2,
          descricao: 'Item 2',
          valorTotal: 250.0,
          dataCompra: DateTime.now(),
          status: 'CONCLUIDA',
          idFornecedor: 1,
          idPropriedade: 1,
          statusLancamento: 'PENDENTE',
          temLancamentoFinanceiro: true,
        ),
        CompraDespesa(
          idCompraDespesa: 3,
          descricao: 'Item 3',
          valorTotal: 50.0,
          dataCompra: DateTime.now(),
          status: 'CONCLUIDA',
          idFornecedor: 1,
          idPropriedade: 1,
          temLancamentoFinanceiro: false,
        ),
      ]);

      expect(controller.totalValorCompras, 400.0);
      expect(controller.totalPagoNoFinanceiro, 100.0);
      expect(controller.totalPendenteNoFinanceiro, 250.0);
      expect(controller.qtdComFinanceiro, 2);
    });

    test('Deve criar, atualizar e deletar compra despesa', () async {
      final sucessoCriar = await controller.criar({
        'descricao': 'Nova Compra',
        'valorTotal': 300.0,
        'dataCompra': '2026-10-15',
        'idFornecedor': 1,
        'idPropriedade': 1,
      });

      expect(sucessoCriar, true);
      expect(controller.compras.length, 1);
      expect(controller.compras.first.descricao, 'Nova Compra');

      final sucessoAtualizar = await controller.atualizar(101, {
        'descricao': 'Compra Alterada',
        'valorTotal': 350.0,
      });

      expect(sucessoAtualizar, true);
      expect(controller.compras.first.descricao, 'Compra Alterada');

      final sucessoDeletar = await controller.deletar(101);
      expect(sucessoDeletar, true);
      expect(controller.compras.isEmpty, true);
    });

    test('Deve processar foto da nota comprimindo e chamando apiService', () async {
      final imgOriginal = img.Image(width: 500, height: 500);
      img.fill(imgOriginal, color: img.ColorRgb8(10, 50, 10));
      final fileTemp = File('${Directory.systemTemp.path}/test_ocr_controller.png');
      await fileTemp.writeAsBytes(img.encodePng(imgOriginal));

      final resultado = await controller.processarFotoNota(fileTemp);

      expect(resultado, isNotNull);
      expect(resultado!['leitura'], isA<LeituraNotaResult>());
      final LeituraNotaResult leitura = resultado['leitura'] as LeituraNotaResult;
      expect(leitura.tipoDocumento, 'NFE');
      expect(leitura.total, 250.0);
      expect(resultado['imageFile'], isA<File>());

      if (fileTemp.existsSync()) fileTemp.deleteSync();
      final File comp = resultado['imageFile'] as File;
      if (comp.existsSync()) comp.deleteSync();
    });
  });
}
