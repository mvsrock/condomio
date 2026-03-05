import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../registry/application/condomini_notifier.dart';
import '../../../registry/domain/condomino.dart';
import '../../application/admin_users_notifier.dart';
import '../../domain/admin_user.dart';

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
              'Condomino creato, ma utenza Keycloak non abilitata: $accessError',
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
    // Flow "successivo":
    // - recupera utenti Keycloak
    // - collega utente selezionato al condomino su Core
    // - ruolo condomino derivato dai metadati utente Keycloak
    await ref.read(adminUsersProvider.notifier).loadUsers();
    if (!mounted) return;
    final users = ref.read(adminUsersProvider.select((state) => state.items));
    String? selectedUserId = users.isNotEmpty ? users.first.userId : null;
    bool createNewUser = users.isEmpty;
    final usernameCtrl = TextEditingController(
      text: condomino.email.contains('@')
          ? condomino.email.split('@').first
          : '${condomino.nome}.${condomino.cognome}'.toLowerCase(),
    );
    final passwordCtrl = TextEditingController();
    CondominoRuolo selectedNewRole = CondominoRuolo.standard;
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Abilita accesso per ${condomino.nominativo}'),
        content: StatefulBuilder(
          builder: (context, setLocalState) => Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Crea nuovo utente Keycloak'),
                  value: createNewUser,
                  onChanged: (value) {
                    setLocalState(() => createNewUser = value);
                  },
                ),
                const SizedBox(height: 8),
                if (!createNewUser)
                  DropdownButtonFormField<String>(
                    initialValue: selectedUserId,
                    decoration: const InputDecoration(
                      labelText: 'Utente Keycloak esistente',
                    ),
                    items: users
                        .map(
                          (u) => DropdownMenuItem<String>(
                            value: u.userId,
                            child: Text('${u.username} (${u.email})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setLocalState(() => selectedUserId = value);
                    },
                  ),
                if (createNewUser) ...[
                  TextFormField(
                    controller: usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username Keycloak',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Username obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) => (value == null || value.trim().length < 8)
                        ? 'Minimo 8 caratteri'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CondominoRuolo>(
                    initialValue: selectedNewRole,
                    decoration: const InputDecoration(
                      labelText: 'Ruolo applicativo',
                    ),
                    items: CondominoRuolo.values
                        .map(
                          (r) => DropdownMenuItem<CondominoRuolo>(
                            value: r,
                            child: Text(r.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setLocalState(() => selectedNewRole = value);
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () {
              if (createNewUser) {
                if (!formKey.currentState!.validate()) return;
                if (usernameCtrl.text.trim().isEmpty) return;
                if (passwordCtrl.text.trim().length < 8) return;
              } else {
                if (selectedUserId == null) return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Abilita'),
          ),
        ],
      ),
    );

    if (ok != true) return;
    AdminUser? selectedUser;
    CondominoRuolo resolvedRole = condomino.ruolo;

    if (createNewUser) {
      await ref.read(adminUsersProvider.notifier).createUserOnly(
        username: usernameCtrl.text.trim(),
        firstName: condomino.nome,
        lastName: condomino.cognome,
        email: condomino.email,
        password: passwordCtrl.text.trim(),
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
      selectedUser = _findUserByUsername(updatedUsers, usernameCtrl.text.trim());
      resolvedRole = selectedNewRole;
    } else {
      selectedUser = _findUserById(users, selectedUserId!);
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
    final condomini = ref.watch(
      condominiProvider.select((state) => state.items),
    );
    final isCreatingAccount = ref.watch(
      adminUsersProvider.select((state) => state.isCreating),
    );
    final accountError = ref.watch(
      adminUsersProvider.select((state) => state.errorMessage),
    );
    final keycloakUsers = ref.watch(
      adminUsersProvider.select((state) => state.items),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isShortViewport = constraints.maxHeight < 760;
        final listHeight = (constraints.maxHeight * 0.45).clamp(260.0, 420.0);

        if (isShortViewport) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (accountError != null) _buildErrorCard(accountError),
              _buildCreateCondominoCard(
                isCreatingAccount: isCreatingAccount,
                keycloakUsers: keycloakUsers,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: listHeight,
                child: _buildCondominiListCard(condomini),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountError != null) _buildErrorCard(accountError),
            _buildCreateCondominoCard(
              isCreatingAccount: isCreatingAccount,
              keycloakUsers: keycloakUsers,
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCondominiListCard(condomini)),
          ],
        );
      },
    );
  }

  Widget _buildErrorCard(String accountError) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          accountError,
          style: TextStyle(color: Colors.red.shade900, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCreateCondominoCard({
    required bool isCreatingAccount,
    required List<AdminUser> keycloakUsers,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 860;
              final createDisabled = _isSavingCondomino || isCreatingAccount;
              final showRoleField = _createAccessNow;

              return Column(
                children: [
                  if (compact) ...[
                    _fieldNomeCognome(compact: true),
                    const SizedBox(height: 12),
                    _fieldContatti(compact: true),
                    const SizedBox(height: 12),
                    _fieldUnita(compact: true),
                  ] else ...[
                    _fieldNomeCognome(compact: false),
                    const SizedBox(height: 12),
                    _fieldContatti(compact: false),
                    const SizedBox(height: 12),
                    _fieldUnita(compact: false),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile.adaptive(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Residente'),
                          value: _residente,
                          onChanged: (value) => setState(() => _residente = value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Associa utente Keycloak esistente'),
                    value: _linkExistingAccess,
                    onChanged: (value) => setState(() {
                      _linkExistingAccess = value;
                      if (value) {
                        _createAccessNow = false;
                      }
                      _selectedAppRole = CondominoRuolo.standard;
                    }),
                  ),
                  if (_linkExistingAccess) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: keycloakUsers.any(
                        (u) => u.userId == _selectedExistingUserId,
                      )
                          ? _selectedExistingUserId
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
                      onChanged: (value) =>
                          setState(() => _selectedExistingUserId = value),
                      validator: (value) {
                        if (!_linkExistingAccess) return null;
                        if (value == null || value.isEmpty) {
                          return 'Seleziona un utente';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Crea utenza Keycloak adesso'),
                    value: _createAccessNow,
                    onChanged: (value) => setState(() {
                      _createAccessNow = value;
                      if (value) {
                        _linkExistingAccess = false;
                      } else {
                        _selectedAppRole = CondominoRuolo.standard;
                      }
                    }),
                  ),
                  if (showRoleField) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CondominoRuolo>(
                      initialValue: _selectedAppRole,
                      decoration: const InputDecoration(
                        labelText: 'Ruolo applicativo',
                      ),
                      items: CondominoRuolo.values
                          .map(
                            (r) => DropdownMenuItem<CondominoRuolo>(
                              value: r,
                              child: Text(r.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedAppRole = value);
                        }
                      },
                      validator: (value) {
                        if (!_createAccessNow) return null;
                        if (value == null) {
                          return 'Seleziona ruolo';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_createAccessNow) ...[
                    const SizedBox(height: 8),
                    compact
                        ? Column(
                            children: [
                              TextFormField(
                                controller: _usernameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Username Keycloak',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (!_createAccessNow) return null;
                                  if (value == null || value.length < 8) {
                                    return 'Minimo 8 caratteri';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _usernameCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Username Keycloak',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (!_createAccessNow) return null;
                                    if (value == null || value.length < 8) {
                                      return 'Minimo 8 caratteri';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                  ],
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: createDisabled ? null : _submitCondomino,
                      icon: createDisabled
                          ? const SizedBox.square(
                              dimension: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add_alt_1),
                      label: const Text('Crea condomino'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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

  Widget _buildCondominiListCard(List<Condomino> condomini) {
    return Card(
      child: ListView.separated(
        itemCount: condomini.length,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final c = condomini[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(c.nome.isEmpty ? '?' : c.nome[0].toUpperCase()),
            ),
            title: Text('${c.nominativo} - ${c.ruolo.label}'),
            subtitle: Text(
              '${c.unita} - ${c.email}${c.hasAppAccess ? ' - accesso attivo (${c.keycloakUsername})' : ' - nessun accesso app'}',
            ),
            trailing: c.hasAppAccess
                ? const Icon(Icons.verified_user, color: Colors.green)
                : OutlinedButton(
                    onPressed: () => _enableAccessLater(c),
                    child: const Text('Abilita accesso'),
                  ),
          );
        },
      ),
    );
  }

  Widget _fieldNomeCognome({required bool compact}) {
    if (compact) {
      return Column(
        children: [
          TextFormField(
            controller: _nomeCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cognomeCtrl,
            decoration: const InputDecoration(labelText: 'Cognome'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null,
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nomeCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _cognomeCtrl,
            decoration: const InputDecoration(labelText: 'Cognome'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null,
          ),
        ),
      ],
    );
  }

  Widget _fieldContatti({required bool compact}) {
    if (compact) {
      return Column(
        children: [
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                (value == null || !value.contains('@')) ? 'Email non valida' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _telefonoCtrl,
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) =>
                (value == null || !value.contains('@')) ? 'Email non valida' : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _telefonoCtrl,
            decoration: const InputDecoration(labelText: 'Telefono'),
          ),
        ),
      ],
    );
  }

  Widget _fieldUnita({required bool compact}) {
    if (compact) {
      return Column(
        children: [
          TextFormField(
            controller: _scalaCtrl,
            decoration: const InputDecoration(labelText: 'Scala'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _internoCtrl,
            decoration: const InputDecoration(labelText: 'Interno'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _millesimiCtrl,
            decoration: const InputDecoration(labelText: 'Millesimi'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                double.tryParse((value ?? '').replaceAll(',', '.')) == null
                ? 'Numero non valido'
                : null,
            onChanged: (value) {
              if (value.contains(',')) {
                _millesimiCtrl.value = _millesimiCtrl.value.copyWith(
                  text: value.replaceAll(',', '.'),
                  selection: TextSelection.collapsed(
                    offset: value.length,
                  ),
                );
              }
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _scalaCtrl,
            decoration: const InputDecoration(labelText: 'Scala'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _internoCtrl,
            decoration: const InputDecoration(labelText: 'Interno'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _millesimiCtrl,
            decoration: const InputDecoration(labelText: 'Millesimi'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) =>
                double.tryParse((value ?? '').replaceAll(',', '.')) == null
                ? 'Numero non valido'
                : null,
            onChanged: (value) {
              if (value.contains(',')) {
                _millesimiCtrl.value = _millesimiCtrl.value.copyWith(
                  text: value.replaceAll(',', '.'),
                  selection: TextSelection.collapsed(
                    offset: value.length,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
