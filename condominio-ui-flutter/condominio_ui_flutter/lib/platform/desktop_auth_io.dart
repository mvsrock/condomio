import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

Future<Uri> runDesktopAuthorizationCodeFlow({
  required Uri authorizationUri,
  required Uri redirectUri,
  Duration timeout = const Duration(minutes: 2),
}) async {
  if (redirectUri.scheme != 'http' && redirectUri.scheme != 'https') {
    throw ArgumentError('Desktop redirect URI must use http/https. Received: $redirectUri');
  }

  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    redirectUri.port,
    shared: true,
  );
  final callbackCompleter = Completer<Uri>();

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
      if (!callbackCompleter.isCompleted) {
        callbackCompleter.completeError(Exception('Authorization error: $error'));
      }
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.html
        ..write('<html><body>Login failed. You can close this window.</body></html>');
      await request.response.close();
      return;
    }

    final code = reqUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
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
      ..write('<html><body>Login completed. You can close this window.</body></html>');
    await request.response.close();

    if (!callbackCompleter.isCompleted) {
      callbackCompleter.complete(reqUri);
    }
  });

  try {
    final launched = await launchUrl(
      authorizationUri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched) {
      throw Exception('Unable to open browser for login.');
    }

    return await callbackCompleter.future.timeout(timeout);
  } finally {
    await sub.cancel();
    await server.close(force: true);
  }
}
