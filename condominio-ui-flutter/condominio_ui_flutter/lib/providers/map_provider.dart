import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/map_state.dart';

/// StateNotifier mappa:
/// - centralizza geolocalizzazione
/// - produce centro + marker comuni a tutte le piattaforme
///
/// PERCHE' ESISTE:
/// - Il renderer UI (`OpenLayersMap`) puo' cambiare nel tempo.
/// - La logica mappa deve vivere in un solo posto.
/// - Qui decidiamo *cosa* mostrare (centro, marker, stato), non *come* disegnarlo.
class MapNotifier extends StateNotifier<MapState> {
  /// Costruttore:
  /// 1. carica stato iniziale (`MapState.initial()`)
  /// 2. avvia subito il primo tentativo di geolocalizzazione
  MapNotifier() : super(MapState.initial()) {
    refreshCurrentLocation();
  }

  /// Ricalcola la posizione corrente e aggiorna marker/centro.
  ///
  /// FLUSSO STEP-BY-STEP:
  /// 1. imposta stato loading per mostrare feedback in UI
  /// 2. verifica che il servizio GPS sia attivo
  /// 3. verifica/richiede permessi runtime
  /// 4. legge lat/lon correnti
  /// 5. aggiorna stato condiviso (centro + marker + messaggio)
  /// 6. in caso di errore usa fallback senza crash
  Future<void> refreshCurrentLocation() async {
    // Step 1: la UI puo' mostrare "Rilevazione posizione..." mentre attendiamo.
    state = state.copyWith(
      isLoadingLocation: true,
      statusMessage: 'Rilevazione posizione...',
    );

    try {
      // Step 2: se il GPS/servizio localizzazione e' disattivato,
      // non possiamo continuare. Manteniamo il fallback iniziale.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          statusMessage: 'GPS disattivato: uso posizione predefinita.',
        );
        return;
      }

      // Step 3: controllo permessi.
      // Se e' "denied", proviamo a chiedere il permesso all'utente.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Step 3b: se resta negato (o negato per sempre), usiamo fallback.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          statusMessage:
              'Permesso posizione negato: uso posizione predefinita.',
        );
        return;
      }

      // Step 4: posizione reale del dispositivo.
      // Accuratezza alta per avere marker/centro piu' affidabili.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Trasformazione dal tipo del plugin (`Position`) al nostro modello comune.
      final current = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Step 5: aggiornamento centralizzato:
      // - `center` sposta la mappa
      // - `markers` decide dove renderizzare i marker
      // - `statusMessage` aggiorna il testo in UI
      state = state.copyWith(
        center: current,
        markers: [current],
        isLoadingLocation: false,
        statusMessage: 'Posizione attuale rilevata.',
      );
    } catch (_) {
      // Step 6: qualsiasi errore non deve rompere la schermata.
      // Restiamo sul fallback e segnaliamo lo stato.
      state = state.copyWith(
        isLoadingLocation: false,
        statusMessage: 'Impossibile leggere la posizione: uso fallback.',
      );
    }
  }
}

/// Provider globale Riverpod della mappa.
///
/// Uso:
/// - `ref.watch(mapStateProvider)` per leggere stato corrente in UI
/// - `ref.read(mapStateProvider.notifier).refreshCurrentLocation()` per aggiornare
final mapStateProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});
