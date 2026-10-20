import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agro360/models/categoria_financeira.dart';
import 'package:agro360/models/compra_despesa.dart';
import 'package:agro360/models/leitura_nota_result.dart';
import 'package:agro360/models/pessoa.dart';
import 'package:agro360/models/propriedade.dart';
import 'package:agro360/services/api_service.dart';
import 'package:agro360/views/compra_despesa_revisao_view.dart';
import 'package:agro360/theme/app_theme.dart';
import 'package:agro360/utils/app_colors.dart';

// Mock minimal do ApiService para o teste de widget
class MockApiService extends GetxService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<List<CompraDespesa>> getComprasDespesas({
    int? idFornecedor,
    int? idPropriedade,
    int? idCategoria,
    String? status,
    DateTime? inicio,
    DateTime? fim,
  }) async =>
      [];

  @override
  Future<List<Pessoa>> getFornecedoresAtivos() async => [
        Pessoa(
          idPessoa: 10,
          nome: 'Agropecuária Central',
          cpfCnpj: '12.345.678/0001-99',
          ativo: true,
          tipo: 'F',
        ),
      ];

  @override
  Future<List<Propriedade>> getPropriedadesAtivas() async => [
        Propriedade(
          idPropriedade: 1,
          nome: 'Fazenda Santa Maria',
          ativo: true,
        ),
      ];

  @override
  Future<List<CategoriaFinanceira>> getAllCategoriasFinanceiras(
          {String? tipo, bool? apenasAtivos}) async =>
      [];
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<ApiService>(MockApiService());
  });

  testWidgets('Deve exibir tela de revisão com dados preenchidos da nota fiscal',
      (WidgetTester tester) async {
    // Configura tela grande para evitar corte de rolagem no teste
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final leitura = LeituraNotaResult(
      tipoDocumento: 'NFE',
      fornecedor: 'Agropecuária Central',
      cnpj: '12.345.678/0001-99',
      numero: '9876',
      chaveAcesso: '35230900000000000000550010000123451000123456',
      total: 450.75,
      dataEmissao: DateTime(2026, 10, 15),
      itens: [
        ItemNotaModel(
          descricao: 'Ração Concentrada 40kg',
          quantidade: 3,
          valorUnitario: 150.25,
          valorTotal: 450.75,
        ),
      ],
      vencimentos: [
        ParcelaNotaModel(
          numeroParcela: 1,
          dataVencimento: DateTime(2026, 11, 15),
          valor: 450.75,
        ),
      ],
      avisos: [
        'A soma dos itens confere com o total.',
      ],
      idDespesaDuplicada: 123, // Simula duplicidade para testar banner
    );

    final themeData = ThemeData.light(useMaterial3: true).copyWith(
      extensions: const [
        AppColorScheme.light,
        AppTextTheme.light,
      ],
      scaffoldBackgroundColor: AppColors.background,
    );

    final testApp = GetMaterialApp(
      theme: themeData,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const Scaffold(body: Text('Home')),
        ),
        GetPage(
          name: '/revisao',
          page: () => const CompraDespesaRevisaoView(),
        ),
      ],
    );

    await tester.pumpWidget(testApp);
    await tester.pumpAndSettle();

    Get.toNamed('/revisao', arguments: {
      'leitura': leitura,
      'imageFile': null,
    });
    await tester.pumpAndSettle();

    // 1. Verifica AppBar
    expect(find.text('Revisão da Nota Fiscal'), findsOneWidget);

    // 2. Verifica Banner de duplicidade
    expect(find.text('Possível Despesa Duplicada'), findsOneWidget);
    expect(find.text('Lançar mesmo assim'), findsOneWidget);

    // 3. Verifica Banner de avisos da IA
    expect(find.text('Avisos de Conferência da Nota'), findsOneWidget);

    // 4. Verifica Valor total preenchido
    expect(find.text('450.75'), findsOneWidget);

    // 5. Verifica Itens da nota discriminados
    expect(find.text('Ração Concentrada 40kg'), findsOneWidget);

    // 6. Verifica Botões de Ação
    expect(find.text('Confirmar e Salvar Despesa'), findsOneWidget);
    expect(find.text('Descartar'), findsWidgets);
  });
}
