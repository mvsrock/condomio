import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/keycloak_config.dart';
import 'models/auth_state.dart';
import 'platform/web_platform.dart';
import 'providers/auth_provider.dart';
import 'providers/keycloak_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  _setupUrlMonitoring();
  print(
    '[CONFIG] profile=${KeycloakAppConfig.activeProfile} '
    'server=${KeycloakAppConfig.keycloakServerUrl} '
    'redirect=${KeycloakAppConfig.appRedirectUri}',
  );

  runApp(const ProviderScope(child: MainApp()));
}

/// Diagnostica startup solo web per debug callback/redirect.
void _setupUrlMonitoring() {
  if (!kIsWeb) return;

  print('[GLOBAL_DEBUG] Setting up URL monitoring...');
  print('[GLOBAL_DEBUG] Current URL at startup: ${webPlatform.locationHref}');
  print('[GLOBAL_DEBUG] Current pathname: ${webPlatform.locationPathname}');
  print('[GLOBAL_DEBUG] Current search: ${webPlatform.locationSearch}');
}

/// Root widget dell'app, agganciato allo stato di autenticazione.
///
/// Strategia di routing adottata:
/// - authenticated -> HomeScreen
/// - unauthenticated -> LoginScreen
/// - loading -> schermata attesa
/// - error -> schermata errore con retry
///
/// FLUSSO STEP-BY-STEP (alto livello):
/// 1. `main()` avvia `ProviderScope`, quindi Riverpod e' disponibile ovunque.
/// 2. `MainApp.initState()` richiama `_initializeKeycloak()`.
/// 3. `_initializeKeycloak()` inizializza il service e verifica callback/sessione.
/// 4. `build()` osserva `authStateProvider` con `ref.watch(...)`.
/// 5. `_buildHome(...)` seleziona la schermata in base allo stato auth.
/// 6. Ogni cambio stato nel notifier aggiorna automaticamente la UI.
class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();

    // Esegue bootstrap auth dopo il primo frame, quando il tree provider e' pronto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeKeycloak();
    });
  }

  /// Bootstrap stato auth all'avvio app.
  ///
  /// Flusso:
  /// 1) inizializza servizio Keycloak
  /// 2) se web callback contiene `code`, completa il token exchange
  /// 3) altrimenti se c'e' sessione valida, ripristina authenticated
  /// 4) altrimenti resta in unauthenticated (mostra LoginScreen)
  Future<void> _initializeKeycloak() async {
    try {
      final keycloakService = ref.read(keycloakServiceProvider);
      final authNotifier = ref.read(authStateProvider.notifier);

      print(
        '[MainApp._initializeKeycloak] Step 1: Initializing Keycloak service...',
      );
      await keycloakService.init();
      print('[MainApp._initializeKeycloak] Step 1: Keycloak initialized');

      final uri = Uri.base;
      final code = kIsWeb ? uri.queryParameters['code'] : null;
      final sessionState = kIsWeb ? uri.queryParameters['session_state'] : null;

      print('[MainApp._initializeKeycloak] Current URL: $uri');
      print(
        '[MainApp._initializeKeycloak] Query params - code: '
        '${code != null ? "PRESENT (${code.substring(0, 10)}...)" : "NOT PRESENT"}',
      );
      print(
        '[MainApp._initializeKeycloak] Query params - session_state: '
        '${sessionState != null ? "PRESENT" : "NOT PRESENT"}',
      );

      if (code != null && code.isNotEmpty) {
        print(
          '[MainApp._initializeKeycloak] Step 2a: Found authorization code in URL',
        );

        try {
          print(
            '[MainApp._initializeKeycloak] Step 3: Exchanging code for tokens...',
          );
          await authNotifier.processToken(code);
          print('[MainApp._initializeKeycloak] Token exchange successful');
        } catch (e) {
          print('[MainApp._initializeKeycloak] Token exchange failed: $e');
        }
      } else if (keycloakService.hasValidSession()) {
        print(
          '[MainApp._initializeKeycloak] Step 2b: Found valid existing session',
        );
        print(
          '[MainApp._initializeKeycloak] Step 3: Restoring authenticated session...',
        );
        authNotifier.restoreSession();
        print('[MainApp._initializeKeycloak] Session restored');
      } else {
        print(
          '[MainApp._initializeKeycloak] Step 2c: No callback code and no valid session',
        );
      }
    } catch (e) {
      print('[MainApp._initializeKeycloak] Initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // `watch` rende il widget reattivo: ogni cambio AuthState ricostruisce la UI.
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Condominio',
      debugShowCheckedModeBanner: false,
      // Tema globale centralizzato: qui definiamo linguaggio visivo base
      // (colori, card, appbar, input) condiviso da tutte le schermate.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E75),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F6FA),
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: _buildHome(authState, ref),
    );
  }

  /// Routing dichiarativo basato su stato:
  /// nessuna push/pop esplicita, la home cambia quando cambia AuthState.
  Widget _buildHome(AuthState authState, WidgetRef ref) {
    return switch (authState) {
      // Sessione valida -> area applicativa autenticata.
      AuthState.authenticated => const HomeScreen(),
      // Nessuna sessione -> login.
      AuthState.unauthenticated => const LoginScreen(),
      // Operazione auth in corso -> feedback visivo.
      AuthState.loading => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Splash minimale mentre il flusso auth e' in corso.
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Authenticating with Keycloak...'),
            ],
          ),
        ),
      ),
      // Errore auth -> messaggio + azione di retry.
      AuthState.error => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Authentication error. Please try again.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry riporta stato a base, cosi' UI torna alla login.
                  ref.read(authStateProvider.notifier).resetAuthState();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    };
  }
}
