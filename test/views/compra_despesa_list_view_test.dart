import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:agro360/models/categoria_financeira.dart';
import 'package:agro360/models/compra_despesa.dart';
import 'package:agro360/models/pessoa.dart';
import 'package:agro360/models/propriedade.dart';
import 'package:agro360/services/api_service.dart';
import 'package:agro360/views/compra_despesa_list_view.dart';
import 'package:agro360/theme/app_theme.dart';
import 'package:agro360/utils/app_colors.dart';

class MockApiForListTest extends GetxService implements ApiService {
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
  Future<List<Pessoa>> getFornecedoresAtivos() async => [];

  @override
  Future<List<Propriedade>> getPropriedadesAtivas() async => [];

  @override
  Future<List<CategoriaFinanceira>> getAllCategoriasFinanceiras(
          {String? tipo, bool? apenasAtivos}) async =>
      [];
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.put<ApiService>(MockApiForListTest());
  });

  testWidgets('Deve exibir tela de listagem de compras com botões Ler NF e Nova Despesa',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeData = ThemeData.light(useMaterial3: true).copyWith(
      extensions: const [
        AppColorScheme.light,
        AppTextTheme.light,
      ],
      scaffoldBackgroundColor: AppColors.background,
    );

    await tester.pumpWidget(GetMaterialApp(
      theme: themeData,
      home: const CompraDespesaListView(),
    ));
    await tester.pumpAndSettle();

    // 1. Verifica AppBar
    expect(find.text('Compras & Despesas'), findsOneWidget);

    // 2. Verifica botões de ação Ler NF e Nova Despesa
    expect(find.text('Ler NF'), findsOneWidget);
    expect(find.text('Nova Despesa'), findsOneWidget);

    // 3. Verifica estado vazio inicial
    expect(find.text('Nenhuma compra ou despesa'), findsOneWidget);

    // 4. Clica em Ler NF e verifica se abre bottom sheet
    await tester.tap(find.text('Ler NF'));
    await tester.pumpAndSettle();

    expect(find.text('Lançar Despesa por Foto da NF'), findsOneWidget);
    expect(find.text('Tirar foto com a Câmera'), findsOneWidget);
    expect(find.text('Escolher da Galeria'), findsOneWidget);
  });
}
