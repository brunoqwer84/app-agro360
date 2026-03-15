import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sync_controller.dart';

/// Binding inicial para injeção de dependências
/// Inicializa os serviços e controllers principais do app
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services - Lazy Singleton (criado uma vez e mantido na memória)
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<DatabaseService>(() => DatabaseService(), fenix: true);
    
    // Controllers - Lazy Put (criado quando necessário)
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<SyncController>(() => SyncController(), fenix: true);
  }
}
