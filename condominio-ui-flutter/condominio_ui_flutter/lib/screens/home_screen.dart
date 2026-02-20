import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/condomino.dart';
import '../providers/auth_provider.dart';
import '../providers/condomini_provider.dart';
import '../providers/keycloak_provider.dart';
import '../providers/map_provider.dart';
import '../services/keycloak_service.dart';
import '../widgets/openlayers_map.dart';

/// Schermata visibile quando la sessione e' autenticata.
///
/// Layout:
/// - menu di navigazione interno (`Dashboard`, `Mappa`, `Anagrafica`, `Sessione`)
/// - contenuto principale reattivo alla voce selezionata
/// - azione logout sempre disponibile
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

  /// Riga anagrafica selezionata (click/tap).
  String? _selectedCondominoId;

  /// Riga anagrafica in hover (desktop/web).
  String? _hoveredCondominoId;

  @override
  void initState() {
    super.initState();

    final keycloak = ref.read(keycloakServiceProvider);
    print('[HomeScreen] User is authenticated: ${keycloak.isAuthenticated}');
    print('[HomeScreen] Has access token: ${keycloak.accessToken != null}');
    print('[HomeScreen] Has ID token: ${keycloak.idToken != null}');
  }

  Future<void> _logout() async {
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
    final isWide = size.width >= 960;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
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
              if (isWide) _buildRail(context),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(isWide ? 0 : 20, 20, 20, 20),
                  child: Column(
                    children: [
                      _buildHeader(context, isWide),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: isWide ? 20 : 0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: KeyedSubtree(
                              key: ValueKey(_selectedIndex),
                              child: _buildPage(keycloak),
                            ),
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
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFD9E2EC))),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 14,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
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
              ),
            ),
    );
  }

  Widget _buildRail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(24),
        ),
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

  Widget _buildHeader(BuildContext context, bool isWide) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isWide
            ? const BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            : BorderRadius.circular(20),
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
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(KeycloakService keycloak) {
    return switch (_selectedIndex) {
      0 => _buildDashboardPage(keycloak),
      1 => _buildMapPage(),
      2 => _buildRegistryPage(),
      _ => _buildSessionPage(keycloak),
    };
  }

  Widget _buildDashboardPage(KeycloakService keycloak) {
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
    final mapState = ref.watch(mapStateProvider);
    final mapNotifier = ref.read(mapStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mappa Condominio',
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
          child: Column(
            children: [
              _buildRegistryTableHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: condomini.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final c = condomini[index];
                    return _buildRegistryRow(c);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistryTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nominativo',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Unita',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              'Millesimi',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              'Stato',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistryRow(Condomino c) {
    final isSelected = _selectedCondominoId == c.id;
    final isHovered = _hoveredCondominoId == c.id;

    Color rowColor = Colors.white;
    if (isSelected) {
      rowColor = const Color(0xFFDCECF3);
    } else if (isHovered) {
      rowColor = const Color(0xFFF1F5F9);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredCondominoId = c.id),
      onExit: (_) => setState(() => _hoveredCondominoId = null),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() => _selectedCondominoId = c.id);
          _openCondominoDetailOverlay(c);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: rowColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF155E75)
                  : const Color(0xFFD9E2EC),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  c.nominativo,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(flex: 2, child: Text(c.unita)),
              Expanded(child: Text(c.millesimi.toStringAsFixed(2))),
              Expanded(
                child: Text(
                  c.residente ? 'Residente' : 'Non residente',
                  style: TextStyle(
                    color: c.residente
                        ? const Color(0xFF147D64)
                        : const Color(0xFFB9770E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay dettaglio condomino:
  /// compare solo dopo click/tap su una riga anagrafica.
  void _openCondominoDetailOverlay(Condomino selected) {
    final isWide = MediaQuery.of(context).size.width >= 960;

    if (!isWide) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return _buildDetailSheetContainer(
            selected: selected,
            isBottomSheet: true,
          );
        },
      );
      return;
    }

    showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Dettaglio condomino',
      barrierDismissible: true,
      barrierColor: const Color(0x55000000),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: _buildDetailSheetContainer(
            selected: selected,
            isBottomSheet: false,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);
        final fade = Tween<double>(begin: 0, end: 1).animate(animation);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  /// Contenitore visuale della scheda dettaglio.
  Widget _buildDetailSheetContainer({
    required Condomino selected,
    required bool isBottomSheet,
  }) {
    final radius = isBottomSheet
        ? const BorderRadius.vertical(top: Radius.circular(24))
        : const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          );

    final width = isBottomSheet ? double.infinity : 460.0;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        margin: isBottomSheet
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(0, 20, 20, 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(-2, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Scheda Dettaglio',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _detailRow('ID', selected.id),
              _detailRow('Nominativo', selected.nominativo),
              _detailRow('Unita', selected.unita),
              _detailRow('Email', selected.email),
              _detailRow('Telefono', selected.telefono),
              _detailRow('Millesimi', selected.millesimi.toStringAsFixed(2)),
              _detailRow(
                'Stato',
                selected.residente ? 'Residente' : 'Non residente',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF52606D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSessionPage(KeycloakService keycloak) {
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
