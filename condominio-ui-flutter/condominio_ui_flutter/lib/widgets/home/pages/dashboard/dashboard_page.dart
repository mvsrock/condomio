import 'package:flutter/material.dart';

import '../../../../services/keycloak_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.keycloak});

  final KeycloakService keycloak;

  @override
  Widget build(BuildContext context) {
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
              _StatCard(
                title: 'Utente autenticato',
                value: '$username',
                subtitle: 'Sessione attiva su Keycloak',
                icon: Icons.verified_user,
              ),
              _StatCard(
                title: 'Ruoli rilevati',
                value: '$roleCount',
                subtitle: 'Dai claims del token',
                icon: Icons.security,
              ),
              _StatCard(
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
