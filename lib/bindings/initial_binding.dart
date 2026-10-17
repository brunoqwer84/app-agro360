import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/grupo_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/raca_controller.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/pesagem_controller.dart';
import '../controllers/vacinacao_controller.dart';

/// Binding inicial para injeção de dependências globais
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Serviços e controllers essenciais com ciclo de vida permanente
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }
    if (!Get.isRegistered<DatabaseService>()) {
      Get.put<DatabaseService>(DatabaseService(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<SyncController>()) {
      Get.put<SyncController>(SyncController(), permanent: true);
    }

    // Controllers de dados sob demanda com fenix: true (renascem se descartados)
    Get.lazyPut<GrupoController>(() => GrupoController(), fenix: true);
    Get.lazyPut<PropriedadeController>(() => PropriedadeController(),
        fenix: true);
    Get.lazyPut<RacaController>(() => RacaController(), fenix: true);
    Get.lazyPut<AnimalController>(() => AnimalController(), fenix: true);
    Get.lazyPut<ManejoController>(() => ManejoController(), fenix: true);
    Get.lazyPut<PesagemController>(() => PesagemController(), fenix: true);
    Get.lazyPut<VacinacaoController>(() => VacinacaoController(), fenix: true);
  }
}
