import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_notifier.dart';
import '../../../auth/application/keycloak_provider.dart';
import '../widgets/session_token_section.dart';

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
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SessionTokenSection(
                      title: 'Access Token',
                      rawToken: keycloak.accessToken,
                      parsedToken: keycloak.tokenParsed,
                      emptyKey: 'token',
                      prettyJson: prettyJson,
                    ),
                    const SizedBox(height: 20),
                    SessionTokenSection(
                      title: 'ID Token',
                      rawToken: keycloak.idToken,
                      parsedToken: keycloak.idTokenParsed,
                      emptyKey: 'id_token',
                      prettyJson: prettyJson,
                    ),
                    const SizedBox(height: 20),
                    SessionTokenSection(
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
