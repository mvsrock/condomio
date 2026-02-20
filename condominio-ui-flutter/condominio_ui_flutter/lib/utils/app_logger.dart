import 'package:flutter/foundation.dart';

/// Logger minimale applicativo.
///
/// Scelta intenzionale:
/// - in debug/staging stampa diagnostica utile;
/// - in release evita log verbosi e dati sensibili in console.
void appLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
