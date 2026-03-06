import 'dart:convert';

import 'package:flutter/material.dart';

/// Sezione diagnostica per singolo token Keycloak.
class SessionTokenSection extends StatelessWidget {
  const SessionTokenSection({
    super.key,
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
