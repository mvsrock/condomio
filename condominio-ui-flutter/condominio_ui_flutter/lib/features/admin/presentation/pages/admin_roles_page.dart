import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/admin_roles_notifier.dart';
import '../../domain/admin_role.dart';

/// Pagina amministrativa per gestione ruoli Keycloak.
class AdminRolesPage extends ConsumerStatefulWidget {
  const AdminRolesPage({super.key});

  @override
  ConsumerState<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends ConsumerState<AdminRolesPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminRolesProvider.notifier).loadRoles());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _createRole() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(adminRolesProvider.notifier)
        .createRole(
          roleName: _nameCtrl.text,
          description: _descriptionCtrl.text,
        );
    if (!mounted) return;
    final hasError = ref.read(
      adminRolesProvider.select((state) => state.errorMessage != null),
    );
    if (!hasError) {
      _formKey.currentState!.reset();
      _nameCtrl.clear();
      _descriptionCtrl.clear();
    }
  }

  Future<void> _confirmDelete(AdminRole role) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina ruolo'),
        content: Text('Vuoi eliminare ${role.roleName}?'),
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
      await ref.read(adminRolesProvider.notifier).deleteRole(role.roleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      adminRolesProvider.select((state) => state.isLoading),
    );
    final isCreating = ref.watch(
      adminRolesProvider.select((state) => state.isCreating),
    );
    final roles = ref.watch(adminRolesProvider.select((state) => state.items));
    final deletingIds = ref.watch(
      adminRolesProvider.select((state) => state.deletingIds),
    );
    final error = ref.watch(
      adminRolesProvider.select((state) => state.errorMessage),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gestione Ruoli',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Aggiorna ruoli',
              onPressed: isLoading
                  ? null
                  : () => ref.read(adminRolesProvider.notifier).loadRoles(),
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
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nome ruolo',
                            hintText: 'ROLE_CONTABILE',
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                              ? 'Obbligatorio'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Descrizione',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: isCreating ? null : _createRole,
                            icon: isCreating
                                ? const SizedBox.square(
                                    dimension: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add_moderator_outlined),
                            label: const Text('Crea ruolo'),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Nome ruolo',
                                  hintText: 'ROLE_CONTABILE',
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
                                controller: _descriptionCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Descrizione',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: isCreating ? null : _createRole,
                              icon: isCreating
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_moderator_outlined),
                              label: const Text('Crea ruolo'),
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
              onRefresh: () => ref.read(adminRolesProvider.notifier).loadRoles(),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : roles.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Nessun ruolo trovato')),
                      ],
                    )
                  : ListView.separated(
                      itemCount: roles.length,
                      separatorBuilder: (_, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final role = roles[index];
                        final isDeleting = deletingIds.contains(role.roleId);
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.shield_outlined),
                          ),
                          title: Text(role.roleName),
                          subtitle: Text(
                            role.description.isEmpty
                                ? 'Nessuna descrizione'
                                : role.description,
                          ),
                          trailing: IconButton(
                            tooltip: 'Elimina',
                            onPressed: isDeleting
                                ? null
                                : () => _confirmDelete(role),
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
