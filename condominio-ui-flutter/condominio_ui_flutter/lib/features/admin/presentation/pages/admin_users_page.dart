import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/admin_users_notifier.dart';
import '../../domain/admin_user.dart';

/// Pagina amministrativa per gestione utenti Keycloak.
class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminUsersProvider.notifier).loadUsers());
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(adminUsersProvider.notifier)
        .createUser(
          username: _usernameCtrl.text,
          firstName: _firstNameCtrl.text,
          lastName: _lastNameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    final hasError = ref.read(
      adminUsersProvider.select((state) => state.errorMessage != null),
    );
    if (!hasError) {
      _formKey.currentState!.reset();
      _usernameCtrl.clear();
      _firstNameCtrl.clear();
      _lastNameCtrl.clear();
      _emailCtrl.clear();
      _passwordCtrl.clear();
    }
  }

  Future<void> _confirmDelete(AdminUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina utente'),
        content: Text('Vuoi eliminare ${user.username}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(adminUsersProvider.notifier).deleteUser(user.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      adminUsersProvider.select((state) => state.isLoading),
    );
    final isCreating = ref.watch(
      adminUsersProvider.select((state) => state.isCreating),
    );
    final users = ref.watch(adminUsersProvider.select((state) => state.items));
    final deletingIds = ref.watch(
      adminUsersProvider.select((state) => state.deletingIds),
    );
    final error = ref.watch(
      adminUsersProvider.select((state) => state.errorMessage),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gestione Utenti',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Aggiorna utenti',
              onPressed: isLoading
                  ? null
                  : () => ref.read(adminUsersProvider.notifier).loadUsers(),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (error != null)
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade900, fontSize: 12),
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 900;
                  return Column(
                    children: [
                      if (isCompact) ...[
                        TextFormField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Obbligatorio'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) =>
                              (value == null || !value.contains('@'))
                              ? 'Email non valida'
                              : null,
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _usernameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                    ? 'Obbligatorio'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _emailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                ),
                                validator: (value) =>
                                    (value == null || !value.contains('@'))
                                    ? 'Email non valida'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (isCompact) ...[
                        TextFormField(
                          controller: _firstNameCtrl,
                          decoration: const InputDecoration(labelText: 'Nome'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _lastNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cognome',
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Cognome',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (isCompact) ...[
                        TextFormField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Password iniziale',
                          ),
                          obscureText: true,
                          validator: (value) =>
                              (value == null || value.length < 8)
                              ? 'Minimo 8 caratteri'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: isCreating ? null : _createUser,
                            icon: isCreating
                                ? const SizedBox.square(
                                    dimension: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1),
                            label: const Text('Crea utente'),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _passwordCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Password iniziale',
                                ),
                                obscureText: true,
                                validator: (value) =>
                                    (value == null || value.length < 8)
                                    ? 'Minimo 8 caratteri'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: isCreating ? null : _createUser,
                              icon: isCreating
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_alt_1),
                              label: const Text('Crea utente'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Card(
            child: RefreshIndicator(
              onRefresh: () => ref.read(adminUsersProvider.notifier).loadUsers(),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Nessun utente trovato')),
                      ],
                    )
                  : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isDeleting = deletingIds.contains(user.userId);
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              user.username.isEmpty
                                  ? '?'
                                  : user.username[0].toUpperCase(),
                            ),
                          ),
                          title: Text(user.username),
                          subtitle: Text(
                            '${user.firstName} ${user.lastName} - ${user.email}',
                          ),
                          trailing: IconButton(
                            tooltip: 'Elimina',
                            onPressed: isDeleting
                                ? null
                                : () => _confirmDelete(user),
                            icon: isDeleting
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.delete_outline),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
