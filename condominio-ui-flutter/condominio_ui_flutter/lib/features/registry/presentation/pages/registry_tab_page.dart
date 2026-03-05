import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/application/admin_users_notifier.dart';
import '../../../admin/domain/admin_user.dart';
import '../../../admin/presentation/pages/admin_users_page.dart';
import '../../../auth/application/keycloak_provider.dart';
import '../../../home/application/home_navigation_provider.dart';
import '../../../home/application/home_ui_notifier.dart';
import '../../application/condomini_notifier.dart';
import '../../domain/condomino.dart';
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
        Expanded(
          child: RegistryPage(
            selectedCondominoId: selectedCondominoId,
            canEditCondomino: (condomino) =>
                _canEditCondomino(condomino, isAdmin, currentUserId),
            onCondominoRowTap: (selected) =>
                uiNotifier.selectCondomino(selected.id),
            onCondominoTap: (selected) => _openCondominoDetailScreen(
              context: context,
              ref: ref,
              selected: selected,
              canEdit: _canEditCondomino(selected, isAdmin, currentUserId),
            ),
            onCondominoEdit: (condomino) => _openCondominoEditScreen(
              context: context,
              ref: ref,
              condomino: condomino,
              canEdit: _canEditCondomino(condomino, isAdmin, currentUserId),
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
        builder: (_) => _CondominoDetailScreen(
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
        builder: (_) => _CondominoEditScreen(condomino: condomino),
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

class _CondominoDetailScreen extends StatefulWidget {
  const _CondominoDetailScreen({
    required this.condomino,
    required this.canEdit,
    required this.onUpdated,
  });

  final Condomino condomino;
  final bool canEdit;
  final ValueChanged<Condomino> onUpdated;

  @override
  State<_CondominoDetailScreen> createState() => _CondominoDetailScreenState();
}

class _CondominoDetailScreenState extends State<_CondominoDetailScreen> {
  late Condomino _current;

  @override
  void initState() {
    super.initState();
    _current = widget.condomino;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio condomino'),
        actions: [
          if (widget.canEdit)
            FilledButton.tonalIcon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Modifica'),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0F4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFF155E75),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _current.nominativo,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _current.unita,
                                      style: const TextStyle(
                                        color: Color(0xFF486581),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ValuePill(label: 'ID', value: _current.id),
                            _ValuePill(
                              label: 'Unita',
                              value: _current.unita,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DetailRow(label: 'Email', value: _current.email),
                        _DetailRow(label: 'Telefono', value: _current.telefono),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => _CondominoEditScreen(condomino: _current),
      ),
    );
    if (updated == null) return;
    widget.onUpdated(updated);
    if (!mounted) return;
    setState(() => _current = updated);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF52606D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CondominoEditScreen extends ConsumerStatefulWidget {
  const _CondominoEditScreen({required this.condomino});

  final Condomino condomino;

  @override
  ConsumerState<_CondominoEditScreen> createState() =>
      _CondominoEditScreenState();
}

class _CondominoEditScreenState extends ConsumerState<_CondominoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cognomeController;
  late final TextEditingController _scalaController;
  late final TextEditingController _internoController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _saldoInizialeController;
  late final TextEditingController _keycloakUsernameController;
  bool _hasAppAccess = false;
  String? _selectedKeycloakUserId;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.condomino.nome);
    _cognomeController = TextEditingController(text: widget.condomino.cognome);
    _scalaController = TextEditingController(text: widget.condomino.scala);
    _internoController = TextEditingController(text: widget.condomino.interno);
    _emailController = TextEditingController(text: widget.condomino.email);
    _telefonoController = TextEditingController(text: widget.condomino.telefono);
    _saldoInizialeController = TextEditingController(
      text: widget.condomino.saldoIniziale.toStringAsFixed(2),
    );
    _keycloakUsernameController = TextEditingController(
      text: widget.condomino.keycloakUsername ?? '',
    );
    // In modifica mostriamo stato accesso applicativo persistito sul condomino.
    _hasAppAccess = widget.condomino.hasAppAccess;
    _selectedKeycloakUserId = widget.condomino.keycloakUserId;
    Future.microtask(() => ref.read(adminUsersProvider.notifier).loadUsers());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _scalaController.dispose();
    _internoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _saldoInizialeController.dispose();
    _keycloakUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keycloakUsers = ref.watch(
      adminUsersProvider.select((state) => state.items),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica condomino'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dati anagrafici',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nomeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Campo obbligatorio'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cognomeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cognome',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Campo obbligatorio'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _scalaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Scala',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _internoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Interno',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Contatti',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(labelText: 'Telefono'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _saldoInizialeController,
                            decoration: const InputDecoration(labelText: 'Saldo iniziale'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
                              if (parsed == null) return 'Numero non valido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Accesso App (Keycloak)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Accesso app abilitato'),
                            value: _hasAppAccess,
                            onChanged: (value) => setState(() {
                              _hasAppAccess = value;
                              // Se l'accesso viene disabilitato da UI,
                              // azzeriamo l'associazione utente.
                              if (!value) {
                                _selectedKeycloakUserId = null;
                                _keycloakUsernameController.clear();
                              }
                            }),
                          ),
                          if (_hasAppAccess) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: keycloakUsers.any(
                                (u) => u.userId == _selectedKeycloakUserId,
                              )
                                  ? _selectedKeycloakUserId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Utente Keycloak',
                              ),
                              items: keycloakUsers
                                  .map(
                                    (u) => DropdownMenuItem<String>(
                                      value: u.userId,
                                      child: Text('${u.username} (${u.email})'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _selectedKeycloakUserId = value);
                                final user = _findAdminUserById(
                                  keycloakUsers,
                                  value,
                                );
                                _keycloakUsernameController.text =
                                    user?.username ?? '';
                              },
                              validator: (value) {
                                if (!_hasAppAccess) return null;
                                if (value == null || value.trim().isEmpty) {
                                  return 'Seleziona utente Keycloak';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Salva modifiche'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    // Fonte utenti Keycloak usata per valorizzare legame applicativo
    // (`keycloakUserId` + `keycloakUsername`) nel documento condomino.
    final keycloakUsers = ref.read(
      adminUsersProvider.select((state) => state.items),
    );
    final selectedUser = _findAdminUserById(keycloakUsers, _selectedKeycloakUserId);
    final resolvedRole = (_hasAppAccess && selectedUser != null)
        ? _roleFromKeycloakUser(selectedUser)
        : widget.condomino.ruolo;
    Navigator.of(context).pop(
      widget.condomino.copyWith(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        scala: _scalaController.text.trim(),
        interno: _internoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        saldoIniziale: double.parse(_saldoInizialeController.text.trim().replaceAll(',', '.')),
        hasAppAccess: _hasAppAccess,
        ruolo: resolvedRole,
        keycloakUsername: _hasAppAccess
            ? (selectedUser?.username ?? _keycloakUsernameController.text.trim())
            : null,
        keycloakUserId: _hasAppAccess ? selectedUser?.userId : null,
        clearKeycloakUsername: !_hasAppAccess,
        clearKeycloakUserId: !_hasAppAccess,
      ),
    );
  }

  AdminUser? _findAdminUserById(List<AdminUser> users, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final u in users) {
      if (u.userId == id) return u;
    }
    return null;
  }

  CondominoRuolo _roleFromKeycloakUser(AdminUser user) {
    final raw = user.groupName.trim().toLowerCase();
    if (raw.contains('consigliere') || raw.contains('role_consigliere')) {
      return CondominoRuolo.consigliere;
    }
    return CondominoRuolo.standard;
  }
}
