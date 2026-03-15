import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Binding para telas de autenticação
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
