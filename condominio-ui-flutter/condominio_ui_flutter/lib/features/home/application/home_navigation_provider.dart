import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/application/keycloak_provider.dart';
import '../presentation/models/home_nav_destination.dart';

/// Ruolo realm usato per abilitare le sezioni amministrative in Home.
const String kHomeAdminRole = 'amministratore';
const int kHomeBranchDashboard = 0;
const int kHomeBranchMap = 1;
const int kHomeBranchRegistry = 2;
const int kHomeBranchSession = 3;
const int kHomeBranchDocuments = 4;
const int kHomeBranchPortal = 5;

/// True quando l'utente corrente puo' vedere le sezioni admin Home.
///
/// Nota: osserva `authSessionRevisionProvider` per aggiornarsi anche se lo stato
/// auth resta "authenticated" ma cambiano i token/claims (refresh sessione).
final homeIsAdminProvider = Provider<bool>((ref) {
  ref.watch(authSessionRevisionProvider);
  final keycloak = ref.watch(keycloakServiceProvider);
  return keycloak.hasRealmRole(kHomeAdminRole);
});

/// Lista destinazioni effettivamente visibili nella shell Home.
///
/// La UI (`presentation`) renderizza questa lista senza conoscere regole ruolo.
final homeDestinationsProvider = Provider<List<HomeNavDestination>>((ref) {
  final isAdmin = ref.watch(homeIsAdminProvider);
  if (!isAdmin) {
    return <HomeNavDestination>[
      const HomeNavDestination(
        branchIndex: kHomeBranchPortal,
        label: 'Portale',
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
      const HomeNavDestination(
        branchIndex: kHomeBranchSession,
        label: 'Sessione',
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
      ),
    ];
  }
  return <HomeNavDestination>[
    const HomeNavDestination(
      branchIndex: kHomeBranchDashboard,
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    const HomeNavDestination(
      branchIndex: kHomeBranchMap,
      label: 'Mappa',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
    ),
    const HomeNavDestination(
      branchIndex: kHomeBranchRegistry,
      label: 'Anagrafica',
      icon: Icons.badge_outlined,
      selectedIcon: Icons.badge,
    ),
    const HomeNavDestination(
      branchIndex: kHomeBranchSession,
      label: 'Sessione',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
  ];
});

/// Mappa branch router -> indice visibile nella lista destinazioni.
int visibleIndexForBranch(
  List<HomeNavDestination> destinations,
  int branchIndex,
) {
  return destinations.indexWhere((d) => d.branchIndex == branchIndex);
}

/// Mappa indice visibile -> branch router.
int branchIndexForVisibleIndex(
  List<HomeNavDestination> destinations,
  int visibleIndex,
) {
  return destinations[visibleIndex].branchIndex;
}
