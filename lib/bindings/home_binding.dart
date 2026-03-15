import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';

/// Binding para a tela Home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<SyncController>(() => SyncController());
  }
}
