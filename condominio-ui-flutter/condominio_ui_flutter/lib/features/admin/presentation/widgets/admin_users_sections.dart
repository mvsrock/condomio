import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../registry/domain/condomino.dart';
import '../../application/admin_users_view_providers.dart';

/// Banner errore del modulo gestione accessi.
class AdminUsersErrorCard extends ConsumerWidget {
  const AdminUsersErrorCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountError = ref.watch(adminUsersErrorProvider);
    if (accountError == null) {
      return const SizedBox.shrink();
    }

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
}

/// Card del form creazione condomino + configurazione accesso applicativo.
///
/// Lo stato persistente del form resta nella pagina chiamante; questo widget
/// rende solo la UI e legge da Riverpod gli utenti Keycloak e lo stato di
/// creazione utenza per ridurre la quantità di watch nella pagina principale.
class AdminUsersCreateCondominoCard extends ConsumerWidget {
  const AdminUsersCreateCondominoCard({
    super.key,
    required this.formKey,
    required this.nomeCtrl,
    required this.cognomeCtrl,
    required this.emailCtrl,
    required this.telefonoCtrl,
    required this.scalaCtrl,
    required this.internoCtrl,
    required this.saldoInizialeCtrl,
    required this.millesimiCtrl,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.residente,
    required this.linkExistingAccess,
    required this.createAccessNow,
    required this.selectedExistingUserId,
    required this.selectedAppRole,
    required this.isSavingCondomino,
    required this.isReadOnly,
    required this.onResidenteChanged,
    required this.onLinkExistingAccessChanged,
    required this.onCreateAccessNowChanged,
    required this.onSelectedExistingUserChanged,
    required this.onSelectedAppRoleChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nomeCtrl;
  final TextEditingController cognomeCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telefonoCtrl;
  final TextEditingController scalaCtrl;
  final TextEditingController internoCtrl;
  final TextEditingController saldoInizialeCtrl;
  final TextEditingController millesimiCtrl;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool residente;
  final bool linkExistingAccess;
  final bool createAccessNow;
  final String? selectedExistingUserId;
  final CondominoRuolo selectedAppRole;
  final bool isSavingCondomino;
  final bool isReadOnly;
  final ValueChanged<bool> onResidenteChanged;
  final ValueChanged<bool> onLinkExistingAccessChanged;
  final ValueChanged<bool> onCreateAccessNowChanged;
  final ValueChanged<String?> onSelectedExistingUserChanged;
  final ValueChanged<CondominoRuolo> onSelectedAppRoleChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keycloakUsers = ref.watch(adminUsersItemsProvider);
    final isCreatingAccount = ref.watch(adminUsersIsCreatingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 860;
              final createDisabled =
                  isSavingCondomino || isCreatingAccount || isReadOnly;
              final showRoleField = createAccessNow;

              return Column(
                children: [
                  if (isReadOnly)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B)),
                      ),
                      child: const Text(
                        'Esercizio chiuso: gestione accessi e creazione condomini disponibili solo in lettura.',
                        style: TextStyle(
                          color: Color(0xFF9A3412),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const _AdminUsersProfileScopeBanner(),
                  const SizedBox(height: 12),
                  AbsorbPointer(
                    absorbing: isReadOnly,
                    child: Opacity(
                      opacity: isReadOnly ? 0.7 : 1,
                      child: Column(
                        children: [
                          if (compact) ...[
                            _AdminUsersNameFields(
                              compact: true,
                              nomeCtrl: nomeCtrl,
                              cognomeCtrl: cognomeCtrl,
                            ),
                            const SizedBox(height: 12),
                            _AdminUsersContactFields(
                              compact: true,
                              emailCtrl: emailCtrl,
                              telefonoCtrl: telefonoCtrl,
                            ),
                            const SizedBox(height: 12),
                            _AdminUsersUnitFields(
                              compact: true,
                              scalaCtrl: scalaCtrl,
                              internoCtrl: internoCtrl,
                              saldoInizialeCtrl: saldoInizialeCtrl,
                              millesimiCtrl: millesimiCtrl,
                            ),
                          ] else ...[
                            _AdminUsersNameFields(
                              compact: false,
                              nomeCtrl: nomeCtrl,
                              cognomeCtrl: cognomeCtrl,
                            ),
                            const SizedBox(height: 12),
                            _AdminUsersContactFields(
                              compact: false,
                              emailCtrl: emailCtrl,
                              telefonoCtrl: telefonoCtrl,
                            ),
                            const SizedBox(height: 12),
                            _AdminUsersUnitFields(
                              compact: false,
                              scalaCtrl: scalaCtrl,
                              internoCtrl: internoCtrl,
                              saldoInizialeCtrl: saldoInizialeCtrl,
                              millesimiCtrl: millesimiCtrl,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SwitchListTile.adaptive(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Residente'),
                                  value: residente,
                                  onChanged: isReadOnly ? null : onResidenteChanged,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Associa utente app esistente'),
                            value: linkExistingAccess,
                            onChanged:
                                isReadOnly ? null : onLinkExistingAccessChanged,
                          ),
                          if (linkExistingAccess) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: keycloakUsers.any(
                                (user) => user.userId == selectedExistingUserId,
                              )
                                  ? selectedExistingUserId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'Utente app',
                              ),
                              items: keycloakUsers
                                  .map(
                                    (user) => DropdownMenuItem<String>(
                                      value: user.userId,
                                      child: Text(
                                        '${user.username} (${user.email})',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: isReadOnly
                                  ? null
                                  : onSelectedExistingUserChanged,
                              validator: (value) {
                                if (!linkExistingAccess) return null;
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
                            title: const Text('Crea utenza app adesso'),
                            value: createAccessNow,
                            onChanged:
                                isReadOnly ? null : onCreateAccessNowChanged,
                          ),
                          if (showRoleField) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<CondominoRuolo>(
                              initialValue: selectedAppRole,
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
                              onChanged: isReadOnly
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        onSelectedAppRoleChanged(value);
                                      }
                                    },
                              validator: (value) {
                                if (!createAccessNow) return null;
                                if (value == null) return 'Seleziona ruolo';
                                return null;
                              },
                            ),
                          ],
                          if (createAccessNow) ...[
                            const SizedBox(height: 8),
                            _AdminUsersCredentialsFields(
                              compact: compact,
                              usernameCtrl: usernameCtrl,
                              passwordCtrl: passwordCtrl,
                              requirePassword: createAccessNow,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: createDisabled ? null : onSubmit,
                              icon: createDisabled
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_alt_1),
                              label: const Text('Crea condomino'),
                            ),
                          ),
                        ],
                      ),
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
}

/// Lista condomini con azione "abilita accesso" per chi non ha ancora utenza.
class AdminUsersCondominiListCard extends ConsumerWidget {
  const AdminUsersCondominiListCard({
    super.key,
    required this.onEnableAccessLater,
    required this.isReadOnly,
  });

  final ValueChanged<Condomino> onEnableAccessLater;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condomini = ref.watch(adminCondominiItemsProvider);

    return Card(
      child: ListView.separated(
        itemCount: condomini.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final condomino = condomini[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(
                condomino.nome.isEmpty ? '?' : condomino.nome[0].toUpperCase(),
              ),
            ),
            title: Text('${condomino.nominativo} - ${condomino.ruolo.label}'),
            subtitle: Text(
              '${condomino.unita} - ${condomino.email}'
              '${condomino.hasAppAccess ? ' - accesso attivo (${condomino.keycloakUsername})' : ' - nessun accesso app'}',
            ),
            trailing: condomino.hasAppAccess
                ? const Icon(Icons.verified_user, color: Colors.green)
                : OutlinedButton(
                    onPressed: isReadOnly
                        ? null
                        : () => onEnableAccessLater(condomino),
                    child: const Text('Abilita accesso'),
                  ),
          );
        },
      ),
    );
  }
}

class _AdminUsersProfileScopeBanner extends StatelessWidget {
  const _AdminUsersProfileScopeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: const Text(
        'Nome, contatti e accesso app appartengono al profilo condiviso del condomino e vengono riutilizzati anche negli altri esercizi collegati. Unita, quote e saldo iniziale restano specifici dell\'esercizio corrente.',
        style: TextStyle(
          color: Color(0xFF0C4A6E),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AdminUsersNameFields extends StatelessWidget {
  const _AdminUsersNameFields({
    required this.compact,
    required this.nomeCtrl,
    required this.cognomeCtrl,
  });

  final bool compact;
  final TextEditingController nomeCtrl;
  final TextEditingController cognomeCtrl;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        children: [
          TextFormField(
            controller: nomeCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: cognomeCtrl,
            decoration: const InputDecoration(labelText: 'Cognome'),
            validator: _requiredValidator,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: nomeCtrl,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: _requiredValidator,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: cognomeCtrl,
            decoration: const InputDecoration(labelText: 'Cognome'),
            validator: _requiredValidator,
          ),
        ),
      ],
    );
  }
}

class _AdminUsersContactFields extends StatelessWidget {
  const _AdminUsersContactFields({
    required this.compact,
    required this.emailCtrl,
    required this.telefonoCtrl,
  });

  final bool compact;
  final TextEditingController emailCtrl;
  final TextEditingController telefonoCtrl;

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
      controller: emailCtrl,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) =>
          (value == null || !value.contains('@')) ? 'Email non valida' : null,
    );
    final telefonoField = TextFormField(
      controller: telefonoCtrl,
      decoration: const InputDecoration(labelText: 'Telefono'),
    );

    if (compact) {
      return Column(
        children: [
          emailField,
          const SizedBox(height: 12),
          telefonoField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: emailField),
        const SizedBox(width: 12),
        Expanded(child: telefonoField),
      ],
    );
  }
}

