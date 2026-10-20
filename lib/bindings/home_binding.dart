import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';
import '../controllers/propriedade_controller.dart';
import '../controllers/animal_controller.dart';
import '../controllers/manejo_controller.dart';
import '../controllers/financeiro_controller.dart';

/// Binding para a tela Home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<SyncController>()) {
      Get.put<SyncController>(SyncController(), permanent: true);
    }
    Get.lazyPut<PropriedadeController>(() => PropriedadeController(),
        fenix: true);
    Get.lazyPut<AnimalController>(() => AnimalController(), fenix: true);
    Get.lazyPut<ManejoController>(() => ManejoController(), fenix: true);
    Get.lazyPut<FinanceiroController>(() => FinanceiroController(),
        fenix: true);
  }
}
