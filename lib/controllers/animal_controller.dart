import 'package:get/get.dart';
import '../models/animal.dart';
import '../models/propriedade.dart';
import '../models/raca.dart';
import '../services/api_service.dart';
import '../utils/error_messages.dart';

/// Estatísticas de animais por propriedade (Corte vs Leite)
class PropriedadeAnimalStats {
  final int? idPropriedade;
  final String nomePropriedade;
  final int total;
  final int corte;
  final int leite;
  final int misto;

  const PropriedadeAnimalStats({
    required this.idPropriedade,
    required this.nomePropriedade,
    required this.total,
    required this.corte,
    required this.leite,
    this.misto = 0,
  });
}

/// Controller de Animais usando GetX
class AnimalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final animais = <Animal>[].obs;

  // Dropdowns / Referências
  final propriedades = <Propriedade>[].obs;
  final racas = <Raca>[].obs;
  final carregandoDropdowns = false.obs;

  // Filtros ativos
  final selectedPropriedadeId = Rxn<int>();
  final tipoProducaoFiltro = 'TODOS'.obs; // 'TODOS', 'CORTE', 'LEITE', 'MISTO'
  final statusFiltro = 'ATIVO'.obs; // 'TODOS', 'ATIVO', 'INATIVO'
  final searchQuery = ''.obs;

  final selectedAnimal = Rxn<Animal>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
    loadDropdowns();
  }

  /// Recarrega animais e dropdowns de apoio
  Future<void> refreshAll() async {
    await Future.wait([
      loadAll(),
      loadDropdowns(),
    ]);
  }

  Future<void> loadDropdowns() async {
    try {
      carregandoDropdowns.value = true;
      final propList = await _apiService.getAllPropriedades();
      propriedades.assignAll(propList);
      final racaList = await _apiService.getAllRacas();
      racas.assignAll(racaList);
    } catch (e) {
      Get.snackbar('Aviso', 'Não foi possível carregar listas para seleção',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      carregandoDropdowns.value = false;
    }
  }

  Future<void> loadAll() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAllAnimais();
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAtivos() async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorStatus('ATIVO');
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais ativos',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByPropriedade(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorPropriedade(id);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais da propriedade',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByRaca(int id) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorRaca(id);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais da raça',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getByStatus(String status) async {
    try {
      isLoading.value = true;
      final lista = await _apiService.getAnimaisPorStatus(status);
      animais.assignAll(lista);
    } catch (e) {
      Get.snackbar('Erro', 'Não foi possível carregar animais por status',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FILTROS & AÇÕES ---

  void filtrarPorPropriedade(int? idPropriedade) {
    if (selectedPropriedadeId.value == idPropriedade) {
      selectedPropriedadeId.value = null; // desmarca se clicar novamente
    } else {
      selectedPropriedadeId.value = idPropriedade;
    }
  }

  void filtrarPorTipoProducao(String tipo) {
    tipoProducaoFiltro.value = tipo;
  }

  void filtrarPorStatus(String status) {
    statusFiltro.value = status;
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
  }

  // --- ESTATÍSTICAS DO REBANHO ---

  int get totalGeral => animais.length;
  int get totalCorteGeral => animais.where((a) => a.isCorte).length;
  int get totalLeiteGeral => animais.where((a) => a.isLeite).length;
  int get totalMistoGeral => animais.where((a) => a.isMisto).length;

  /// Retorna as estatísticas agrupadas por propriedade (quantidade de corte e leite)
  List<PropriedadeAnimalStats> get statsPorPropriedade {
    final Map<int, String> propMap = {};

    // Adiciona propriedades conhecidas do controller
    for (final p in propriedades) {
      propMap[p.idPropriedade] = p.nome;
    }

    // Inclui eventuais propriedades referenciadas nos animais
    for (final a in animais) {
      if (a.idPropriedade > 0 && !propMap.containsKey(a.idPropriedade)) {
        propMap[a.idPropriedade] = a.propriedade.nome.isNotEmpty
            ? a.propriedade.nome
            : 'Propriedade #${a.idPropriedade}';
      }
    }

    final List<PropriedadeAnimalStats> list = [];

    propMap.forEach((id, nome) {
      final animaisDaProp =
          animais.where((a) => a.idPropriedade == id).toList();
      final corte = animaisDaProp.where((a) => a.isCorte).length;
      final leite = animaisDaProp.where((a) => a.isLeite).length;
      final misto = animaisDaProp.where((a) => a.isMisto).length;

      list.add(PropriedadeAnimalStats(
        idPropriedade: id,
        nomePropriedade: nome,
        total: animaisDaProp.length,
        corte: corte,
        leite: leite,
        misto: misto,
      ));
    });

    // Ordena decrescente por quantidade total e nome
    list.sort((a, b) {
      final comp = b.total.compareTo(a.total);
      if (comp != 0) return comp;
      return a.nomePropriedade.compareTo(b.nomePropriedade);
    });

    return list;
  }

  /// Lista de animais com todos os filtros combinados aplicados
  List<Animal> get animaisFiltrados {
    final query = searchQuery.value.trim().toLowerCase();
    final propId = selectedPropriedadeId.value;
    final tipo = tipoProducaoFiltro.value.toUpperCase();
    final st = statusFiltro.value.toUpperCase();

    return animais.where((animal) {
      // Filtro de propriedade
      if (propId != null && animal.idPropriedade != propId) {
        return false;
      }

      // Filtro de tipo de produção
      if (tipo != 'TODOS') {
        final tp = (animal.tipoProducao ?? '').toUpperCase();
        if (tp != tipo) return false;
      }

      // Filtro de status
      if (st == 'ATIVO' && !animal.isAtivo) return false;
      if (st == 'INATIVO' && animal.isAtivo) return false;

      // Filtro de texto
      if (query.isNotEmpty) {
        final matchId = animal.identificacao.toLowerCase().contains(query);
        final prop = animal.propriedade.nome.toLowerCase();
        final raca = animal.raca.descricao.toLowerCase();
        return matchId || prop.contains(query) || raca.contains(query);
      }

      return true;
    }).toList();
  }

  // --- CRUD ---

  Future<bool> create(Animal animal) async {
    try {
      isLoading.value = true;
      final created = await _apiService.createAnimal(animal);
      animais.add(created);
      Get.back();
      Get.snackbar('Sucesso', 'Animal criado com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateAnimal(int id, Animal animal) async {
    try {
      isLoading.value = true;
      final updated = await _apiService.updateAnimal(id, animal);
      final idx = animais.indexWhere((a) => a.idAnimal == id);
      if (idx >= 0) animais[idx] = updated;
      Get.back();
      Get.snackbar('Sucesso', 'Animal atualizado com sucesso!',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> delete(int id) async {
    try {
      isLoading.value = true;
      await _apiService.deleteAnimal(id);
      animais.removeWhere((a) => a.idAnimal == id);
      Get.snackbar('Sucesso', 'Animal deletado',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Erro', AppError.getErrorMessage(e),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void selectForEdit(Animal a) {
    selectedAnimal.value = a;
  }

  void clearSelection() {
    selectedAnimal.value = null;
  }
}
