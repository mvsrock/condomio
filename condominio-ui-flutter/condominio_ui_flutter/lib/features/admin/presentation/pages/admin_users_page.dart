import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../registry/application/condomini_notifier.dart';
import '../../../registry/application/unita_immobiliari_notifier.dart';
import '../../../registry/domain/condomino.dart';
import '../../../registry/domain/unita_immobiliare.dart';
import '../../application/admin_users_notifier.dart';
import '../../domain/admin_user.dart';
import '../dialogs/admin_enable_access_dialog.dart';
import '../widgets/admin_users_sections.dart';

/// Pagina amministrativa:
/// - ruoli prefissati (amministratore/consigliere/standard)
/// - creazione condomino
/// - abilitazione utenza Keycloak contestuale o successiva
///
/// Nota:
/// questa pagina e' renderizzata dentro Anagrafica (tab "Gestione Accessi")
/// e non piu' dal menu header home.
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _cognomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _scalaCtrl = TextEditingController();
  final _internoCtrl = TextEditingController();
  final _saldoInizialeCtrl = TextEditingController(text: '0');
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _residente = true;
  String? _selectedUnitaImmobiliareId;
  bool _linkExistingAccess = false;
  bool _createAccessNow = false;
  String? _selectedExistingUserId;
  CondominoRuolo _selectedAppRole = CondominoRuolo.standard;
  bool _isSavingCondomino = false;

  @override
  void initState() {
    super.initState();
    // Carichiamo subito gli utenti Keycloak disponibili per l'admin corrente.
    Future.microtask(() {
      ref.read(adminUsersProvider.notifier).loadUsers();
      ref.read(unitaImmobiliariProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cognomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _scalaCtrl.dispose();
    _internoCtrl.dispose();
    _saldoInizialeCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _defaultUsername() {
    final email = _emailCtrl.text.trim();
    if (email.contains('@')) return email.split('@').first;
    final base =
        '${_nomeCtrl.text.trim()}.${_cognomeCtrl.text.trim()}'.toLowerCase();
    return base.replaceAll(' ', '');
  }

  Future<void> _submitCondomino() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSavingCondomino) return;
    if (ref.read(selectedManagedCondominioIsClosedProvider)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esercizio chiuso: non puoi creare condomini o accessi in sola lettura.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isSavingCondomino = true);
    try {
      // Legami funzionali:
      // - `adminUsersProvider` -> API Core facade (/keycloak-admin/users)
      //   che inoltra a keycloak-service via discovery/Feign (no direct FE -> keycloak-service)
      // - `condominiProvider`  -> API Core (/condomino) per persistenza anagrafica
      final registryNotifier = ref.read(condominiProvider.notifier);
      final authNotifier = ref.read(adminUsersProvider.notifier);
      final selectedUnita = _findUnitaById(
        ref.read(unitaImmobiliariItemsProvider),
        _selectedUnitaImmobiliareId,
      );
      if (selectedUnita == null) {
        throw Exception('Seleziona unita immobiliare.');
      }

      final username = _usernameCtrl.text.trim().isEmpty
          ? _defaultUsername()
          : _usernameCtrl.text.trim();
      final password = _passwordCtrl.text;

      bool accessEnabled = false;
      String? accessUserId;
      String? accessUsername;
      String? accessError;

      // Se richiesto, prima creiamo l'utenza Keycloak e poi salviamo il condomino.
      // In questo modo persistiamo anche `keycloakUserId/keycloakUsername` su Core.
      if (_createAccessNow) {
        await authNotifier.createUserOnly(
          username: username,
          firstName: _nomeCtrl.text.trim(),
          lastName: _cognomeCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: password,
        );
        accessError = ref.read(
          adminUsersProvider.select((state) => state.errorMessage),
        );
        if (accessError == null) {
          accessEnabled = true;
          accessUsername = username;
          await authNotifier.loadUsers();
          final createdUser = _findUserByUsername(
            ref.read(adminUsersProvider.select((state) => state.items)),
            username,
          );
          accessUserId = createdUser?.userId;
        }
      }

      // Associazione utenza esistente: nessuna create su Keycloak, solo lookup locale.
      if (_linkExistingAccess && _selectedExistingUserId != null) {
        final selected = _findUserById(
          ref.read(adminUsersProvider.select((state) => state.items)),
          _selectedExistingUserId!,
        );
        if (selected != null) {
          accessEnabled = true;
          accessUserId = selected.userId;
          accessUsername = selected.username;
        }
      }

      // Ruolo applicativo: in creazione nuova utenza viene scelto in UI;
      // con utenza esistente viene derivato dai dati utente Keycloak.
      CondominoRuolo effectiveRole = CondominoRuolo.standard;
      if (_createAccessNow) {
        effectiveRole = _selectedAppRole;
      } else if (_linkExistingAccess && _selectedExistingUserId != null) {
        final selected = _findUserById(
          ref.read(adminUsersProvider.select((state) => state.items)),
          _selectedExistingUserId!,
        );
        if (selected != null) {
          effectiveRole = _roleFromKeycloakUser(selected);
        }
      }

      await registryNotifier.createCondomino(
        Condomino(
          id: '',
          nome: _nomeCtrl.text.trim(),
          cognome: _cognomeCtrl.text.trim(),
          scala: selectedUnita.scala,
          interno: selectedUnita.interno,
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          saldoIniziale: double.parse(_saldoInizialeCtrl.text.trim().replaceAll(',', '.')),
          millesimi: 0,
          residente: _residente,
          ruolo: effectiveRole,
          hasAppAccess: accessEnabled,
          keycloakUserId: accessUserId,
          keycloakUsername: accessUsername,
          unitaImmobiliareId: selectedUnita.id,
        ),
      );

      if (!mounted) return;
      if (_createAccessNow && accessError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Condomino creato, ma accesso app non abilitato: $accessError',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Condomino creato con successo')),
        );
      }

      _formKey.currentState!.reset();
      _nomeCtrl.clear();
      _cognomeCtrl.clear();
      _emailCtrl.clear();
      _telefonoCtrl.clear();
      _scalaCtrl.clear();
      _internoCtrl.clear();
      _saldoInizialeCtrl.text = '0';
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      setState(() {
        _residente = true;
        _selectedUnitaImmobiliareId = null;
        _linkExistingAccess = false;
        _createAccessNow = false;
        _selectedExistingUserId = null;
        _selectedAppRole = CondominoRuolo.standard;
      });
    } catch (e) {
      // Qualunque errore (Keycloak/Core) viene notificato e non lascia la UI bloccata.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore creazione condomino: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingCondomino = false);
      }
    }
  }

  Future<void> _enableAccessLater(Condomino condomino) async {
    if (ref.read(selectedManagedCondominioIsClosedProvider)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esercizio chiuso: non puoi associare accessi in sola lettura.',
            ),
          ),
        );
      }
      return;
    }

    // Flow "successivo":
    // - recupera utenti Keycloak
    // - collega utente selezionato al condomino su Core
    // - ruolo condomino derivato dai metadati utente Keycloak
    await ref.read(adminUsersProvider.notifier).loadUsers();
    if (!mounted) return;
    final users = ref.read(adminUsersProvider.select((state) => state.items));
    final result = await showDialog<AdminEnableAccessResult>(
      context: context,
      builder: (context) => AdminEnableAccessDialog(
        condomino: condomino,
        users: users,
      ),
    );
    if (result == null) return;
    AdminUser? selectedUser;
    CondominoRuolo resolvedRole = condomino.ruolo;

    if (result.createNewUser) {
      await ref.read(adminUsersProvider.notifier).createUserOnly(
        username: result.username,
        firstName: condomino.nome,
        lastName: condomino.cognome,
        email: condomino.email,
        password: result.password,
      );

      final error = ref.read(
        adminUsersProvider.select((state) => state.errorMessage),
      );
      if (!mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore creazione utenza: $error')),
        );
        return;
      }

      await ref.read(adminUsersProvider.notifier).loadUsers();
      final updatedUsers = ref.read(
        adminUsersProvider.select((state) => state.items),
      );
      selectedUser = _findUserByUsername(updatedUsers, result.username);
      resolvedRole = result.selectedRole;
    } else {
      selectedUser = _findUserById(users, result.selectedUserId!);
      if (selectedUser != null) {
        resolvedRole = _roleFromKeycloakUser(selectedUser);
      }
    }
    if (selectedUser == null) return;

    await ref.read(condominiProvider.notifier).updateCondomino(
      condomino.copyWith(
        hasAppAccess: true,
        keycloakUserId: selectedUser.userId,
        keycloakUsername: selectedUser.username,
        ruolo: resolvedRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isReadOnly = ref.watch(selectedManagedCondominioIsClosedProvider);
    final availableUnita = ref.watch(unitaImmobiliariItemsProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShortViewport = constraints.maxHeight < 760;
        final listHeight = (constraints.maxHeight * 0.45).clamp(260.0, 420.0);

        if (isShortViewport) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const AdminUsersErrorCard(),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: isReadOnly ? null : () => _openManageUnitaDialog(),
                  icon: const Icon(Icons.apartment_outlined),
                  label: const Text('Gestisci unita'),
                ),
              ),
              const SizedBox(height: 8),
              AdminUsersCreateCondominoCard(
                formKey: _formKey,
                nomeCtrl: _nomeCtrl,
                cognomeCtrl: _cognomeCtrl,
                emailCtrl: _emailCtrl,
                telefonoCtrl: _telefonoCtrl,
                availableUnita: availableUnita,
                selectedUnitaImmobiliareId: _selectedUnitaImmobiliareId,
                onSelectedUnitaChanged: (value) => setState(() {
                  _selectedUnitaImmobiliareId = value;
                  final selected = _findUnitaById(availableUnita, value);
                  if (selected != null) {
                    _scalaCtrl.text = selected.scala;
                    _internoCtrl.text = selected.interno;
                  }
                }),
                onCreateUnitaInline: _createUnitaInlineFromCondominoForm,
                saldoInizialeCtrl: _saldoInizialeCtrl,
                usernameCtrl: _usernameCtrl,
                passwordCtrl: _passwordCtrl,
                residente: _residente,
                linkExistingAccess: _linkExistingAccess,
                createAccessNow: _createAccessNow,
                selectedExistingUserId: _selectedExistingUserId,
                selectedAppRole: _selectedAppRole,
                isSavingCondomino: _isSavingCondomino,
                isReadOnly: isReadOnly,
                onResidenteChanged: (value) => setState(() => _residente = value),
                onLinkExistingAccessChanged: (value) => setState(() {
                  _linkExistingAccess = value;
                  if (value) {
                    _createAccessNow = false;
                  }
                  _selectedAppRole = CondominoRuolo.standard;
                }),
                onCreateAccessNowChanged: (value) => setState(() {
                  _createAccessNow = value;
                  if (value) {
                    _linkExistingAccess = false;
                  } else {
                    _selectedAppRole = CondominoRuolo.standard;
                  }
                }),
                onSelectedExistingUserChanged: (value) =>
                    setState(() => _selectedExistingUserId = value),
                onSelectedAppRoleChanged: (value) =>
                    setState(() => _selectedAppRole = value),
                onSubmit: _submitCondomino,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: listHeight,
                child: AdminUsersCondominiListCard(
                  onEnableAccessLater: _enableAccessLater,
                  isReadOnly: isReadOnly,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminUsersErrorCard(),
            OutlinedButton.icon(
              onPressed: isReadOnly ? null : () => _openManageUnitaDialog(),
              icon: const Icon(Icons.apartment_outlined),
              label: const Text('Gestisci unita'),
            ),
            const SizedBox(height: 8),
            AdminUsersCreateCondominoCard(
              formKey: _formKey,
              nomeCtrl: _nomeCtrl,
              cognomeCtrl: _cognomeCtrl,
              emailCtrl: _emailCtrl,
              telefonoCtrl: _telefonoCtrl,
              availableUnita: availableUnita,
              selectedUnitaImmobiliareId: _selectedUnitaImmobiliareId,
              onSelectedUnitaChanged: (value) => setState(() {
                _selectedUnitaImmobiliareId = value;
                final selected = _findUnitaById(availableUnita, value);
                if (selected != null) {
                  _scalaCtrl.text = selected.scala;
                  _internoCtrl.text = selected.interno;
                }
              }),
              onCreateUnitaInline: _createUnitaInlineFromCondominoForm,
              saldoInizialeCtrl: _saldoInizialeCtrl,
              usernameCtrl: _usernameCtrl,
              passwordCtrl: _passwordCtrl,
              residente: _residente,
              linkExistingAccess: _linkExistingAccess,
              createAccessNow: _createAccessNow,
              selectedExistingUserId: _selectedExistingUserId,
              selectedAppRole: _selectedAppRole,
              isSavingCondomino: _isSavingCondomino,
              isReadOnly: isReadOnly,
              onResidenteChanged: (value) => setState(() => _residente = value),
              onLinkExistingAccessChanged: (value) => setState(() {
                _linkExistingAccess = value;
                if (value) {
                  _createAccessNow = false;
                }
                _selectedAppRole = CondominoRuolo.standard;
              }),
              onCreateAccessNowChanged: (value) => setState(() {
                _createAccessNow = value;
                if (value) {
                  _linkExistingAccess = false;
                } else {
                  _selectedAppRole = CondominoRuolo.standard;
                }
              }),
              onSelectedExistingUserChanged: (value) =>
                  setState(() => _selectedExistingUserId = value),
              onSelectedAppRoleChanged: (value) =>
                  setState(() => _selectedAppRole = value),
              onSubmit: _submitCondomino,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AdminUsersCondominiListCard(
                onEnableAccessLater: _enableAccessLater,
                isReadOnly: isReadOnly,
              ),
            ),
          ],
        );
      },
    );
  }
  AdminUser? _findUserById(List<AdminUser> users, String userId) {
    for (final user in users) {
      if (user.userId == userId) return user;
    }
    return null;
  }

  AdminUser? _findUserByUsername(List<AdminUser> users, String username) {
    for (final user in users) {
      if (user.username == username) return user;
    }
    return null;
  }

  CondominoRuolo _roleFromKeycloakUser(AdminUser user) {
    return _roleFromKeycloakName(user.groupName);
  }

  CondominoRuolo _roleFromKeycloakName(String? rawRoleName) {
    final raw = (rawRoleName ?? '').trim().toLowerCase();
    if (raw.contains('consigliere') || raw.contains('role_consigliere')) {
      return CondominoRuolo.consigliere;
    }
    return CondominoRuolo.standard;
  }

  Future<void> _createUnitaInlineFromCondominoForm() async {
    final scalaCtrl = TextEditingController(text: _scalaCtrl.text.trim());
    final internoCtrl = TextEditingController(text: _internoCtrl.text.trim());
    try {
      final created = await showDialog<UnitaImmobiliare>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Nuova unita immobiliare'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                Row(
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
      if (created == null) return;
      await ref.read(unitaImmobiliariProvider.notifier).create(created);
      final availableUnita = ref.read(unitaImmobiliariItemsProvider);
      final matched = availableUnita
          .where((item) => item.scala == created.scala && item.interno == created.interno)
          .toList(growable: false);
      if (matched.isEmpty) return;
      final selected = matched.last;
      setState(() {
        _selectedUnitaImmobiliareId = selected.id;
        _scalaCtrl.text = selected.scala;
        _internoCtrl.text = selected.interno;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore creazione unita inline: $e')),
      );
    } finally {
      scalaCtrl.dispose();
      internoCtrl.dispose();
    }
  }

  Future<void> _openManageUnitaDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _AdminManageUnitaDialog(),
    );
  }

  UnitaImmobiliare? _findUnitaById(List<UnitaImmobiliare> items, String? id) {
    if (id == null || id.isEmpty) {
      return null;
    }
    for (final unit in items) {
      if (unit.id == id) return unit;
    }
    return null;
  }
}

