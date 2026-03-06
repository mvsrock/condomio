import 'package:flutter/material.dart';

import '../../../registry/domain/condomino.dart';
import '../../domain/admin_user.dart';

/// Risultato del dialog di abilitazione accesso per un condomino.
class AdminEnableAccessResult {
  const AdminEnableAccessResult({
    required this.createNewUser,
    required this.selectedUserId,
    required this.username,
    required this.password,
    required this.selectedRole,
  });

  final bool createNewUser;
  final String? selectedUserId;
  final String username;
  final String password;
  final CondominoRuolo selectedRole;
}

/// Dialog che consente all'amministratore di:
/// - collegare un utente Keycloak già esistente
/// - oppure crearne uno nuovo al volo
///
/// Non esegue chiamate backend: restituisce solo l'intenzione dell'utente,
/// lasciando la pagina chiamante responsabile dell'orchestrazione.
class AdminEnableAccessDialog extends StatefulWidget {
  const AdminEnableAccessDialog({
    super.key,
    required this.condomino,
    required this.users,
  });

  final Condomino condomino;
  final List<AdminUser> users;

  @override
  State<AdminEnableAccessDialog> createState() => _AdminEnableAccessDialogState();
}

class _AdminEnableAccessDialogState extends State<AdminEnableAccessDialog> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _passwordCtrl;
  late bool _createNewUser;
  String? _selectedUserId;
  CondominoRuolo _selectedRole = CondominoRuolo.standard;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _selectedUserId = widget.users.isNotEmpty ? widget.users.first.userId : null;
    _createNewUser = widget.users.isEmpty;
    _usernameCtrl = TextEditingController(text: _defaultUsername());
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _defaultUsername() {
    final email = widget.condomino.email;
    if (email.contains('@')) return email.split('@').first;
    return '${widget.condomino.nome}.${widget.condomino.cognome}'.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Abilita accesso per ${widget.condomino.nominativo}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Crea nuovo utente Keycloak'),
              value: _createNewUser,
              onChanged: (value) {
                setState(() => _createNewUser = value);
              },
            ),
            const SizedBox(height: 8),
            if (!_createNewUser)
              DropdownButtonFormField<String>(
                initialValue: _selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Utente Keycloak esistente',
                ),
                items: widget.users
                    .map(
                      (user) => DropdownMenuItem<String>(
                        value: user.userId,
                        child: Text('${user.username} (${user.email})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedUserId = value);
                },
              ),
            if (_createNewUser) ...[
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username Keycloak',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Username obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => (value == null || value.trim().length < 8)
                    ? 'Minimo 8 caratteri'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<CondominoRuolo>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Ruolo applicativo',
                ),
                items: CondominoRuolo.values
                    .map(
                      (role) => DropdownMenuItem<CondominoRuolo>(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedRole = value);
                  }
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _onConfirm,
          child: const Text('Abilita'),
        ),
      ],
    );
  }

  void _onConfirm() {
    if (_createNewUser) {
      if (!_formKey.currentState!.validate()) return;
      if (_usernameCtrl.text.trim().isEmpty) return;
      if (_passwordCtrl.text.trim().length < 8) return;
    } else if (_selectedUserId == null) {
      return;
    }

    Navigator.of(context).pop(
      AdminEnableAccessResult(
        createNewUser: _createNewUser,
        selectedUserId: _selectedUserId,
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        selectedRole: _selectedRole,
      ),
    );
  }
}
