import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/map_notifier.dart';
import '../widgets/openlayers_map.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoadingLocation = ref.watch(
      mapStateProvider.select((state) => state.isLoadingLocation),
    );
    final statusMessage = ref.watch(
      mapStateProvider.select((state) => state.statusMessage),
    );
    final center = ref.watch(
      mapStateProvider.select((state) => state.center),
    );
    final markers = ref.watch(
      mapStateProvider.select((state) => state.markers),
    );
    final mapNotifier = ref.read(mapStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: isLoadingLocation
                ? null
                : () => mapNotifier.refreshCurrentLocation(),
            icon: const Icon(Icons.my_location),
            label: const Text('Aggiorna posizione'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusMessage,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF486581)),
        ),
        const SizedBox(height: 12),
        Expanded(child: OpenLayersMap(center: center, markers: markers)),
      ],
    );
  }
}
