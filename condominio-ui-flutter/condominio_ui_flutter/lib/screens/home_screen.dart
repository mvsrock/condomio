import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/keycloak_provider.dart';

/// SCHERMATA HOME (Autenticato)
/// Mostra i token JWT ricevuti da Keycloak e un bottone di logout
/// 
/// ARCHITETTURA (con Riverpod):
/// - ConsumerWidget per accedere ai provider
/// - Usa ref.read(keycloakServiceProvider) per accedere al servizio
/// - Usa ref.read(authStateProvider.notifier).logout() per il logout
/// - Riverpod gestisce automaticamente lo stato e la reattività UI
///
/// COSA VEDI:
/// 1. Access Token (raw) - la stringa JWT completa
/// 2. Access Token (parsed) - il payload decodificato come JSON
/// 3. ID Token (raw) - il JWT con info dell'utente
/// 4. ID Token (parsed) - il payload del JWT decodificato
/// 5. Bottone Logout - disconnette l'utente e passa a LoginScreen
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Traccia se siamo nel mezzo di un logout (per mostrare spinner)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Accedi al servizio Keycloak per logare lo stato dei token
    final keycloak = ref.read(keycloakServiceProvider);
    
    print('[HomeScreen] User is authenticated: ${keycloak.isAuthenticated}');
    print('[HomeScreen] Has access token: ${keycloak.accessToken != null}');
    print('[HomeScreen] Has ID token: ${keycloak.idToken != null}');
  }

  /// Effettua il logout usando Riverpod:
  /// 1. Chiama ref.read(authStateProvider.notifier).logout()
  /// 2. AuthNotifier.logout() chiama keycloak.logout()
  /// 3. AuthNotifier emette lo stato 'unauthenticated'
  /// 4. RiverPod aggiorna la UI → MainApp vede lo stato e passa a LoginScreen
  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      print('[HomeScreen] Initiating logout...');
      
      // Accedi al notifier del provider authStateProvider e chiama logout()
      await ref.read(authStateProvider.notifier).logout();
      
      // Non serve fare nulla qui - AuthNotifier ha già emesso 'unauthenticated'
      // MainApp ascolterà il cambiamento e passerà automaticamente a LoginScreen
    } catch (e) {
      print('[HomeScreen] Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accedi al servizio Keycloak per leggere i token
    final keycloak = ref.watch(keycloakServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Condominio - Authenticated')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Login successful!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // CARD: Mostra i token ricevuti da Keycloak
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Access Token Raw
                          const Text(
                            'Access Token (JWT string):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            keycloak.accessToken?.substring(0, 100) ?? 'N/A',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 16),
                          
                          // Access Token Parsed (JSON)
                          if (keycloak.tokenParsed != null) ...[
                            const Text(
                              'Access Token (parsed JSON):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SelectableText(
                              const JsonEncoder.withIndent('  ')
                                  .convert(keycloak.tokenParsed),
                              style: const TextStyle(fontSize: 9),
                            ),
                            const SizedBox(height: 16),
                          ],
                          
                          // ID Token Raw
                          const Text(
                            'ID Token (JWT string):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(
                            keycloak.idToken?.substring(0, 100) ?? 'N/A',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(height: 16),
                          
                          // ID Token Parsed (JSON)
                          if (keycloak.idTokenParsed != null) ...[
                            const Text(
                              'ID Token (parsed JSON):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SelectableText(
                              const JsonEncoder.withIndent('  ')
                                  .convert(keycloak.idTokenParsed),
                              style: const TextStyle(fontSize: 9),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bottone Logout
                  ElevatedButton(
                    onPressed: _logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
    );
  }
}
