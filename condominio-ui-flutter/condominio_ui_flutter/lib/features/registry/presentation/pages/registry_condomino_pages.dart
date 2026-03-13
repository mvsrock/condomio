import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin/application/admin_users_notifier.dart';
import '../../../admin/domain/admin_user.dart';
import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../application/unita_immobiliari_notifier.dart';
import '../../domain/condomino.dart';
import '../../domain/unita_immobiliare.dart';
import '../widgets/registry_condomino_sections.dart';

/// Schermata dettaglio del condomino selezionato da anagrafica.
///
/// E' separata dalla tab principale per mantenere `RegistryTabPage` focalizzata
/// sul coordinamento della sezione, non sul rendering del dettaglio.
class RegistryCondominoDetailPage extends StatefulWidget {
  const RegistryCondominoDetailPage({
    super.key,
    required this.condomino,
    required this.canEdit,
    required this.onUpdated,
    required this.onDelete,
    required this.onCease,
    required this.onSubentro,
  });

  final Condomino condomino;
  final bool canEdit;
  final Future<Condomino> Function(Condomino updated) onUpdated;
  final Future<void> Function(Condomino condomino) onDelete;
  final Future<Condomino> Function(Condomino condomino) onCease;
  final Future<Condomino> Function(Condomino condomino) onSubentro;

  @override
  State<RegistryCondominoDetailPage> createState() =>
      _RegistryCondominoDetailPageState();
}

class _RegistryCondominoDetailPageState
    extends State<RegistryCondominoDetailPage> {
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
          if (widget.canEdit) ...[
            FilledButton.tonalIcon(
              onPressed: _openEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Modifica'),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<_RegistryDetailAction>(
              tooltip: 'Azioni posizione',
              onSelected: _handleAction,
              itemBuilder: (context) => [
                if (_current.isActivePosition)
                  const PopupMenuItem(
                    value: _RegistryDetailAction.cease,
                    child: Text('Cessa posizione'),
                  ),
                if (_current.isActivePosition)
                  const PopupMenuItem(
                    value: _RegistryDetailAction.subentro,
                    child: Text('Registra subentro'),
                  ),
                const PopupMenuItem(
                  value: _RegistryDetailAction.delete,
                  child: Text('Elimina se e errore'),
                ),
              ],
            ),
          ],
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
                child: RegistryCondominoOverviewCard(
                  condomino: _current,
                  theme: theme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit() async {
    final saved = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => RegistryCondominoEditPage(
          condomino: _current,
          onSave: widget.onUpdated,
        ),
      ),
    );
    if (saved == null) return;
    if (!mounted) return;
    setState(() => _current = saved);
  }

  Future<void> _handleAction(_RegistryDetailAction action) async {
    switch (action) {
      case _RegistryDetailAction.cease:
        final updated = await widget.onCease(_current);
        if (!mounted) return;
        setState(() => _current = updated);
        break;
      case _RegistryDetailAction.subentro:
        await widget.onSubentro(_current);
        if (!mounted) return;
        Navigator.of(context).pop();
        break;
      case _RegistryDetailAction.delete:
        await widget.onDelete(_current);
        if (!mounted) return;
        Navigator.of(context).pop();
        break;
    }
  }
}

enum _RegistryDetailAction { cease, subentro, delete }

/// Schermata modifica anagrafica/accesso di un condomino.
///
/// Usa Riverpod solo per leggere utenti Keycloak disponibili: la logica di save
/// resta locale alla pagina e restituisce un `Condomino` aggiornato al caller.
class RegistryCondominoEditPage extends ConsumerStatefulWidget {
  const RegistryCondominoEditPage({
    super.key,
    required this.condomino,
    required this.onSave,
  });

  final Condomino condomino;
  final Future<Condomino> Function(Condomino updated) onSave;

  @override
  ConsumerState<RegistryCondominoEditPage> createState() =>
      _RegistryCondominoEditPageState();
}

