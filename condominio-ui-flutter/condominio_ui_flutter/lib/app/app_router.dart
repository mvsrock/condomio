import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_notifier.dart';
import '../features/auth/domain/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/condominio_selection/application/managed_condominio_notifier.dart';
import '../features/condominio_selection/presentation/pages/condominio_selection_page.dart';
import '../features/documents/presentation/pages/documents_page.dart';
import '../features/home/presentation/pages/dashboard_page.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/home/presentation/pages/session_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/registry/presentation/pages/registry_tab_page.dart';

/// Notifier bridge tra Riverpod e GoRouter.
///
/// Ogni cambio di `AuthState` notifica il router, che rivaluta `redirect`.
class RouterRefreshNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

final routerRefreshNotifierProvider = Provider<RouterRefreshNotifier>((ref) {
  final notifier = RouterRefreshNotifier();
  ref.listen<AuthState>(
    authStateProvider,
    (previous, next) => notifier.trigger(),
  );
  ref.listen<int>(
    authSessionRevisionProvider,
    (previous, next) => notifier.trigger(),
  );
  ref.listen<ManagedCondominioState>(
    managedCondominioProvider,
    (previous, next) => notifier.trigger(),
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Router applicativo principale.
///
/// Route top-level:
/// - `/login`
/// - `/loading`
/// - `/error`
/// - shell autenticata con branch `/home/*`
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/loading',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.uri.path;

      final isLogin = location == '/login';
      final isLoading = location == '/loading';
      final isError = location == '/error';
      final isCondominioLoading = location == '/condominio-loading';
      final isCondominioSelection = location == '/select-condominio';
      final isHome = location.startsWith('/home');
      if (authState == AuthState.authenticated) {
        ref.read(managedCondominioProvider.notifier).bootstrap();
        final condominioState = ref.read(managedCondominioProvider);
        if (!condominioState.ready || condominioState.isLoading) {
          if (isCondominioSelection || isCondominioLoading) {
            return null;
          }
          return isCondominioLoading ? null : '/condominio-loading';
        }
        if (condominioState.selectedId == null) {
          return isCondominioSelection ? null : '/select-condominio';
        }
        if (isCondominioLoading) {
          return '/home/dashboard';
        }
      }

      return switch (authState) {
        AuthState.loading => isLoading ? null : '/loading',
        AuthState.error => isError ? null : '/error',
        AuthState.unauthenticated => isLogin ? null : '/login',
        AuthState.authenticated => (isHome || isCondominioSelection)
            ? null
            : '/home/dashboard',
      };
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => SelectionArea(child: child),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/loading',
            builder: (context, state) => const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Autenticazione con Keycloak in corso...'),
                  ],
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/error',
            builder: (context, state) => const _AuthErrorPage(),
          ),
          GoRoute(
            path: '/condominio-loading',
            builder: (context, state) => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
          GoRoute(
            path: '/select-condominio',
            builder: (context, state) => const CondominioSelectionPage(),
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return HomeScreen(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home/dashboard',
                    builder: (context, state) => const DashboardPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home/map',
                    builder: (context, state) => const MapPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home/anagrafica',
                    builder: (context, state) => const RegistryTabPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home/session',
                    builder: (context, state) => const SessionPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/home/documents',
                    builder: (context, state) => const DocumentsPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthErrorPage extends ConsumerWidget {
  const _AuthErrorPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Errore autenticazione.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(authStateProvider.notifier).resetAuthState();
              },
              child: const Text('Vai al login'),
            ),
          ],
        ),
      ),
    );
  }
}
