import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../auth/application/keycloak_provider.dart';
import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../../home/application/home_ui_notifier.dart';
import '../../application/condomini_notifier.dart';
import '../../domain/condomino.dart';
import '../dialogs/registry_position_dialogs.dart';
import 'registry_condomino_pages.dart';
import 'registry_page.dart';

/// Container route-level della tab Anagrafica.
///
/// Responsabilita':
/// - collega `RegistryPage` allo stato UI condiviso (`homeUiProvider`)
/// - gestisce apertura dettaglio/modifica tramite `Navigator`
/// - propaga eventuali update al provider dominio `condominiProvider`
class RegistryTabPage extends ConsumerWidget {
  const RegistryTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(
      condominiProvider.select((state) => state.errorMessage),
      (previous, next) {
        if (next != null && next != previous) {
          debugPrint('[REGISTRY][uiError] $next');
        }
      },
    );

    final items = ref.watch(
      condominiItemsProvider,
    );
    final isLoading = ref.watch(condominiIsLoadingProvider);
    final error = ref.watch(condominiErrorMessageProvider);
    final selectedCondominoId = ref.watch(
      homeUiProvider.select((state) => state.selectedCondominoId),
    );
    final uiNotifier = ref.read(homeUiProvider.notifier);
    final isAdmin = ref.watch(homeIsAdminProvider);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final currentUserId = ref.watch(
      keycloakServiceProvider.select(
        (service) => service.tokenParsed?['sub']?.toString(),
      ),
    );
    final tabCount = isAdmin ? 2 : 1;

