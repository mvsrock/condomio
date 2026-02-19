import 'dart:async';

Future<Uri> runDesktopAuthorizationCodeFlow({
  required Uri authorizationUri,
  required Uri redirectUri,
  Duration timeout = const Duration(minutes: 2),
}) async {
  throw UnsupportedError('Desktop authorization flow is not available on this platform.');
}
