import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/map_provider.dart';
import '../../openlayers_map.dart';

class MapPage extends ConsumerWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapStateProvider);
    final mapNotifier = ref.read(mapStateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mappa Condominio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: mapState.isLoadingLocation
                  ? null
                  : () => mapNotifier.refreshCurrentLocation(),
              icon: const Icon(Icons.my_location),
              label: const Text('Aggiorna posizione'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          mapState.statusMessage,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF486581)),
        ),
        const SizedBox(height: 12),
        Expanded(child: OpenLayersMap(mapState: mapState)),
      ],
    );
  }
}
