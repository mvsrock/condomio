import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Flusso OAuth desktop con callback locale:
/// 1. avvia server HTTP in loopback (`127.0.0.1:<porta>`)
/// 2. apre browser esterno sull'authorization URL
/// 3. attende redirect di callback con `code`
/// 4. restituisce URI callback al chiamante
Future<Uri> runDesktopAuthorizationCodeFlow({
  required Uri authorizationUri,
  required Uri redirectUri,
  Duration timeout = const Duration(minutes: 2),
}) async {
  if (redirectUri.scheme != 'http' && redirectUri.scheme != 'https') {
    throw ArgumentError(
      'Desktop redirect URI must use http/https. Received: $redirectUri',
    );
  }

  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    redirectUri.port,
    shared: true,
  );
  final callbackCompleter = Completer<Uri>();

  // Listener del server locale: intercetta esclusivamente il path di callback atteso.
  late final StreamSubscription<HttpRequest> sub;
  sub = server.listen((request) async {
    final reqUri = request.uri;
    if (reqUri.path != redirectUri.path) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..headers.contentType = ContentType.html
        ..write('<html><body>Not Found</body></html>');
      await request.response.close();
      return;
    }

    final error = reqUri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      // Keycloak ha restituito errore lato autorizzazione.
      if (!callbackCompleter.isCompleted) {
        callbackCompleter.completeError(
          Exception('Authorization error: $error'),
        );
      }
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.html
        ..write(
          '<html><body>Login failed. You can close this window.</body></html>',
        );
      await request.response.close();
      return;
    }

    final code = reqUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      // Callback valida ma senza authorization code.
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.html
        ..write('<html><body>Missing authorization code.</body></html>');
      await request.response.close();
      return;
    }

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..write(
        '<html><body>Login completed. You can close this window.</body></html>',
      );
    await request.response.close();

    if (!callbackCompleter.isCompleted) {
      callbackCompleter.complete(reqUri);
    }
  });

  try {
    // Apre browser di sistema: requisito di sicurezza per OAuth pubblico.
    final launched = await launchUrl(
      authorizationUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw Exception('Unable to open browser for login.');
    }

    // Attende callback fino a timeout.
    return await callbackCompleter.future.timeout(timeout);
  } finally {
    // Cleanup risorse anche in caso di errore/timeout.
    await sub.cancel();
    await server.close(force: true);
  }
}
