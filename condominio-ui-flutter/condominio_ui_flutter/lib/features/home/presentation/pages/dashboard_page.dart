import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/keycloak_provider.dart';
import '../widgets/dashboard_stat_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keycloak = ref.watch(keycloakServiceProvider);
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
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width >= 1280 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.6,
            children: [
              DashboardStatCard(
                title: 'Utente autenticato',
                value: '$username',
                subtitle: 'Sessione attiva su Keycloak',
                icon: Icons.verified_user,
              ),
              DashboardStatCard(
                title: 'Ruoli rilevati',
                value: '$roleCount',
                subtitle: 'Dai claims del token',
                icon: Icons.security,
              ),
              DashboardStatCard(
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
}
