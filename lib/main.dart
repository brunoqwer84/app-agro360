import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'bindings/initial_binding.dart';
import 'services/api_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar serviços
  await initServices();

  runApp(const MyApp());
}

/// Inicializa os serviços necessários antes do app iniciar
Future<void> initServices() async {
  // Inicializar binding global
  InitialBinding().dependencies();

  // Inicializar API Service
  final apiService = Get.find<ApiService>();
  await apiService.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Agro360',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      initialBinding: InitialBinding(),
      defaultTransition: Transition.fadeIn,
      transitionDuration: AppDuration.normal,
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      extensions: [
        AppColorScheme.light,
        AppTextTheme.light,
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surface,
        onSurfaceVariant: AppColors.textSecondary,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.divider,
        outlineVariant: AppColors.divider,
        shadow: AppColors.shadow,
        scrim: AppColors.shadow,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.background,
        inversePrimary: AppColors.primaryLight,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleTextStyle: base.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.level1,
        shadowColor: AppColors.shadowLight,
        surfaceTintColor: Colors.transparent,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppElevation.level1,
          shadowColor: AppColors.shadowLight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 48),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          textStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 1),
        ),
        labelStyle: base.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        hintStyle: base.textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        errorStyle: base.textTheme.bodySmall?.copyWith(color: AppColors.error),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textHint,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.round)),
        labelStyle: base.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        side: const BorderSide(color: AppColors.divider),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryContainer,
        secondarySelectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.primaryDark,
        deleteIconColor: AppColors.textHint,
        brightness: Brightness.light,
        pressElevation: 0,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.md,
        indent: 0,
        endIndent: 0,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryContainer,
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        subtitleTextStyle: base.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        leadingAndTrailingTextStyle: base.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        minLeadingWidth: 40,
        horizontalTitleGap: AppSpacing.md,
        dense: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        extendedTextStyle: base.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: AppElevation.level4,
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: base.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: base.textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevation.level4,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return base.textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base.textTheme.labelSmall?.copyWith(color: AppColors.textHint);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textHint, size: 24);
        }),
        height: 64,
      ),
      dialogTheme: DialogThemeData(
        elevation: AppElevation.level4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xxl)),
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.card,
        titleTextStyle: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        contentTextStyle: base.textTheme.bodyMedium,
        alignment: Alignment.center,
        actionsPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        elevation: AppElevation.level4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.card,
        modalBackgroundColor: AppColors.card,
        dragHandleColor: AppColors.divider,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: AppElevation.level3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: base.textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: AppColors.primaryLight,
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: base.textTheme.bodySmall?.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        preferBelow: true,
        verticalOffset: 8,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primaryContainer,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.15),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: base.textTheme.labelSmall?.copyWith(color: Colors.white),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primaryContainer;
          return AppColors.divider;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.check, size: 16, color: Colors.white);
          }
          return const Icon(Icons.close, size: 16, color: Colors.white);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.divider, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        visualDensity: VisualDensity.compact,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.textHint;
        }),
        visualDensity: VisualDensity.compact,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w400),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(AppColors.primary.withValues(alpha: 0.1)),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        backgroundColor: AppColors.surface,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        childrenPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        iconColor: AppColors.textSecondary,
        collapsedIconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textPrimary,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      extensions: [
        AppColorScheme.light.copyWith(
          primary: AppColors.primaryLight,
          onPrimary: Colors.black,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: AppColors.primaryLight,
          surface: const Color(0xFF1E1E1E),
          onSurface: Colors.white,
          surfaceVariant: const Color(0xFF2C2C2C),
          onSurfaceVariant: Colors.grey.shade400,
          background: const Color(0xFF121212),
          onBackground: Colors.white,
          outline: Colors.grey.shade700,
          outlineVariant: Colors.grey.shade800,
          shadow: Colors.black,
          scrim: Colors.black,
          inverseSurface: Colors.white,
          inverseOnSurface: Colors.black,
          inversePrimary: AppColors.primary,
        ),
        AppTextTheme.light.copyWith(
          displayLarge: AppTextTheme.light.displayLarge.copyWith(color: Colors.white),
          displayMedium: AppTextTheme.light.displayMedium.copyWith(color: Colors.white),
          displaySmall: AppTextTheme.light.displaySmall.copyWith(color: Colors.white),
          headlineLarge: AppTextTheme.light.headlineLarge.copyWith(color: Colors.white),
          headlineMedium: AppTextTheme.light.headlineMedium.copyWith(color: Colors.white),
          headlineSmall: AppTextTheme.light.headlineSmall.copyWith(color: Colors.white),
          titleLarge: AppTextTheme.light.titleLarge.copyWith(color: Colors.white),
          titleMedium: AppTextTheme.light.titleMedium.copyWith(color: Colors.white),
          titleSmall: AppTextTheme.light.titleSmall.copyWith(color: Colors.white),
          bodyLarge: AppTextTheme.light.bodyLarge.copyWith(color: Colors.white),
          bodyMedium: AppTextTheme.light.bodyMedium.copyWith(color: Colors.grey.shade300),
          bodySmall: AppTextTheme.light.bodySmall.copyWith(color: Colors.grey.shade500),
          labelLarge: AppTextTheme.light.labelLarge.copyWith(color: Colors.white),
          labelMedium: AppTextTheme.light.labelMedium.copyWith(color: Colors.grey.shade300),
          labelSmall: AppTextTheme.light.labelSmall.copyWith(color: Colors.grey.shade500),
        ),
      ],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLight,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        onPrimary: Colors.black,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: const Color(0xFF1E1E1E),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF2C2C2C),
        onSurfaceVariant: Colors.grey.shade400,
        error: AppColors.errorLight,
        onError: Colors.black,
        outline: Colors.grey.shade700,
        outlineVariant: Colors.grey.shade800,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Colors.white,
        onInverseSurface: Colors.black,
        inversePrimary: AppColors.primary,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}