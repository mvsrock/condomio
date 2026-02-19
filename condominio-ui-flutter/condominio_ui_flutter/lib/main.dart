import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/keycloak_config.dart';
import 'models/auth_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/keycloak_provider.dart';
import 'platform/web_platform.dart';

void main() {
  // DEBUG: Monitora OGNI cambio di URL a livello JavaScript
  _setupUrlMonitoring();
  print(
    '[CONFIG] profile=${KeycloakAppConfig.activeProfile} '
    'server=${KeycloakAppConfig.keycloakServerUrl} '
    'redirect=${KeycloakAppConfig.appRedirectUri}',
  );
  
  runApp(
    // ProviderScope è necessario per usare Riverpod in Flutter
    // Avvolge l'intera app per fornire accesso ai provider
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

/// Aggiunge un listener che monitora i cambi di URL
void _setupUrlMonitoring() {
  if (!kIsWeb) return;
  
  print('[GLOBAL_DEBUG] Setting up URL monitoring...');
  print('[GLOBAL_DEBUG] Current URL at startup: ${webPlatform.locationHref}');
  print('[GLOBAL_DEBUG] Current pathname: ${webPlatform.locationPathname}');
  print('[GLOBAL_DEBUG] Current search: ${webPlatform.locationSearch}');
}
/// FLUSSO:
/// 1. ProviderScope in main() inizializza Riverpod
/// 2. MainApp è un ConsumerWidget che ha accesso ai provider
/// 3. build() usa ref.watch() per ascoltare authStateProvider
/// 4. Quando lo stato cambia (login/logout), UI si aggiorna automaticamente
/// 5. Se stato = authenticated → mostra HomeScreen
/// 6. Se stato = unauthenticated/error → mostra LoginScreen
/// 7. Se stato = loading → mostra spinner di loading
class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    // Alla partenza dell'app, inizializza Keycloak e check per il callback code
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeKeycloak();
    });
  }

  /// Inizializzazione dello stato di autenticazione all'app start
  /// 
  /// FLUSSO:
  /// 1. Inizializza Keycloak (carica token da localStorage se esistono)
  /// 2. Controlla il URL per un code di callback da Keycloak
  /// 3. Se code presente, chiama AuthNotifier.processToken() per lo scambio
  /// 4. Se niente code ma token validi in localStorage, chiama AuthNotifier.restoreSession()
  /// 5. Altrimenti mostra LoginScreen
  Future<void> _initializeKeycloak() async {
    try {
      final keycloakService = ref.read(keycloakServiceProvider);
      final authNotifier = ref.read(authStateProvider.notifier);
      
      // STEP 1: Inizializza il servizio Keycloak (carica token da localStorage se esistono)
      print('[MainApp._initializeKeycloak] Step 1: Initializing Keycloak service...');
      await keycloakService.init();
      print('[MainApp._initializeKeycloak] Step 1: Keycloak initialized');

      // STEP 2: Controlla il URL per un code di callback da Keycloak
      final uri = Uri.base;
      final code = kIsWeb ? uri.queryParameters['code'] : null;
      final sessionState = kIsWeb ? uri.queryParameters['session_state'] : null;
      
      print('[MainApp._initializeKeycloak] Current URL: $uri');
      print('[MainApp._initializeKeycloak] Query params - code: ${code != null ? "PRESENT (${code.substring(0, 10)}...)" : "NOT PRESENT"}');
      print('[MainApp._initializeKeycloak] Query params - session_state: ${sessionState != null ? "PRESENT" : "NOT PRESENT"}');
      
      if (code != null && code.isNotEmpty) {
        // L'utente torna da Keycloak con un authorization code
        print('[MainApp._initializeKeycloak] ✓ Step 2a: Found authorization code in URL');
        
        try {
          print('[MainApp._initializeKeycloak] Step 3: Exchanging code for tokens...');
          await authNotifier.processToken(code);
          print('[MainApp._initializeKeycloak] ✓ Token exchange successful!');
        } catch (e) {
          print('[MainApp._initializeKeycloak] ✗ Token exchange FAILED: $e');
        }
      } else if (keycloakService.hasValidSession()) {
        // Non c'è code nei query params, ma abbiamo token validi in localStorage
        // Questo significa che l'utente era già loggato e ha ricaricato la pagina
        print('[MainApp._initializeKeycloak] ✓ Step 2b: Found valid session in localStorage');
        print('[MainApp._initializeKeycloak] Step 3: Restoring authenticated session...');
        authNotifier.restoreSession();
        print('[MainApp._initializeKeycloak] ✓ Session restored!');
      } else {
        print('[MainApp._initializeKeycloak] Step 2c: No authorization code and no valid session - user must login');
      }
    } catch (e) {
      print('[MainApp._initializeKeycloak] ✗ Keycloak initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa ref.watch() per ascoltare il provider authStateProvider
    // Riverpod aggiorna automaticamente la UI quando lo stato cambia
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Condominio',
      home: _buildHome(authState, ref),
    );
  }

  /// BuildHome: Routing basato sullo stato di autenticazione
  /// 
  /// Riverpod e la state management professionale fanno tutto il routing automatico
  Widget _buildHome(AuthState authState, WidgetRef ref) {
    return switch (authState) {
      // Utente autenticato → mostra HomeScreen con token
      AuthState.authenticated => const HomeScreen(),
      
      // Utente non autenticato → mostra LoginScreen con bottone di login
      AuthState.unauthenticated => const LoginScreen(),
      
      // Loading (login in corso) → mostra spinner
      AuthState.loading => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Authenticating with Keycloak...'),
            ],
          ),
        ),
      ),
      
      // Errore durante il login → mostra messaggio di errore
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
                  // Retry: ripristina lo stato a unauthenticated per mostrare LoginScreen di nuovo
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
