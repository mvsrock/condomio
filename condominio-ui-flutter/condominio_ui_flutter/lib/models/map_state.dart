/// Punto geografico semplice indipendente dalla libreria di rendering mappa.
class GeoPoint {
  const GeoPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Stato comune della mappa usato da web/mobile/desktop.
///
/// Questo e' il single source of truth:
/// i renderer piattaforma leggono solo questi dati.
class MapState {
  const MapState({
    required this.center,
    required this.markers,
    required this.isLoadingLocation,
    required this.statusMessage,
  });

  final GeoPoint center;
  final List<GeoPoint> markers;
  final bool isLoadingLocation;
  final String statusMessage;

  factory MapState.initial() {
    const fallback = GeoPoint(latitude: 41.9028, longitude: 12.4964);
    return const MapState(
      center: fallback,
      markers: [fallback],
      isLoadingLocation: true,
      statusMessage: 'Rilevazione posizione...',
    );
  }

  MapState copyWith({
    GeoPoint? center,
    List<GeoPoint>? markers,
    bool? isLoadingLocation,
    String? statusMessage,
  }) {
    return MapState(
      center: center ?? this.center,
      markers: markers ?? this.markers,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
