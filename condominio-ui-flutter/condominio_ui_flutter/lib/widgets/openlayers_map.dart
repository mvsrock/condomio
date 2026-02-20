import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_state.dart';

/// Widget mappa unico cross-platform (web/mobile/desktop) basato su flutter_map.
///
/// Tutte le piattaforme usano lo stesso renderer OSM.
/// I dati (centro, marker, stato) arrivano dal layer comune `MapState`.
class OpenLayersMap extends StatefulWidget {
  const OpenLayersMap({super.key, required this.mapState});

  final MapState mapState;

  @override
  State<OpenLayersMap> createState() => _OpenLayersMapState();
}

class _OpenLayersMapState extends State<OpenLayersMap> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(covariant OpenLayersMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCenter = oldWidget.mapState.center;
    final newCenter = widget.mapState.center;
    if (oldCenter.latitude != newCenter.latitude ||
        oldCenter.longitude != newCenter.longitude) {
      _mapController.move(LatLng(newCenter.latitude, newCenter.longitude), 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.mapState.center;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(center.latitude, center.longitude),
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'it.mvs.condominiouiflutter',
              ),
              MarkerLayer(
                markers: widget.mapState.markers
                    .map(
                      (point) => Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 38,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                border: Border.all(color: const Color(0xFFD9E2EC)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'OSM (flutter_map) cross-platform',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
