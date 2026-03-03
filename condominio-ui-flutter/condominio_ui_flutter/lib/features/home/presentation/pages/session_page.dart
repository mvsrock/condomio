import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_notifier.dart';
import '../../../auth/application/keycloak_provider.dart';

/// Pagina diagnostica sessione/token.
///
/// Mostra i token in formato JSON per uniformita' di lettura/debug.
class SessionPage extends ConsumerWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authSessionRevisionProvider);
    final keycloak = ref.watch(keycloakServiceProvider);
    final prettyJson = const JsonEncoder.withIndent('  ');
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
                    _TokenSection(
                      title: 'Access Token',
                      rawToken: keycloak.accessToken,
                      parsedToken: keycloak.tokenParsed,
                      emptyKey: 'token',
                      prettyJson: prettyJson,
                    ),
                    const SizedBox(height: 20),
                    _TokenSection(
                      title: 'ID Token',
                      rawToken: keycloak.idToken,
                      parsedToken: keycloak.idTokenParsed,
                      emptyKey: 'id_token',
                      prettyJson: prettyJson,
                    ),
                    const SizedBox(height: 20),
                    _TokenSection(
                      title: 'Refresh Token',
                      rawToken: keycloak.refreshToken,
                      parsedToken: keycloak.refreshTokenParsed,
                      emptyKey: 'refresh_token',
                      prettyJson: prettyJson,
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
}

class _TokenSection extends StatelessWidget {
  const _TokenSection({
    required this.title,
    required this.rawToken,
    required this.parsedToken,
    required this.emptyKey,
    required this.prettyJson,
  });

  final String title;
  final String? rawToken;
  final Map<String, dynamic>? parsedToken;
  final String emptyKey;
  final JsonEncoder prettyJson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'Raw',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SelectableText(rawToken ?? 'N/A', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
        const Text(
          'Parsed JSON',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
        const SizedBox(height: 6),
        SelectableText(
          prettyJson.convert(parsedToken ?? {emptyKey: 'N/A'}),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
