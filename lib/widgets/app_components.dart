import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Botão principal do app com variantes
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.large,
  })  : variant = AppButtonVariant.primary,
        color = null;

  const AppButton.secondary({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.large,
  })  : variant = AppButtonVariant.secondary,
        color = null;

  const AppButton.outline({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.large,
  })  : variant = AppButtonVariant.outline,
        color = null;

  const AppButton.ghost({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.large,
  })  : variant = AppButtonVariant.ghost,
        color = null;

  const AppButton.custom({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.size = AppButtonSize.large,
    required this.color,
  }) : variant = AppButtonVariant.custom;

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    final (bgColor, fgColor, borderColor, elevation) = switch (variant) {
      AppButtonVariant.primary => (
          colorScheme.primary,
          colorScheme.onPrimary,
          null,
          AppElevation.level1
        ),
      AppButtonVariant.secondary => (
          colorScheme.secondary,
          colorScheme.onSecondary,
          null,
          AppElevation.level1
        ),
      AppButtonVariant.outline => (
          Colors.transparent,
          colorScheme.primary,
          colorScheme.primary,
          AppElevation.level0
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          colorScheme.primary,
          null,
          AppElevation.level0
        ),
      AppButtonVariant.custom => (
          color ?? colorScheme.primary,
          Colors.white,
          null,
          AppElevation.level1
        ),
    };

    final horizontalPadding = switch (size) {
      AppButtonSize.small => AppSpacing.md,
      AppButtonSize.medium => AppSpacing.lg,
      AppButtonSize.large => AppSpacing.xl,
    };

    final height = switch (size) {
      AppButtonSize.small => 36.0,
      AppButtonSize.medium => 44.0,
      AppButtonSize.large => 52.0,
    };

    final textStyle = switch (size) {
      AppButtonSize.small => textTheme.labelSmall,
      AppButtonSize.medium => textTheme.labelMedium,
      AppButtonSize.large => textTheme.labelLarge,
    };

    final iconSize = switch (size) {
      AppButtonSize.small => 16.0,
      AppButtonSize.medium => 20.0,
      AppButtonSize.large => 22.0,
    };

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: elevation,
          shadowColor: colorScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return fgColor.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return fgColor.withValues(alpha: 0.05);
            }
            return null;
          }),
        ),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon is Icon ? (icon as Icon).icon : Icons.help,
                        size: iconSize),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(label, style: textStyle.copyWith(color: fgColor)),
                ],
              ),
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, outline, ghost, custom }

enum AppButtonSize { small, medium, large }

/// Card padronizado do app
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.md,
    this.margin,
    this.elevation = AppElevation.level1,
    this.onTap,
    this.border,
    this.color,
    this.gradient,
    this.borderRadius = AppRadius.lg,
  });

  final Widget child;
  final double padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final VoidCallback? onTap;
  final Border? border;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    final decoration = BoxDecoration(
      color: color ?? colorScheme.surface,
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ??
          Border.all(
            color: colorScheme.outline.withValues(alpha: 0.7),
            width: 1,
          ),
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: colorScheme.shadow,
                blurRadius: elevation * 4 + 4,
                offset: Offset(0, elevation + 1),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      // IMPORTANT: the background is painted with `Ink` (not `Container`)
      // so it's drawn as part of the Material's ink layer. If it were a
      // plain Container, its opaque color/gradient would paint *on top of*
      // the InkWell splash and hide it — this is exactly what causes the
      // "ListTile background color or ink splashes may be invisible"
      // style warning for any InkWell placed under an opaque decoration.
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              padding: EdgeInsets.all(padding),
              decoration: decoration,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: decoration,
      child: child,
    );
  }
}