class _AdminManageUnitaDialog extends ConsumerStatefulWidget {
  const _AdminManageUnitaDialog();

  @override
  ConsumerState<_AdminManageUnitaDialog> createState() =>
      _AdminManageUnitaDialogState();
}

class _AdminManageUnitaDialogState
    extends ConsumerState<_AdminManageUnitaDialog> {
  final _scalaCtrl = TextEditingController();
  final _internoCtrl = TextEditingController();
  String? _selectedCondominoId;
  bool _isSaving = false;

  @override
  void dispose() {
    _scalaCtrl.dispose();
    _internoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitaImmobiliariProvider);
    final condomini = ref.watch(condominiItemsProvider);
    return AlertDialog(
      title: const Text('Gestione unita immobiliari'),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scalaCtrl,
                    decoration: const InputDecoration(labelText: 'Scala'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _internoCtrl,
                    decoration: const InputDecoration(labelText: 'Interno'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _createUnita,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add),
                  label: const Text('Aggiungi'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => ref.read(unitaImmobiliariProvider.notifier).load(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Aggiorna'),
                ),
              ],
            ),
            DropdownButtonFormField<String?>(
              initialValue: condomini.any((c) => c.id == _selectedCondominoId)
                  ? _selectedCondominoId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Associa subito a condomino (opzionale)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Nessuna associazione'),
                ),
                ...condomini.map(
                  (condomino) => DropdownMenuItem<String?>(
                    value: condomino.id,
                    child: Text(
                      '${condomino.nominativo} (${condomino.unita})',
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCondominoId = value),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: state.items.isEmpty
                  ? const Center(
                      child: Text('Nessuna unita disponibile.'),
                    )
                  : ListView.separated(
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return ListTile(
                          title: Text(item.label),
                          subtitle: Text(
                            item.codice.trim().isEmpty
                                ? 'Codice non impostato'
                                : 'Codice: ${item.codice}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Modifica unita',
                                onPressed: () => _editUnita(item),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Storico titolarità',
                                onPressed: () => _showTitolaritaStorico(item),
                                icon: const Icon(Icons.history_outlined),
                              ),
                              IconButton(
                                tooltip: 'Elimina unita',
                                onPressed: () => _deleteUnita(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Future<void> _createUnita() async {
    final scala = _scalaCtrl.text.trim();
    final interno = _internoCtrl.text.trim();
    if (scala.isEmpty || interno.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compila scala e interno.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref.read(unitaImmobiliariProvider.notifier).create(
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
      if (_selectedCondominoId != null && _selectedCondominoId!.isNotEmpty) {
        await ref.read(condominiProvider.notifier).loadForSelectedCondominio(
              showLoading: false,
            );
        final updatedList = ref.read(condominiItemsProvider);
        Condomino? target;
        for (final item in updatedList) {
          if (item.id == _selectedCondominoId) {
            target = item;
            break;
          }
        }
        UnitaImmobiliare? linkedUnit;
        for (final item in ref.read(unitaImmobiliariItemsProvider)) {
          if (item.scala == scala && item.interno == interno) {
            linkedUnit = item;
          }
        }
        if (target != null && linkedUnit != null) {
          await ref.read(condominiProvider.notifier).updateCondomino(
                target.copyWith(
                  unitaImmobiliareId: linkedUnit.id,
                  scala: linkedUnit.scala,
                  interno: linkedUnit.interno,
                ),
              );
        }
      }
      _scalaCtrl.clear();
      _internoCtrl.clear();
      setState(() => _selectedCondominoId = null);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore creazione unità: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _editUnita(UnitaImmobiliare item) async {
    final scalaCtrl = TextEditingController(text: item.scala);
    final internoCtrl = TextEditingController(text: item.interno);
    final subalternoCtrl = TextEditingController(text: item.subalterno);
    final destinazioneCtrl = TextEditingController(text: item.destinazioneUso);
    final mqCtrl = TextEditingController(
      text: item.metriQuadri == null ? '' : item.metriQuadri!.toString(),
    );
    try {
      final updated = await showDialog<UnitaImmobiliare>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Modifica unita'),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                  const SizedBox(height: 8),
                  TextField(
                    controller: subalternoCtrl,
                    decoration: const InputDecoration(labelText: 'Subalterno'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: destinazioneCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Destinazione uso'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: mqCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Metri quadri'),
                  ),
                ],
              ),
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
                  item.copyWith(
                    scala: scala,
                    interno: interno,
                    subalterno: subalternoCtrl.text.trim(),
                    destinazioneUso: destinazioneCtrl.text.trim(),
                    metriQuadri: double.tryParse(
                      mqCtrl.text.trim().replaceAll(',', '.'),
                    ),
                  ),
                );
              },
              child: const Text('Salva'),
            ),
          ],
        ),
      );
      if (updated == null) return;
      await ref.read(unitaImmobiliariProvider.notifier).update(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore modifica unita: $e')),
      );
    } finally {
      scalaCtrl.dispose();
      internoCtrl.dispose();
      subalternoCtrl.dispose();
      destinazioneCtrl.dispose();
      mqCtrl.dispose();
    }
  }

  Future<void> _deleteUnita(UnitaImmobiliare item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Elimina unita'),
        content: Text('Confermi eliminazione di ${item.label}?'),
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
    try {
      await ref.read(unitaImmobiliariProvider.notifier).delete(item.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore eliminazione unita: $e')),
      );
    }
  }

  Future<void> _showTitolaritaStorico(UnitaImmobiliare item) async {
    try {
      final history = await ref
          .read(unitaImmobiliariProvider.notifier)
          .loadTitolaritaStorico(item.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Storico titolarita - ${item.label}'),
          content: SizedBox(
            width: 740,
            height: 360,
            child: history.isEmpty
                ? const Center(
                    child: Text('Nessuna titolarita registrata.'),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return ListTile(
                        title: Text(entry.nominativo),
                        subtitle: Text(
                          '${entry.titolaritaTipo} - ${entry.statoPosizione}'
                          '\nEsercizio: ${entry.esercizioLabel}'
                          '\nIngresso: ${_formatDate(entry.dataIngresso)} - Uscita: ${_formatDate(entry.dataUscita)}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore caricamento storico titolarita: $e')),
      );
    }
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
