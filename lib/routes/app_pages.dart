import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/home_view.dart';
import '../bindings/initial_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import 'app_routes.dart';

/// Configuração de páginas e rotas do GetX
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}