/// Card com header, body e footer
class AppCardSectioned extends StatelessWidget {
  const AppCardSectioned({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.padding = AppSpacing.md,
    this.margin,
    this.elevation = AppElevation.level1,
    this.onTap,
    this.color,
    this.gradient,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final double padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return AppCard(
      margin: margin,
      elevation: elevation,
      onTap: onTap,
      color: color,
      gradient: gradient,
      padding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: EdgeInsets.all(padding),
              child: header,
            ),
          if (header != null && footer != null)
            Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: EdgeInsets.all(padding),
            child: body,
          ),
          if (footer != null) ...[
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: EdgeInsets.all(padding),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

/// Input field padronizado
class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.suffixText,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final Widget? suffixIcon;
  final String? suffixText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode,
      textCapitalization: textCapitalization,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: colorScheme.primary, size: 20)
            : null,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        labelStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle:
            theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
        counterStyle: theme.textTheme.bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}

/// Estado vazio padronizado
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 64,
    this.spacing = AppSpacing.md,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final textTheme = theme.extension<AppTextTheme>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: colorScheme.primary),
            ),
            SizedBox(height: spacing),
            Text(title,
                style: textTheme.headlineSmall, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle!,
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading overlay padronizado
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(message!,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Skeleton loader para listas
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.md,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: const _ShimmerEffect(),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).extension<AppColorScheme>()!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                colorScheme.outlineVariant.withValues(alpha: 0.3),
                colorScheme.outlineVariant.withValues(alpha: 0.1),
                colorScheme.outlineVariant.withValues(alpha: 0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Banner de mensagem (erro/sucesso/info)
class AppMessageBanner extends StatelessWidget {
  const AppMessageBanner({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppMessageType type;
  final VoidCallback? onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    final (bgColor, borderColor, icon, textColor) = switch (type) {
      AppMessageType.error => (
          colorScheme.error.withValues(alpha: 0.1),
          colorScheme.error,
          Icons.error_outline,
          colorScheme.error,
        ),
      AppMessageType.success => (
          colorScheme.success.withValues(alpha: 0.1),
          colorScheme.success,
          Icons.check_circle_outline,
          colorScheme.success,
        ),
      AppMessageType.warning => (
          colorScheme.warning.withValues(alpha: 0.1),
          colorScheme.warning,
          Icons.warning_amber_outlined,
          colorScheme.warning,
        ),
      AppMessageType.info => (
          colorScheme.info.withValues(alpha: 0.1),
          colorScheme.info,
          Icons.info_outline,
          colorScheme.info,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: textColor)),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: textColor,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(Icons.close, color: textColor, size: 18),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              tooltip: 'Fechar',
            ),
        ],
      ),
    );
  }
}

enum AppMessageType { error, success, warning, info }

/// Chip padronizado
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onDeleted,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onDeleted;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;
    final chipColor = color ?? colorScheme.primary;

    return FilterChip(
      label: Text(label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : chipColor,
            fontWeight: FontWeight.w500,
          )),
      avatar: icon != null
          ? Icon(icon, size: 16, color: selected ? Colors.white : chipColor)
          : null,
      selected: selected,
      onSelected: onTap != null ? (v) => onTap!() : null,
      onDeleted: onDeleted,
      deleteIcon: Icon(Icons.close,
          size: 16, color: selected ? Colors.white : chipColor),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.round)),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Badge de status
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.size = AppStatusBadgeSize.medium,
  });

  final String label;
  final AppStatusType type;
  final AppStatusBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    final (bgColor, textColor) = switch (type) {
      AppStatusType.active => (
          colorScheme.success.withValues(alpha: 0.15),
          colorScheme.success
        ),
      AppStatusType.inactive => (
          colorScheme.outlineVariant,
          colorScheme.onSurfaceVariant
        ),
      AppStatusType.pending => (
          colorScheme.warning.withValues(alpha: 0.15),
          colorScheme.warning
        ),
      AppStatusType.error => (
          colorScheme.error.withValues(alpha: 0.15),
          colorScheme.error
        ),
      AppStatusType.info => (
          colorScheme.info.withValues(alpha: 0.15),
          colorScheme.info
        ),
    };

    final fontSize = switch (size) {
      AppStatusBadgeSize.small => 10.0,
      AppStatusBadgeSize.medium => 12.0,
      AppStatusBadgeSize.large => 14.0,
    };

    final padding = switch (size) {
      AppStatusBadgeSize.small =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      AppStatusBadgeSize.medium =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      AppStatusBadgeSize.large =>
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
    };

    final dotSize = switch (size) {
      AppStatusBadgeSize.small => 5.0,
      AppStatusBadgeSize.medium => 6.0,
      AppStatusBadgeSize.large => 7.0,
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.round),
        border: Border.all(
          color: textColor.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: size == AppStatusBadgeSize.small ? 4.0 : 6.0),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum AppStatusType { active, inactive, pending, error, info }

enum AppStatusBadgeSize { small, medium, large }

/// Dropdown padronizado (mesmo visual do AppInput)
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.icon,
    this.prefixIcon,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.extension<AppColorScheme>()!;

    return DropdownButtonFormField<T>(
      items: items,
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary, size: 20)
            : null,
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        labelStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
        errorStyle:
            theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
      ),
      dropdownColor: colorScheme.surface,
      iconEnabledColor: colorScheme.onSurfaceVariant,
      menuMaxHeight: 320,
    );
  }
}