class _AdminUsersUnitFields extends StatelessWidget {
  const _AdminUsersUnitFields({
    required this.compact,
    required this.scalaCtrl,
    required this.internoCtrl,
    required this.saldoInizialeCtrl,
    required this.millesimiCtrl,
  });

  final bool compact;
  final TextEditingController scalaCtrl;
  final TextEditingController internoCtrl;
  final TextEditingController saldoInizialeCtrl;
  final TextEditingController millesimiCtrl;

  @override
  Widget build(BuildContext context) {
    final scalaField = TextFormField(
      controller: scalaCtrl,
      decoration: const InputDecoration(labelText: 'Scala'),
    );
    final internoField = TextFormField(
      controller: internoCtrl,
      decoration: const InputDecoration(labelText: 'Interno'),
    );
    final saldoField = TextFormField(
      controller: saldoInizialeCtrl,
      decoration: const InputDecoration(labelText: 'Saldo iniziale'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _decimalValidator,
      onChanged: (_) => _normalizeDecimalController(saldoInizialeCtrl),
    );
    final millesimiField = TextFormField(
      controller: millesimiCtrl,
      decoration: const InputDecoration(labelText: 'Millesimi'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: _decimalValidator,
      onChanged: (_) => _normalizeDecimalController(millesimiCtrl),
    );

    if (compact) {
      return Column(
        children: [
          scalaField,
          const SizedBox(height: 12),
          internoField,
          const SizedBox(height: 12),
          saldoField,
          const SizedBox(height: 12),
          millesimiField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: scalaField),
        const SizedBox(width: 12),
        Expanded(child: internoField),
        const SizedBox(width: 12),
        Expanded(child: saldoField),
        const SizedBox(width: 12),
        Expanded(child: millesimiField),
      ],
    );
  }
}

class _AdminUsersCredentialsFields extends StatelessWidget {
  const _AdminUsersCredentialsFields({
    required this.compact,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.requirePassword,
  });

  final bool compact;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool requirePassword;

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
      controller: usernameCtrl,
      decoration: const InputDecoration(labelText: 'Username app'),
    );
    final passwordField = TextFormField(
      controller: passwordCtrl,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      validator: (value) {
        if (!requirePassword) return null;
        if (value == null || value.length < 8) {
          return 'Minimo 8 caratteri';
        }
        return null;
      },
    );

    if (compact) {
      return Column(
        children: [
          usernameField,
          const SizedBox(height: 12),
          passwordField,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: usernameField),
        const SizedBox(width: 12),
        Expanded(child: passwordField),
      ],
    );
  }
}

String? _requiredValidator(String? value) {
  return (value == null || value.trim().isEmpty) ? 'Obbligatorio' : null;
}

String? _decimalValidator(String? value) {
  return double.tryParse((value ?? '').replaceAll(',', '.')) == null
      ? 'Numero non valido'
      : null;
}

void _normalizeDecimalController(TextEditingController controller) {
  final value = controller.text;
  if (!value.contains(',')) return;
  controller.value = controller.value.copyWith(
    text: value.replaceAll(',', '.'),
    selection: TextSelection.collapsed(offset: value.length),
  );
}
