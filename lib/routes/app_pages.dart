import 'package:get/get.dart';
import '../views/grupo_form_view.dart';
import '../views/grupo_list_view.dart';
import '../views/splash_view.dart';
import '../views/login_view.dart';
import '../views/register_view.dart';
import '../views/propriedade_list_view.dart';
import '../views/propriedade_form_view.dart';
import '../views/raca_list_view.dart';
import '../views/raca_form_view.dart';
import '../views/animal_list_view.dart';
import '../views/animal_form_view.dart';
import '../views/manejo_list_view.dart';
import '../views/manejo_form_view.dart';
import '../views/pesagem_list_view.dart';
import '../views/pesagem_form_view.dart';
import '../views/vacinacao_list_view.dart';
import '../views/vacinacao_form_view.dart';
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
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.propriedades,
      page: () => const PropriedadeListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.propriedadesForm,
      page: () => const PropriedadeFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.racas,
      page: () => const RacaListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.racasForm,
      page: () => const RacaFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.animais,
      page: () => const AnimalListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.animaisForm,
      page: () => const AnimalFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.manejos,
      page: () => const ManejoListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.manejosForm,
      page: () => const ManejoFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.pesagens,
      page: () => const PesagemListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.pesagensForm,
      page: () => const PesagemFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.vacinacoes,
      page: () => const VacinacaoListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.vacinacoesForm,
      page: () => const VacinacaoFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.grupos,
      page: () => const GrupoListView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.gruposForm,
      page: () => const GrupoFormView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
  ];
}