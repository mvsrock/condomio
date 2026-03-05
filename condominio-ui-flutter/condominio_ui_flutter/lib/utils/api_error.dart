import 'dart:convert';

import 'package:http/http.dart' as http;

/// Errore API normalizzato per evitare parsing duplicato nei vari client HTTP.
class ApiError implements Exception {
  ApiError({
    required this.operation,
    required this.statusCode,
    required this.technicalMessage,
    required this.userMessage,
    this.responseBody,
  });

  final String operation;
  final int statusCode;
  final String technicalMessage;
  final String userMessage;
  final String? responseBody;

  factory ApiError.fromHttp({
    required String operation,
    required http.Response response,
  }) {
    final status = response.statusCode;
    final body = response.body;
    final parsedMessage = _extractMessage(body);
    final userMessage = switch (status) {
      400 => parsedMessage ?? 'Richiesta non valida.',
      401 => 'Sessione scaduta. Effettua nuovamente il login.',
      403 => 'Operazione non consentita per il tuo profilo.',
      404 => 'Risorsa non trovata.',
      409 => parsedMessage ?? 'Conflitto dati: elemento gia\' presente.',
      _ => parsedMessage ?? 'Errore di comunicazione con il server.',
    };
    return ApiError(
      operation: operation,
      statusCode: status,
      technicalMessage: '$operation failed: status=$status, body=$body',
      userMessage: userMessage,
      responseBody: body,
    );
  }

  @override
  String toString() => userMessage;

  static String? _extractMessage(String body) {
    if (body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final direct = [
          decoded['message'],
          decoded['error'],
          decoded['detail'],
          decoded['validationMessage'],
        ];
        for (final candidate in direct) {
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
