import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_font_scale.dart';
import 'app/theme/app_theme.dart';
import 'app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppColors.restoreSavedPalette();
  await AppFontScale.restore();
  runApp(const ProviderScope(child: TallyJieApp()));
}

class TallyJieApp extends StatelessWidget {
  const TallyJieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: AppColors.themeVersion,
      builder: (context, _, child) {
        return MaterialApp.router(
          title: 'TallyJie',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return ValueListenableBuilder<int>(
              valueListenable: AppFontScale.version,
              builder: (context, _, scaledChild) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: _AppUiScale(
                  scale: 0.84,
                  fontScale: AppFontScale.current,
                  child: scaledChild ?? const SizedBox(),
                ),
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}

class _AppUiScale extends StatelessWidget {
  final double scale;
  final double fontScale;
  final Widget child;

  const _AppUiScale({
    required this.scale,
    required this.fontScale,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
          return Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: child,
          );
        }

        final media = MediaQuery.of(context);
        final logicalSize = Size(
          constraints.maxWidth / scale,
          constraints.maxHeight / scale,
        );

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: logicalSize.width,
            maxWidth: logicalSize.width,
            minHeight: logicalSize.height,
            maxHeight: logicalSize.height,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: MediaQuery(
                data: media.copyWith(
                  size: logicalSize,
                  textScaler: TextScaler.linear(fontScale),
                  padding: _scaleInsets(media.padding),
                  viewPadding: _scaleInsets(media.viewPadding),
                  viewInsets: _scaleInsets(media.viewInsets),
                  systemGestureInsets: _scaleInsets(media.systemGestureInsets),
                ),
                child: SizedBox(
                  width: logicalSize.width,
                  height: logicalSize.height,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _scaleInsets(EdgeInsets insets) {
    return EdgeInsets.fromLTRB(
      insets.left / scale,
      insets.top / scale,
      insets.right / scale,
      insets.bottom / scale,
    );
  }
}