class _RegistryCondominoEditPageState
    extends ConsumerState<RegistryCondominoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cognomeController;
  late final TextEditingController _scalaController;
  late final TextEditingController _internoController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _saldoInizialeController;
  late final TextEditingController _keycloakUsernameController;
  late final TextEditingController _keycloakPasswordController;
  String? _selectedUnitaImmobiliareId;
  late CondominoTitolaritaTipo _titolaritaTipo;
  bool _hasAppAccess = false;
  bool _createNewUser = false;
  String? _selectedKeycloakUserId;
  late CondominoRuolo _selectedAppRole;

  String _defaultUsername() {
    final email = _emailController.text.trim();
    if (email.contains('@')) return email.split('@').first;
    final base =
        '${_nomeController.text.trim()}.${_cognomeController.text.trim()}'
            .toLowerCase();
    return base.replaceAll(' ', '');
  }

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.condomino.nome);
    _cognomeController = TextEditingController(text: widget.condomino.cognome);
    _scalaController = TextEditingController(text: widget.condomino.scala);
    _internoController = TextEditingController(text: widget.condomino.interno);
    _emailController = TextEditingController(text: widget.condomino.email);
    _telefonoController = TextEditingController(
      text: widget.condomino.telefono,
    );
    _saldoInizialeController = TextEditingController(
      text: widget.condomino.saldoIniziale.toStringAsFixed(2),
    );
    _keycloakUsernameController = TextEditingController(
      text: widget.condomino.keycloakUsername ?? '',
    );
    _keycloakPasswordController = TextEditingController();
    _selectedUnitaImmobiliareId = widget.condomino.unitaImmobiliareId;
    _titolaritaTipo = widget.condomino.titolaritaTipo;
    _hasAppAccess = widget.condomino.hasAppAccess;
    _selectedKeycloakUserId = widget.condomino.keycloakUserId;
    _selectedAppRole = widget.condomino.ruolo;
    Future.microtask(() {
      ref.read(adminUsersProvider.notifier).loadUsers();
      ref.read(unitaImmobiliariProvider.notifier).load();
    });
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
    _keycloakPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keycloakUsers = ref.watch(
      adminUsersProvider.select((state) => state.items),
    );
    final availableUnita = ref.watch(unitaImmobiliariItemsProvider);
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);

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
                          if (isReadOnly)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B),
                                ),
                              ),
                              child: const Text(
                                'Esercizio chiuso: puoi consultare i dati ma non salvare modifiche.',
                                style: TextStyle(
                                  color: Color(0xFF9A3412),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          AbsorbPointer(
                            absorbing: isReadOnly,
                            child: Opacity(
                              opacity: isReadOnly ? 0.7 : 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RegistryCondominoAnagraficaSection(
                                    nomeController: _nomeController,
                                    cognomeController: _cognomeController,
                                    requiredFieldValidator: _requiredField,
                                  ),
                                  const SizedBox(height: 16),
                                  RegistryCondominoScopeNotice(
                                    condomino: widget.condomino,
                                  ),
                                  const SizedBox(height: 16),
                                  RegistryCondominoContactsSection(
                                    emailController: _emailController,
                                    telefonoController: _telefonoController,
                                  ),
                                  const SizedBox(height: 16),
                                  RegistryCondominoExerciseSection(
                                    availableUnita: availableUnita,
                                    selectedUnitaImmobiliareId:
                                        _selectedUnitaImmobiliareId,
                                    onSelectUnitaImmobiliare: (unitId) {
                                      setState(
                                        () => _selectedUnitaImmobiliareId =
                                            unitId,
                                      );
                                      if (unitId == null || unitId.isEmpty) {
                                        _scalaController.clear();
                                        _internoController.clear();
                                        return;
                                      }
                                      final selectedUnit = _findUnitaById(
                                        availableUnita,
                                        unitId,
                                      );
                                      if (selectedUnit == null) return;
                                      _scalaController.text =
                                          selectedUnit.scala;
                                      _internoController.text =
                                          selectedUnit.interno;
                                    },
                                    onCreateUnitaInline: isReadOnly
                                        ? null
                                        : _createUnitaInlineFromEditForm,
                                    saldoInizialeController:
                                        _saldoInizialeController,
                                    titolaritaTipo: _titolaritaTipo,
                                    onTitolaritaChanged: (value) =>
                                        setState(() => _titolaritaTipo = value),
                                    decimalFieldValidator: _decimalField,
                                  ),
                                  const SizedBox(height: 16),
                                  RegistryCondominoAppAccessSection(
                                    hasAppAccess: _hasAppAccess,
                                    createNewUser: _createNewUser,
                                    selectedKeycloakUserId:
                                        _selectedKeycloakUserId,
                                    selectedRole: _selectedAppRole,
                                    usernameController:
                                        _keycloakUsernameController,
                                    passwordController:
                                        _keycloakPasswordController,
                                    keycloakUsers: keycloakUsers,
                                    onAccessChanged: (value) => setState(() {
                                      _hasAppAccess = value;
                                      if (!value) {
                                        _createNewUser = false;
                                        _selectedKeycloakUserId = null;
                                        _keycloakUsernameController.clear();
                                        _keycloakPasswordController.clear();
                                        _selectedAppRole =
                                            CondominoRuolo.standard;
                                      }
                                    }),
                                    onCreateNewUserChanged: (value) =>
                                        setState(() {
                                          _createNewUser = value;
                                          if (value) {
                                            _selectedKeycloakUserId = null;
                                            if (_keycloakUsernameController.text
                                                .trim()
                                                .isEmpty) {
                                              _keycloakUsernameController.text =
                                                  _defaultUsername();
                                            }
                                          } else {
                                            _keycloakPasswordController.clear();
                                          }
                                        }),
                                    onUserSelected: (value) {
                                      setState(() {
                                        _selectedKeycloakUserId = value;
                                        _createNewUser = false;
                                      });
                                      final user = _findAdminUserById(
                                        keycloakUsers,
                                        value,
                                      );
                                      _keycloakUsernameController.text =
                                          user?.username ?? '';
                                      if (user != null) {
                                        _selectedAppRole =
                                            _roleFromKeycloakUser(user);
                                      }
                                    },
                                    onRoleSelected: (value) {
                                      if (value == null) return;
                                      setState(() => _selectedAppRole = value);
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: FilledButton.icon(
                                      onPressed: isReadOnly
                                          ? null
                                          : () => _save(),
                                      icon: const Icon(Icons.save_outlined),
                                      label: const Text('Salva modifiche'),
                                    ),
                                  ),
                                ],
                              ),
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

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final adminNotifier = ref.read(adminUsersProvider.notifier);
    final keycloakUsers = ref.read(
      adminUsersProvider.select((state) => state.items),
    );
    AdminUser? selectedUser = _findAdminUserById(
      keycloakUsers,
      _selectedKeycloakUserId,
    );
    final resolvedRole = _hasAppAccess
        ? _selectedAppRole
        : CondominoRuolo.standard;

    if (_hasAppAccess && _createNewUser) {
      final username = _keycloakUsernameController.text.trim().isEmpty
          ? _defaultUsername()
          : _keycloakUsernameController.text.trim();
      final password = _keycloakPasswordController.text.trim();
      if (username.isEmpty) {
        throw Exception('Username app obbligatorio');
      }
      if (password.length < 8) {
        throw Exception('Password app: minimo 8 caratteri');
      }

      await adminNotifier.createUserOnly(
        username: username,
        firstName: _nomeController.text.trim(),
        lastName: _cognomeController.text.trim(),
        email: _emailController.text.trim(),
        password: password,
      );
      final createError = ref.read(
        adminUsersProvider.select((state) => state.errorMessage),
      );
      if (createError != null) {
        throw Exception(createError);
      }

      await adminNotifier.loadUsers();
      final updatedUsers = ref.read(
        adminUsersProvider.select((state) => state.items),
      );
      selectedUser = _findAdminUserByUsername(updatedUsers, username);
      if (selectedUser == null) {
        throw Exception(
          'Utenza creata ma non recuperabile. Riprova a ricaricare la lista utenti.',
        );
      }
      _selectedKeycloakUserId = selectedUser.userId;
      _keycloakUsernameController.text = selectedUser.username;
    }
    if (_hasAppAccess && !_createNewUser && selectedUser == null) {
      throw Exception(
        'Seleziona un utente app esistente oppure crea un nuovo utente',
      );
    }

    final hasSelectedUnit =
        _selectedUnitaImmobiliareId != null &&
        _selectedUnitaImmobiliareId!.trim().isNotEmpty;
    final candidate = widget.condomino.copyWith(
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
      scala: hasSelectedUnit ? _scalaController.text.trim() : '',
      interno: hasSelectedUnit ? _internoController.text.trim() : '',
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      saldoIniziale: double.parse(
        _saldoInizialeController.text.trim().replaceAll(',', '.'),
      ),
      unitaImmobiliareId:
          (_selectedUnitaImmobiliareId == null ||
              _selectedUnitaImmobiliareId!.trim().isEmpty)
          ? null
          : _selectedUnitaImmobiliareId,
      clearUnitaImmobiliareId:
          _selectedUnitaImmobiliareId == null ||
          _selectedUnitaImmobiliareId!.trim().isEmpty,
      titolaritaTipo: _titolaritaTipo,
      hasAppAccess: _hasAppAccess,
      ruolo: resolvedRole,
      keycloakUsername: _hasAppAccess
          ? (selectedUser?.username ?? _keycloakUsernameController.text.trim())
          : null,
      keycloakUserId: _hasAppAccess ? selectedUser?.userId : null,
      clearKeycloakUsername: !_hasAppAccess,
      clearKeycloakUserId: !_hasAppAccess,
    );
    try {
      final saved = await widget.onSave(candidate);
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      debugPrint('[REGISTRY][editSaveError] $e');
      final raw = e.toString();
      final pretty = raw.startsWith('Exception: ')
          ? raw.substring('Exception: '.length)
          : raw;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossibile salvare la modifica: $pretty')),
      );
    }
  }

  UnitaImmobiliare? _findUnitaById(List<UnitaImmobiliare> items, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  AdminUser? _findAdminUserById(List<AdminUser> users, String? id) {
    if (id == null || id.isEmpty) return null;
    for (final user in users) {
      if (user.userId == id) return user;
    }
    return null;
  }

  AdminUser? _findAdminUserByUsername(List<AdminUser> users, String username) {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final user in users) {
      if (user.username.trim().toLowerCase() == normalized) {
        return user;
      }
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

  /// Crea unita' immobiliare inline dal form di modifica e la seleziona subito.
  Future<void> _createUnitaInlineFromEditForm() async {
    final scalaCtrl = TextEditingController(text: _scalaController.text.trim());
    final internoCtrl = TextEditingController(
      text: _internoController.text.trim(),
    );
    try {
      final created = await showDialog<UnitaImmobiliare>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Nuova unita immobiliare'),
          content: SizedBox(
            width: 520,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: scalaCtrl,
                    decoration: const InputDecoration(labelText: 'Scala'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: internoCtrl,
                    decoration: const InputDecoration(labelText: 'Interno'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                final scala = scalaCtrl.text.trim();
                final interno = internoCtrl.text.trim();
                if (scala.isEmpty || interno.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scala e interno sono obbligatori.'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(
                  UnitaImmobiliare(
                    id: '',
                    codice: '',
                    scala: scala,
                    interno: interno,
                    subalterno: '',
                    destinazioneUso: '',
                    metriQuadri: null,
                  ),
                );
              },
              child: const Text('Crea'),
            ),
          ],
        ),
      );
      if (created == null) {
        return;
      }

      await ref.read(unitaImmobiliariProvider.notifier).create(created);
      final units = ref.read(unitaImmobiliariItemsProvider);
      final matching = units
          .where(
            (item) =>
                item.scala == created.scala && item.interno == created.interno,
          )
          .toList(growable: false);
      if (matching.isEmpty) {
        return;
      }
      final selected = matching.last;
      setState(() {
        _selectedUnitaImmobiliareId = selected.id;
        _scalaController.text = selected.scala;
        _internoController.text = selected.interno;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore creazione unita: $e')));
    } finally {
      scalaCtrl.dispose();
      internoCtrl.dispose();
    }
  }
}

String? _requiredField(String? value) {
  return (value == null || value.trim().isEmpty) ? 'Campo obbligatorio' : null;
}

String? _decimalField(String? value) {
  final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
  if (parsed == null) return 'Numero non valido';
  return null;
}
