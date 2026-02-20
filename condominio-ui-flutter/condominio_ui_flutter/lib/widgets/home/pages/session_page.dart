import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/keycloak_service.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key, required this.keycloak});

  final KeycloakService keycloak;

  @override
  Widget build(BuildContext context) {
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
}
