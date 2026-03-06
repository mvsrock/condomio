import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../registry/application/condomini_notifier.dart';
import '../../registry/domain/condomino.dart';
import '../domain/admin_user.dart';
import 'admin_users_notifier.dart';

/// Elenco utenti Keycloak già filtrato dal notifier admin.
final adminUsersItemsProvider = Provider<List<AdminUser>>((ref) {
  return ref.watch(adminUsersProvider.select((state) => state.items));
});

/// Stato di creazione utenza Keycloak in corso.
final adminUsersIsCreatingProvider = Provider<bool>((ref) {
  return ref.watch(adminUsersProvider.select((state) => state.isCreating));
});

/// Messaggio errore corrente del modulo gestione accessi.
final adminUsersErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminUsersProvider.select((state) => state.errorMessage));
});

/// Elenco anagrafica corrente del condominio attivo.
final adminCondominiItemsProvider = Provider<List<Condomino>>((ref) {
  return ref.watch(condominiItemsProvider);
});
