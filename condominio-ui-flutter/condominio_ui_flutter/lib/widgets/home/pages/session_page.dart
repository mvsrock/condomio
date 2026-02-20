import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../services/keycloak_service.dart';

/// Pagina diagnostica sessione/token.
///
/// Nota sicurezza:
/// - il refresh token e' sensibile;
/// - viene mostrato mascherato di default e rivelato solo su azione esplicita.
class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.keycloak});

  final KeycloakService keycloak;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  /// Flag puramente visuale locale: mostra/nasconde token sensibile.
  ///
  /// Non serve in provider globale perche' non influenza altri widget/pagine.
  bool _showRefreshToken = false;

  @override
  Widget build(BuildContext context) {
    final refreshToken = widget.keycloak.refreshToken;
    final maskedRefreshToken = _maskToken(refreshToken);

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
                        widget.keycloak.tokenParsed ?? const {'token': 'N/A'},
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
                        widget.keycloak.idTokenParsed ??
                            const {'id_token': 'N/A'},
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Refresh Token',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _showRefreshToken = !_showRefreshToken);
                          },
                          icon: Icon(
                            _showRefreshToken
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          label: Text(
                            _showRefreshToken ? 'Nascondi' : 'Mostra',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _showRefreshToken ? (refreshToken ?? 'N/A') : maskedRefreshToken,
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

  /// Mostra solo inizio/fine token per ridurre esposizione accidentale in UI.
  String _maskToken(String? token) {
    if (token == null || token.isEmpty) return 'N/A';
    if (token.length <= 12) return '************';
    final start = token.substring(0, 6);
    final end = token.substring(token.length - 6);
    return '$start...$end';
  }
}
