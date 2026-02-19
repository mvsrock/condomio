import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/condomini_provider.dart';
import '../providers/keycloak_provider.dart';
import '../providers/map_provider.dart';
import '../services/keycloak_service.dart';
import '../widgets/openlayers_map.dart';

/// Schermata visibile quando la sessione e' autenticata.
///
/// Layout:
/// - menu di navigazione interno (`Dashboard`, `Mappa`, `Sessione`)
/// - contenuto principale reattivo alla voce selezionata
/// - azione logout sempre disponibile
///
/// FLUSSO STEP-BY-STEP (logout):
/// 1. Utente preme `Logout`.
/// 2. `_logout()` chiama `authStateProvider.notifier.logout()`.
/// 3. Il notifier chiama `KeycloakService.logout()`.
/// 4. Lo stato passa a `unauthenticated`.
/// 5. `MainApp` ricostruisce la home e mostra `LoginScreen`.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  /// Mostra overlay/spinner mentre e' in corso il logout.
  bool _isLoading = false;

  /// Tab corrente della UI:
  /// 0 = Dashboard, 1 = Mappa, 2 = Anagrafica, 3 = Sessione.
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final keycloak = ref.read(keycloakServiceProvider);
    print('[HomeScreen] User is authenticated: ${keycloak.isAuthenticated}');
    print('[HomeScreen] Has access token: ${keycloak.accessToken != null}');
    print('[HomeScreen] Has ID token: ${keycloak.idToken != null}');
  }

  Future<void> _logout() async {
    // Blocca UI durante logout per evitare doppio tap.
    setState(() => _isLoading = true);
    try {
      print('[HomeScreen] Initiating logout...');
      await ref.read(authStateProvider.notifier).logout();
    } catch (e) {
      print('[HomeScreen] Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keycloak = ref.watch(keycloakServiceProvider);
    final size = MediaQuery.of(context).size;

    // Breakpoint principale: oltre 960 usiamo rail desktop, altrimenti bottom nav.
    final isWide = size.width >= 960;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        // Sfondo gradient per dare profondita' visiva alla dashboard.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Navigazione laterale solo su layout larghi (desktop/tablet landscape).
              if (isWide) _buildRail(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Header fisso con branding + action logout.
                      _buildHeader(context),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AnimatedSwitcher(
                          // Transizione dolce tra pagine menu.
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            // Chiave legata all'indice per forzare il cambio child.
                            key: ValueKey(_selectedIndex),
                            child: _buildPage(keycloak),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              // Variante mobile della navigazione.
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Mappa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.badge_outlined),
                  selectedIcon: Icon(Icons.badge),
                  label: 'Anagrafica',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Sessione',
                ),
              ],
            ),
    );
  }

  Widget _buildRail(BuildContext context) {
    // Variante desktop/tablet: rail con etichette sempre visibili.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          labelType: NavigationRailLabelType.all,
          minWidth: 92,
          backgroundColor: Colors.white,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: Text('Mappa'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.badge_outlined),
              selectedIcon: Icon(Icons.badge),
              label: Text('Anagrafica'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: Text('Sessione'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    // Header informativo principale della dashboard autenticata.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(Icons.apartment_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Condominio Control Center',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Interfaccia professionale multi piattaforma',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF486581),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            // Logout disponibile da qualsiasi sezione.
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(KeycloakService keycloak) {
    // Router interno della home basato su indice menu selezionato.
    return switch (_selectedIndex) {
      0 => _buildDashboardPage(keycloak),
      1 => _buildMapPage(),
      2 => _buildRegistryPage(),
      _ => _buildSessionPage(keycloak),
    };
  }

  Widget _buildDashboardPage(KeycloakService keycloak) {
    // Lettura claims token per popolare KPI rapidi.
    final tokenPayload = keycloak.tokenParsed;
    final username =
        tokenPayload?['preferred_username'] ??
        tokenPayload?['name'] ??
        tokenPayload?['email'] ??
        'Utente';
    final roleCount =
        (tokenPayload?['realm_access']?['roles'] as List?)?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            // Card responsive: 3 colonne su schermi ampi, 1 colonna su schermi stretti.
            crossAxisCount: MediaQuery.of(context).size.width >= 1280 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.6,
            children: [
              _statCard(
                title: 'Utente autenticato',
                value: '$username',
                subtitle: 'Sessione attiva su Keycloak',
                icon: Icons.verified_user,
              ),
              _statCard(
                title: 'Ruoli rilevati',
                value: '$roleCount',
                subtitle: 'Dai claims del token',
                icon: Icons.security,
              ),
              _statCard(
                title: 'Piattaforma',
                value: Theme.of(context).platform.name,
                subtitle: 'Build multi piattaforma',
                icon: Icons.devices,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPage() {
    // Pagina mappa: dati mappa da provider comune, rendering delegato al widget cross-platform.
    final mapState = ref.watch(mapStateProvider);
    final mapNotifier = ref.read(mapStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mappa OpenLayers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: mapState.isLoadingLocation
                  ? null
                  : () => mapNotifier.refreshCurrentLocation(),
              icon: const Icon(Icons.my_location),
              label: const Text('Aggiorna posizione'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          mapState.statusMessage,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF486581)),
        ),
        const SizedBox(height: 12),
        Expanded(child: OpenLayersMap(mapState: mapState)),
      ],
    );
  }

  Widget _buildSessionPage(KeycloakService keycloak) {
    // Pagina di ispezione sessione: espone payload token in JSON.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sessione',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Access Token (parsed JSON)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      // JSON leggibile per debug claims access token.
                      const JsonEncoder.withIndent(
                        '  ',
                      ).convert(keycloak.tokenParsed ?? const {'token': 'N/A'}),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ID Token (parsed JSON)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      // JSON leggibile per debug claims id token.
                      const JsonEncoder.withIndent('  ').convert(
                        keycloak.idTokenParsed ?? const {'id_token': 'N/A'},
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Pagina anagrafica condomini.
  ///
  /// I dati arrivano da Riverpod (`condominiProvider`), cosi' in futuro
  /// si puo' passare a repository/API senza cambiare la UI.
  Widget _buildRegistryPage() {
    final condomini = ref.watch(condominiProvider);
    final residenti = condomini.where((c) => c.residente).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anagrafica Condomini',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoChip(
              label: 'Totale condomini: ${condomini.length}',
              icon: Icons.people_alt_outlined,
            ),
            _infoChip(
              label: 'Residenti: $residenti',
              icon: Icons.home_outlined,
            ),
            _infoChip(
              label: 'Non residenti: ${condomini.length - residenti}',
              icon: Icons.business_center_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: condomini.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = condomini[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F0F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF155E75),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.nominativo,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${c.unita} • Millesimi ${c.millesimi.toStringAsFixed(2)}',
                              style: const TextStyle(color: Color(0xFF52606D)),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${c.email} • ${c.telefono}',
                              style: const TextStyle(
                                color: Color(0xFF7B8794),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          c.residente ? 'Residente' : 'Non residente',
                        ),
                        backgroundColor: c.residente
                            ? const Color(0xFFE3FCEF)
                            : const Color(0xFFFFF4E5),
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Chip info riusabile per testata anagrafica.
  Widget _infoChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF334E68)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    // Componente riusabile per le card KPI della dashboard.
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF155E75)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF486581),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7B8794),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
