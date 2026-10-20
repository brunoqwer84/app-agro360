import 'package:get/get.dart';
import '../models/lancamento_financeiro.dart';
import '../models/balanco_financeiro.dart';
import '../models/manejo.dart';
import '../models/pessoa.dart';
import '../models/propriedade.dart';
import '../models/categoria_financeira.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

enum PeriodoExercicio {
  dias30,
  dias60,
  anual,
  todos,
  customizado,
}

/// Controller de Gestão Financeira (Contas a Pagar, Contas a Receber e Balanço)
class FinanceiroController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final isSaving = false.obs;

  // Lançamentos e balanço
  final lancamentos = <LancamentoFinanceiro>[].obs;
  final balanco = Rxn<BalancoFinanceiro>();
  final selectedLancamento = Rxn<LancamentoFinanceiro>();

  // Entidades auxiliares para seleção em formulários
  final categorias = <CategoriaFinanceira>[].obs;
  final manejos = <Manejo>[].obs;
  final pessoas = <Pessoa>[].obs;
  final propriedades = <Propriedade>[].obs;

  // Filtros ativos
  final periodoSelecionado = PeriodoExercicio.dias30.obs;
  final dataInicio = Rxn<DateTime>();
  final dataFim = Rxn<DateTime>();
  final statusFiltro = Rxn<String>(); // null = todos, 'PENDENTE', 'PAGO'
  final tipoFiltro = Rxn<String>(); // null = todos, 'RECEITA', 'DESPESA'

  @override
  void onInit() {
    super.onInit();
    aplicarPeriodo(PeriodoExercicio.dias30, reload: false);
    loadAll();
    loadAuxiliares();
  }

  /// Define o período do exercício e recarrega os dados
  void aplicarPeriodo(PeriodoExercicio periodo, {DateTime? customInicio, DateTime? customFim, bool reload = true}) {
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
        // Exercício anual (ano corrente)
        dataInicio.value = DateTime(now.year, 1, 1);
        dataFim.value = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case PeriodoExercicio.todos:
        dataInicio.value = null;
        dataFim.value = null;
        break;
      case PeriodoExercicio.customizado:
        if (customInicio != null && customFim != null) {
          dataInicio.value = DateTime(customInicio.year, customInicio.month, customInicio.day);
          dataFim.value = DateTime(customFim.year, customFim.month, customFim.day, 23, 59, 59);
        }
        break;
    }

    if (reload) {
      loadAll();
    }
  }

  /// Carrega lançamentos e balanço com os filtros atuais
  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _apiService.getAllLancamentos(
          tipo: tipoFiltro.value,
          status: statusFiltro.value,
          dataInicio: dataInicio.value,
          dataFim: dataFim.value,
        ),
        _apiService.getBalancoFinanceiro(
          dataInicio: dataInicio.value,
          dataFim: dataFim.value,
        ),
      ]);

      lancamentos.assignAll(results[0] as List<LancamentoFinanceiro>);
      balanco.value = results[1] as BalancoFinanceiro;
    } catch (e) {
      Get.snackbar(
        'Erro ao carregar dados',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Carrega listas auxiliares (Categorias, Manejos, Pessoas, Propriedades) para formulários
  Future<void> loadAuxiliares() async {
    try {
      final results = await Future.wait([
        _apiService
            .getAllCategoriasFinanceiras(apenasAtivos: true)
            .catchError((_) => <CategoriaFinanceira>[]),
        _apiService.getAllManejos().catchError((_) => <Manejo>[]),
        _apiService.getPessoasAtivas().catchError((_) => <Pessoa>[]),
        _apiService.getPropriedadesAtivas().catchError((_) => <Propriedade>[]),
      ]);

      categorias.assignAll(results[0] as List<CategoriaFinanceira>);
      manejos.assignAll(results[1] as List<Manejo>);
      pessoas.assignAll(results[2] as List<Pessoa>);
      propriedades.assignAll(results[3] as List<Propriedade>);
    } catch (_) {
      // Ignora falhas menores no carregamento de auxiliares
    }
  }

  /// Categorias de despesa (tipo P)
  List<CategoriaFinanceira> get categoriasDespesa =>
      categorias.where((c) => c.isDespesa).toList();

  /// Categorias de receita (tipo R)
  List<CategoriaFinanceira> get categoriasReceita =>
      categorias.where((c) => c.isReceita).toList();

  /// Retorna categorias para o tipo selecionado ('P' ou 'R')
  List<CategoriaFinanceira> getCategoriasPorTipo(String tipo) {
    final t = tipo.toUpperCase();
    if (t == 'P' || t == 'DESPESA' || t == 'PAGAR') {
      return categoriasDespesa;
    } else {
      return categoriasReceita;
    }
  }

  /// Clientes ativos (tipo C ou A)
  List<Pessoa> get clientes => pessoas.where((p) => p.isCliente).toList();

  /// Fornecedores ativos (tipo F ou A)
  List<Pessoa> get fornecedores => pessoas.where((p) => p.isFornecedor).toList();

  /// Retorna lista de pessoas/contatos de acordo com o tipo de lançamento ('P' -> Fornecedores, 'R' -> Clientes)
  List<Pessoa> getPessoasPorTipoLancamento(String tipo) {
    final t = tipo.toUpperCase();
    if (t == 'P' || t == 'DESPESA' || t == 'PAGAR') {
      return fornecedores;
    } else {
      return clientes;
    }
  }

  /// Lista filtrada: apenas Contas a Pagar (Despesas)
  List<LancamentoFinanceiro> get contasAPagar =>
      lancamentos.where((l) => l.isDespesa).toList();

  /// Lista filtrada: apenas Contas a Receber (Receitas)
  List<LancamentoFinanceiro> get contasAReceber =>
      lancamentos.where((l) => l.isReceita).toList();

  /// Total a pagar pendente
  double get totalPendentePagar => contasAPagar
      .where((l) => l.isPendente)
      .fold(0.0, (acc, item) => acc + item.valor);

  /// Total a receber pendente
  double get totalPendenteReceber => contasAReceber
      .where((l) => l.isPendente)
      .fold(0.0, (acc, item) => acc + item.valor);

  /// Cria lançamento financeiro
  Future<bool> create(LancamentoFinanceiro lancamento) async {
    try {
      isSaving.value = true;
      final created = await _apiService.createLancamento(lancamento);
      lancamentos.insert(0, created);
      // Recarrega balanço atualizado
      _recarregarBalancoSilencioso();
      Get.back();
      Get.snackbar(
        'Sucesso',
        '${created.isReceita ? "Receita" : "Despesa"} cadastrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro ao salvar',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Atualiza lançamento financeiro
  Future<bool> updateLancamento(int id, LancamentoFinanceiro lancamento) async {
    try {
      isSaving.value = true;
      final updated = await _apiService.updateLancamento(id, lancamento);
      final idx = lancamentos.indexWhere((l) => l.idLancamento == id);
      if (idx >= 0) {
        lancamentos[idx] = updated;
      }
      _recarregarBalancoSilencioso();
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Lançamento atualizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro ao atualizar',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Marca lançamento como pago ou recebido
  Future<bool> marcarComoPago(int id, {DateTime? dataPagamento}) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.marcarLancamentoComoPago(
        id,
        dataPagamento: dataPagamento ?? DateTime.now(),
      );
      final idx = lancamentos.indexWhere((l) => l.idLancamento == id);
      if (idx >= 0) {
        lancamentos[idx] = updated;
      }
      _recarregarBalancoSilencioso();
      Get.snackbar(
        'Liquidado!',
        'Lançamento liquidado com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Deleta lançamento financeiro
  Future<bool> deleteLancamento(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteLancamento(id);
      lancamentos.removeWhere((l) => l.idLancamento == id);
      _recarregarBalancoSilencioso();
      Get.snackbar(
        'Sucesso',
        'Lançamento removido com sucesso.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Erro ao excluir',
        AppError.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _recarregarBalancoSilencioso() async {
    try {
      final b = await _apiService.getBalancoFinanceiro(
        dataInicio: dataInicio.value,
        dataFim: dataFim.value,
      );
      balanco.value = b;
    } catch (_) {}
  }
}
