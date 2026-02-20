import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'app_startup.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';

/// Root widget applicativo.
///
/// Responsabilita':
/// - ospitare `MaterialApp`
/// - agganciarsi ad `AuthState`
/// - delegare bootstrap a [AppStartupCoordinator]
/// - delegare routing a `buildHomeFromAuthState(...)`
class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppStartupCoordinator(ref).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Condominio',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: buildHomeFromAuthState(authState, ref),
    );
  }
}
