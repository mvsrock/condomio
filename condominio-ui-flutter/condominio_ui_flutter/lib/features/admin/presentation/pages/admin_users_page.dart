import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../condominio_selection/application/managed_condominio_notifier.dart';
import '../../../registry/application/condomini_notifier.dart';
import '../../../registry/domain/condomino.dart';
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
  final _millesimiCtrl = TextEditingController(text: '0');
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _residente = true;
  bool _linkExistingAccess = false;
  bool _createAccessNow = false;
  String? _selectedExistingUserId;
  CondominoRuolo _selectedAppRole = CondominoRuolo.standard;
  bool _isSavingCondomino = false;

  @override
  void initState() {
    super.initState();
    // Carichiamo subito gli utenti Keycloak disponibili per l'admin corrente.
    Future.microtask(() => ref.read(adminUsersProvider.notifier).loadUsers());
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
    _millesimiCtrl.dispose();
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
      // - `adminUsersProvider` -> API Keycloak service (/users) per gestione utenza
      // - `condominiProvider`  -> API Core (/condomino) per persistenza anagrafica
      final registryNotifier = ref.read(condominiProvider.notifier);
      final authNotifier = ref.read(adminUsersProvider.notifier);

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
          scala: _scalaCtrl.text.trim(),
          interno: _internoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          saldoIniziale: double.parse(_saldoInizialeCtrl.text.trim().replaceAll(',', '.')),
          millesimi: double.parse(_millesimiCtrl.text.trim().replaceAll(',', '.')),
          residente: _residente,
          ruolo: effectiveRole,
          hasAppAccess: accessEnabled,
          keycloakUserId: accessUserId,
          keycloakUsername: accessUsername,
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
      _millesimiCtrl.text = '0';
      _usernameCtrl.clear();
      _passwordCtrl.clear();
      setState(() {
        _residente = true;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShortViewport = constraints.maxHeight < 760;
        final listHeight = (constraints.maxHeight * 0.45).clamp(260.0, 420.0);

        if (isShortViewport) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              const AdminUsersErrorCard(),
              AdminUsersCreateCondominoCard(
                formKey: _formKey,
                nomeCtrl: _nomeCtrl,
                cognomeCtrl: _cognomeCtrl,
                emailCtrl: _emailCtrl,
                telefonoCtrl: _telefonoCtrl,
                scalaCtrl: _scalaCtrl,
                internoCtrl: _internoCtrl,
                saldoInizialeCtrl: _saldoInizialeCtrl,
                millesimiCtrl: _millesimiCtrl,
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
            AdminUsersCreateCondominoCard(
              formKey: _formKey,
              nomeCtrl: _nomeCtrl,
              cognomeCtrl: _cognomeCtrl,
              emailCtrl: _emailCtrl,
              telefonoCtrl: _telefonoCtrl,
              scalaCtrl: _scalaCtrl,
              internoCtrl: _internoCtrl,
              saldoInizialeCtrl: _saldoInizialeCtrl,
              millesimiCtrl: _millesimiCtrl,
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
}
