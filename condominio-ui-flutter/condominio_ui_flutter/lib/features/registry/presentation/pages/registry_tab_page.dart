import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../auth/application/keycloak_provider.dart';
import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../../home/application/home_ui_notifier.dart';
import '../../application/condomini_notifier.dart';
import '../../domain/condomino.dart';
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
      condominiProvider.select((state) => state.items),
    );
    final isLoading = ref.watch(
      condominiProvider.select((state) => state.isLoading),
    );
    final error = ref.watch(
      condominiProvider.select((state) => state.errorMessage),
    );
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
          onUpdated: (updated) {
            ref.read(condominiProvider.notifier).updateCondomino(updated);
          },
        ),
      ),
    );
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
        builder: (_) => RegistryCondominoEditPage(condomino: condomino),
      ),
    );
    if (updated != null) {
      try {
        await ref.read(condominiProvider.notifier).updateCondomino(updated);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Modifica salvata.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante la modifica: $e')),
          );
        }
      }
    }
  }

  bool _canEditCondomino(Condomino condomino, bool isAdmin, String? currentUserId) {
    if (isAdmin) return true;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return condomino.keycloakUserId == currentUserId;
  }
}
