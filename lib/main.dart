import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'app/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppColors.restoreSavedPalette();
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
        );
      },
    );
  }
}
