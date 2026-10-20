import 'dart:io';
import 'package:get/get.dart';
import '../models/compra_despesa.dart';
import '../models/pessoa.dart';
import '../models/propriedade.dart';
import '../models/categoria_financeira.dart';
import '../services/api_service.dart';
import '../services/image_compression_service.dart';
import '../utils/error_messages.dart';
import 'financeiro_controller.dart' show PeriodoExercicio;

/// Controller para gestão de Compras e Despesas
class CompraDespesaController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isReadingOcr = false.obs;

  // Lista de compras e despesas
  final compras = <CompraDespesa>[].obs;
  final selectedCompra = Rxn<CompraDespesa>();

  // Entidades auxiliares
  final fornecedores = <Pessoa>[].obs;
  final propriedades = <Propriedade>[].obs;
  final categorias = <CategoriaFinanceira>[].obs;

  // Filtros ativos
  final periodoSelecionado = PeriodoExercicio.dias30.obs;
  final dataInicio = Rxn<DateTime>();
  final dataFim = Rxn<DateTime>();
  final fornecedorFiltro = Rxn<int>();
  final propriedadeFiltro = Rxn<int>();
  final statusFiltro = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    aplicarPeriodo(PeriodoExercicio.dias30, reload: false);
    loadAll();
    loadAuxiliares();
  }

  /// Define o período do filtro e recarrega
  void aplicarPeriodo(PeriodoExercicio periodo,
      {DateTime? customInicio, DateTime? customFim, bool reload = true}) {
    periodoSelecionado.value = periodo;
    final now = DateTime.now();

    switch (periodo) {
      case PeriodoExercicio.dias30:
        dataFim.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        dataInicio.value = now.subtract(const Duration(days: 30));
        break;
      case PeriodoExercicio.dias60:
        dataFim.value = DateTime(now.year, now.month, now.day, 23, 59, 59);
        dataInicio.value = now.subtract(const Duration(days: 60));
        break;
      case PeriodoExercicio.anual:
        dataInicio.value = DateTime(now.year, 1, 1);
        dataFim.value = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case PeriodoExercicio.todos:
        dataInicio.value = null;
        dataFim.value = null;
        break;
      case PeriodoExercicio.customizado:
        if (customInicio != null && customFim != null) {
          dataInicio.value =
              DateTime(customInicio.year, customInicio.month, customInicio.day);
          dataFim.value = DateTime(
              customFim.year, customFim.month, customFim.day, 23, 59, 59);
        }
        break;
    }

    if (reload) {
      loadAll();
    }
  }

  /// Carrega as compras/despesas conforme os filtros
  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final lista = await _apiService.getComprasDespesas(
        idFornecedor: fornecedorFiltro.value,
        idPropriedade: propriedadeFiltro.value,
        status: statusFiltro.value,
        inicio: dataInicio.value,
        fim: dataFim.value,
      );
      compras.assignAll(lista);
    } catch (e) {
      _mostrarNotificacao('Erro', AppError.getErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega dados auxiliares (fornecedores, propriedades, categorias de despesa)
  Future<void> loadAuxiliares() async {
    try {
      final results = await Future.wait([
        _apiService.getFornecedoresAtivos(),
        _apiService.getPropriedadesAtivas(),
        _apiService.getAllCategoriasFinanceiras(tipo: 'P', apenasAtivos: true),
      ]);

      fornecedores.assignAll(results[0] as List<Pessoa>);
      propriedades.assignAll(results[1] as List<Propriedade>);
      categorias.assignAll(results[2] as List<CategoriaFinanceira>);
    } catch (e) {
      // Ignora erro silencioso no carregamento auxiliar inicial
    }
  }

  /// Totalizador geral do valor de compras/despesas
  double get totalValorCompras =>
      compras.fold(0.0, (acc, item) => acc + item.valorTotal);

  /// Total pago no financeiro
  double get totalPagoNoFinanceiro => compras
      .where((item) => item.isPagoNoFinanceiro)
      .fold(0.0, (acc, item) => acc + item.valorTotal);

  /// Total pendente no financeiro
  double get totalPendenteNoFinanceiro => compras
      .where((item) => item.isPendenteNoFinanceiro)
      .fold(0.0, (acc, item) => acc + item.valorTotal);

  /// Quantidade de compras vinculadas ao contas a pagar
  int get qtdComFinanceiro =>
      compras.where((item) => item.temLancamentoFinanceiro).length;

  /// Registra uma nova compra/despesa
  Future<bool> criar(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final created = await _apiService.createCompraDespesa(data);
      compras.insert(0, created);
      _mostrarNotificacao('Sucesso', 'Compra/Despesa registrada com sucesso!');
      return true;
    } catch (e) {
      _mostrarNotificacao('Erro', AppError.getErrorMessage(e));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Atualiza uma compra/despesa existente
  Future<bool> atualizar(int id, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final updated = await _apiService.updateCompraDespesa(id, data);
      final index = compras.indexWhere((c) => c.idCompraDespesa == id);
      if (index != -1) {
        compras[index] = updated;
      }
      _mostrarNotificacao('Sucesso', 'Compra/Despesa atualizada com sucesso!');
      return true;
    } catch (e) {
      _mostrarNotificacao('Erro', AppError.getErrorMessage(e));
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Exclui uma compra/despesa
  Future<bool> deletar(int id) async {
    try {
      await _apiService.deleteCompraDespesa(id);
      compras.removeWhere((c) => c.idCompraDespesa == id);
      _mostrarNotificacao('Sucesso', 'Compra/Despesa removida com sucesso!');
      return true;
    } catch (e) {
      _mostrarNotificacao('Erro', AppError.getErrorMessage(e));
      return false;
    }
  }

  /// Comprime a imagem da nota fiscal e envia para o backend realizar a extração via IA
  Future<Map<String, dynamic>?> processarFotoNota(File originalFile) async {
    isReadingOcr.value = true;
    try {
      final compressedFile =
          await ImageCompressionService.compressImage(originalFile);
      final resultado = await _apiService.lerNotaFiscal(compressedFile);
      return {
        'leitura': resultado,
        'imageFile': compressedFile,
      };
    } catch (e) {
      final msg = AppError.getErrorMessage(e);
      _mostrarNotificacao('Leitura da Nota', msg, duration: const Duration(seconds: 5));
      return null;
    } finally {
      isReadingOcr.value = false;
    }
  }

  void _mostrarNotificacao(String titulo, String mensagem, {Duration? duration}) {
    if (Get.context != null) {
      Get.snackbar(
        titulo,
        mensagem,
        snackPosition: SnackPosition.BOTTOM,
        duration: duration ?? const Duration(seconds: 4),
      );
    }
  }
}