    // La tab anagrafica diventa il punto unico per:
    // - consultazione/ricerca condomini
    // - gestione accessi (solo admin)
    return DefaultTabController(
      length: tabCount,
      child: Column(
        children: [
          TabBar(
            tabs: [
              const Tab(text: 'Anagrafica'),
              if (isAdmin) const Tab(text: 'Gestione Accessi'),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                if (isLoading)
                  if (items.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildRegistryContent(
                      context: context,
                      ref: ref,
                      uiNotifier: uiNotifier,
                      isAdmin: isAdmin,
                      isReadOnly: isReadOnly,
                      currentUserId: currentUserId,
                      selectedCondominoId: selectedCondominoId,
                      error: error,
                    )
                else
                  _buildRegistryContent(
                    context: context,
                    ref: ref,
                    uiNotifier: uiNotifier,
                    isAdmin: isAdmin,
                    isReadOnly: isReadOnly,
                    currentUserId: currentUserId,
                    selectedCondominoId: selectedCondominoId,
                    error: error,
                  ),
                if (isAdmin) const AdminUsersPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistryContent({
    required BuildContext context,
    required WidgetRef ref,
    required HomeUiNotifier uiNotifier,
    required bool isAdmin,
    required bool isReadOnly,
    required String? currentUserId,
    required String? selectedCondominoId,
    required String? error,
  }) {
    return Column(
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade900),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            ),
        if (isReadOnly)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: Color(0xFF9A3412)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esercizio chiuso: anagrafica consultabile ma non modificabile.',
                        style: TextStyle(
                          color: Color(0xFF9A3412),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        Expanded(
          child: RegistryPage(
            selectedCondominoId: selectedCondominoId,
            canEditCondomino: (condomino) =>
                !isReadOnly && _canEditCondomino(condomino, isAdmin, currentUserId),
            onCondominoRowTap: (selected) =>
                uiNotifier.selectCondomino(selected.id),
            onCondominoTap: (selected) => _openCondominoDetailScreen(
              context: context,
              ref: ref,
              selected: selected,
              canEdit:
                  !isReadOnly && _canEditCondomino(selected, isAdmin, currentUserId),
            ),
            onCondominoEdit: (condomino) => _openCondominoEditScreen(
              context: context,
              ref: ref,
              condomino: condomino,
              canEdit:
                  !isReadOnly && _canEditCondomino(condomino, isAdmin, currentUserId),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCondominoDetailScreen({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino selected,
    required bool canEdit,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RegistryCondominoDetailPage(
          condomino: selected,
          canEdit: canEdit,
          onUpdated: (updated) => _saveCondominoUpdate(
            context: context,
            ref: ref,
            updated: updated,
          ),
          onDelete: (condomino) => _deleteCondominoPosition(
            context: context,
            ref: ref,
            condomino: condomino,
          ),
          onCease: (condomino) => _ceaseCondominoPosition(
            context: context,
            ref: ref,
            condomino: condomino,
          ),
          onSubentro: (condomino) => _subentraCondominoPosition(
            context: context,
            ref: ref,
            condomino: condomino,
          ),
        ),
      ),
    );
  }

  Future<Condomino> _saveCondominoUpdate({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino updated,
  }) async {
    final notifier = ref.read(condominiProvider.notifier);
    await notifier.updateCondomino(updated);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modifica salvata.')),
      );
    }
    return updated;
  }

  Future<void> _deleteCondominoPosition({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino condomino,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elimina posizione'),
        content: const Text(
          'Usa questa azione solo se l\'anagrafica e stata inserita per errore. Se esiste storico contabile, il backend blocchera l\'eliminazione.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(condominiProvider.notifier).deleteCondomino(condomino.id);
    ref.read(homeUiProvider.notifier).clearSelectedCondomino();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posizione eliminata.')),
      );
    }
  }

  Future<Condomino> _ceaseCondominoPosition({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino condomino,
  }) async {
    final result = await showDialog<RegistryCessazioneResult>(
      context: context,
      builder: (_) => RegistryCessazioneDialog(
        initialDate: DateTime.now(),
      ),
    );
    if (result == null) {
      return condomino;
    }
    final updated = await ref.read(condominiProvider.notifier).cessaCondomino(
      condominoId: condomino.id,
      dataCessazione: result.dataCessazione,
      motivo: result.motivo,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posizione cessata.')),
      );
    }
    return updated;
  }

  Future<Condomino> _subentraCondominoPosition({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino condomino,
  }) async {
    final result = await showDialog<RegistrySubentroResult>(
      context: context,
      builder: (_) => RegistrySubentroDialog(
        initialDate: DateTime.now(),
        initialNome: '',
        initialCognome: '',
        initialEmail: '',
        initialTelefono: '',
      ),
    );
    if (result == null) {
      return condomino;
    }
    final created = await ref.read(condominiProvider.notifier).subentraCondomino(
      precedenteCondominoId: condomino.id,
      nuovoCondomino: Condomino(
        id: '',
        nome: result.nome,
        cognome: result.cognome,
        scala: condomino.scala,
        interno: condomino.interno,
        email: result.email,
        telefono: result.telefono,
        saldoIniziale: result.saldoIniziale,
        millesimi: condomino.millesimi,
        residente: condomino.residente,
        ruolo: CondominoRuolo.standard,
        hasAppAccess: false,
        unitaImmobiliareId: condomino.unitaImmobiliareId,
        titolaritaTipo: condomino.titolaritaTipo,
      ),
      dataSubentro: result.dataSubentro,
      carryOverSaldo: result.carryOverSaldo,
    );
    ref.read(homeUiProvider.notifier).selectCondomino(created.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subentro registrato.')),
      );
    }
    return created;
  }

  Future<void> _openCondominoEditScreen({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino condomino,
    required bool canEdit,
  }) async {
    if (!canEdit) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non puoi modificare questo condomino.')),
        );
      }
      return;
    }

    final updated = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => RegistryCondominoEditPage(
          condomino: condomino,
          onSave: (updated) =>
              _saveCondominoUpdate(context: context, ref: ref, updated: updated),
        ),
      ),
    );
    if (!context.mounted || updated == null) {
      return;
    }
  }

  bool _canEditCondomino(Condomino condomino, bool isAdmin, String? currentUserId) {
    if (isAdmin) return true;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return condomino.keycloakUserId == currentUserId;
  }
}
