import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/main_layout.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: WardonPosApp(),
    ),
  );
}

class WardonPosApp extends ConsumerWidget {
  const WardonPosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'WARDON POS - Warung Kopi & Eatery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: user == null ? const LoginScreen() : const MainLayout(),
    );
  }
}
