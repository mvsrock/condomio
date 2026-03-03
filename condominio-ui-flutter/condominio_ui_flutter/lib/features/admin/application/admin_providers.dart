import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_api_client.dart';

/// Provider condiviso per il client HTTP dell'area amministrazione.
final adminApiClientProvider = Provider<AdminApiClient>((ref) {
  return const AdminApiClient();
});
