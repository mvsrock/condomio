import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/keycloak_provider.dart';

/// Pagina diagnostica sessione/token.
///
/// Mostra i token in formato JSON per uniformita' di lettura/debug.
class SessionPage extends ConsumerWidget {
  const SessionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keycloak = ref.watch(keycloakServiceProvider);
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
                      ).convert(
                        keycloak.tokenParsed ?? const {'token': 'N/A'},
                      ),
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
                    const SizedBox(height: 20),
                    const Text(
                      'Refresh Token (parsed JSON)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      const JsonEncoder.withIndent('  ').convert(
                        keycloak.refreshTokenParsed ??
                            const {'refresh_token': 'N/A'},
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
}
