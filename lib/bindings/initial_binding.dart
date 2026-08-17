import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/raca_controller.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/pesagem_controller.dart';
import '../controllers/vacinacao_controller.dart';

/// Binding inicial para injeção de dependências
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<DatabaseService>(() => DatabaseService(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<SyncController>(() => SyncController(), fenix: true);
    Get.lazyPut<PropriedadeController>(() => PropriedadeController(), fenix: true);
    Get.lazyPut<RacaController>(() => RacaController(), fenix: true);
    Get.lazyPut<AnimalController>(() => AnimalController(), fenix: true);
    Get.lazyPut<ManejoController>(() => ManejoController(), fenix: true);
    Get.lazyPut<PesagemController>(() => PesagemController(), fenix: true);
    Get.lazyPut<VacinacaoController>(() => VacinacaoController(), fenix: true);
  }
}
