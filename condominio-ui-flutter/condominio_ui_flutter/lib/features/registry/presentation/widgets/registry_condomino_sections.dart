import 'package:flutter/material.dart';

import '../../../admin/domain/admin_user.dart';
import '../../domain/condomino.dart';

/// Card riepilogo del dettaglio condomino.
class RegistryCondominoOverviewCard extends StatelessWidget {
  const RegistryCondominoOverviewCard({
    super.key,
    required this.condomino,
    required this.theme,
  });

  final Condomino condomino;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          condomino.nominativo,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          condomino.unita,
                          style: const TextStyle(color: Color(0xFF486581)),
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
                _RegistryValuePill(label: 'ID', value: condomino.id),
                _RegistryValuePill(label: 'Unita', value: condomino.unita),
              ],
            ),
            const SizedBox(height: 18),
            _RegistryDetailRow(label: 'Email', value: condomino.email),
            _RegistryDetailRow(label: 'Telefono', value: condomino.telefono),
          ],
        ),
      ),
    );
  }
}

/// Sezione campi base anagrafici.
class RegistryCondominoAnagraficaSection extends StatelessWidget {
  const RegistryCondominoAnagraficaSection({
    super.key,
    required this.nomeController,
    required this.cognomeController,
    required this.scalaController,
    required this.internoController,
    required this.requiredFieldValidator,
  });

  final TextEditingController nomeController;
  final TextEditingController cognomeController;
  final TextEditingController scalaController;
  final TextEditingController internoController;
  final FormFieldValidator<String> requiredFieldValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dati anagrafici',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: requiredFieldValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cognomeController,
                decoration: const InputDecoration(labelText: 'Cognome'),
                validator: requiredFieldValidator,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: scalaController,
                decoration: const InputDecoration(labelText: 'Scala'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: internoController,
                decoration: const InputDecoration(labelText: 'Interno'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Sezione contatti e saldo iniziale.
class RegistryCondominoContactsSection extends StatelessWidget {
  const RegistryCondominoContactsSection({
    super.key,
    required this.emailController,
    required this.telefonoController,
    required this.saldoInizialeController,
    required this.decimalFieldValidator,
  });

  final TextEditingController emailController;
  final TextEditingController telefonoController;
  final TextEditingController saldoInizialeController;
  final FormFieldValidator<String> decimalFieldValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contatti',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: telefonoController,
          decoration: const InputDecoration(labelText: 'Telefono'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: saldoInizialeController,
          decoration: const InputDecoration(labelText: 'Saldo iniziale'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: decimalFieldValidator,
        ),
      ],
    );
  }
}

/// Sezione di associazione utente Keycloak per il condomino.
class RegistryCondominoAppAccessSection extends StatelessWidget {
  const RegistryCondominoAppAccessSection({
    super.key,
    required this.hasAppAccess,
    required this.selectedKeycloakUserId,
    required this.keycloakUsers,
    required this.onAccessChanged,
    required this.onUserSelected,
  });

  final bool hasAppAccess;
  final String? selectedKeycloakUserId;
  final List<AdminUser> keycloakUsers;
  final ValueChanged<bool>? onAccessChanged;
  final ValueChanged<String?>? onUserSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accesso App (Keycloak)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Accesso app abilitato'),
          value: hasAppAccess,
          onChanged: onAccessChanged,
        ),
        if (hasAppAccess) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: keycloakUsers.any(
              (user) => user.userId == selectedKeycloakUserId,
            )
                ? selectedKeycloakUserId
                : null,
            decoration: const InputDecoration(labelText: 'Utente Keycloak'),
            items: keycloakUsers
                .map(
                  (user) => DropdownMenuItem<String>(
                    value: user.userId,
                    child: Text('${user.username} (${user.email})'),
                  ),
                )
                .toList(),
            onChanged: onUserSelected,
            validator: (value) {
              if (!hasAppAccess) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Seleziona utente Keycloak';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

class _RegistryDetailRow extends StatelessWidget {
  const _RegistryDetailRow({required this.label, required this.value});

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

class _RegistryValuePill extends StatelessWidget {
  const _RegistryValuePill({required this.label, required this.value});

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
