import 'package:flutter/material.dart';

import '../../../admin/domain/admin_user.dart';
import '../../domain/condomino.dart';
import '../../domain/unita_immobiliare.dart';

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
            RegistryCondominoScopeNotice(condomino: condomino),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _RegistryValuePill(
                  label: 'Profilo',
                  value: condomino.hasStableProfile
                      ? 'Condiviso tra esercizi'
                      : 'Solo esercizio corrente',
                ),
                _RegistryValuePill(
                  label: 'Stato posizione',
                  value: condomino.posizioneStatoLabel,
                ),
                _RegistryValuePill(label: 'Unita', value: condomino.unita),
                _RegistryValuePill(
                  label: 'Titolarita',
                  value: condomino.titolaritaTipo.label,
                ),
                _RegistryValuePill(
                  label: 'Accesso app',
                  value: condomino.hasAppAccess ? 'Attivo' : 'Non abilitato',
                ),
                if (condomino.hasAppAccess)
                  _RegistryValuePill(
                    label: 'Ruolo',
                    value: condomino.ruolo.label,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Profilo condiviso',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _RegistryDetailRow(label: 'Email', value: condomino.email),
            _RegistryDetailRow(label: 'Telefono', value: condomino.telefono),
            _RegistryDetailRow(
              label: 'Utente app',
              value: condomino.hasLinkedAppUser
                  ? (condomino.keycloakUsername ?? '')
                  : 'Non collegato',
            ),
            const SizedBox(height: 18),
            const Text(
              'Posizione esercizio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _RegistryDetailRow(label: 'Unita', value: condomino.unita),
            _RegistryDetailRow(
              label: 'Titolarita',
              value: condomino.titolaritaTipo.label,
            ),
            _RegistryDetailRow(
              label: 'Ingresso',
              value: _formatDate(condomino.dataIngresso),
            ),
            _RegistryDetailRow(
              label: 'Uscita',
              value: _formatDate(condomino.dataUscita),
            ),
            if ((condomino.motivoUscita ?? '').trim().isNotEmpty)
              _RegistryDetailRow(
                label: 'Motivo uscita',
                value: condomino.motivoUscita!,
              ),
            _RegistryDetailRow(
              label: 'Saldo iniziale',
              value: condomino.saldoIniziale.toStringAsFixed(2),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) {
    return '-';
  }
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}

/// Banner che spiega in modo funzionale cosa e' condiviso tra esercizi.
class RegistryCondominoScopeNotice extends StatelessWidget {
  const RegistryCondominoScopeNotice({
    super.key,
    required this.condomino,
  });

  final Condomino condomino;

  @override
  Widget build(BuildContext context) {
    final hasStableProfile = condomino.hasStableProfile;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasStableProfile
            ? const Color(0xFFF0F9FF)
            : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasStableProfile
              ? const Color(0xFF7DD3FC)
              : const Color(0xFFF59E0B),
        ),
      ),
      child: Text(
        hasStableProfile
            ? 'Nome, contatti e accesso app fanno parte del profilo condiviso del condomino e si riflettono su tutti gli esercizi collegati. Unita, quote e saldo iniziale restano specifici dell\'esercizio corrente.'
            : 'Questo record appartiene all\'esercizio corrente. Quando il profilo condiviso viene allineato, nome, contatti e accesso app vengono riutilizzati anche sugli altri esercizi collegati.',
        style: TextStyle(
          color: hasStableProfile
              ? const Color(0xFF0C4A6E)
              : const Color(0xFF9A3412),
          fontWeight: FontWeight.w600,
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
    required this.requiredFieldValidator,
  });

  final TextEditingController nomeController;
  final TextEditingController cognomeController;
  final FormFieldValidator<String> requiredFieldValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profilo condiviso',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Questi dati vengono condivisi tra gli esercizi collegati dello stesso condominio.',
          style: TextStyle(color: Color(0xFF52606D)),
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
      ],
    );
  }
}

/// Sezione contatti condivisi del profilo.
class RegistryCondominoContactsSection extends StatelessWidget {
  const RegistryCondominoContactsSection({
    super.key,
    required this.emailController,
    required this.telefonoController,
  });

  final TextEditingController emailController;
  final TextEditingController telefonoController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contatti condivisi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Email e telefono seguono il profilo condiviso del condomino.',
          style: TextStyle(color: Color(0xFF52606D)),
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
      ],
    );
  }
}

/// Sezione dei dati specifici dell'esercizio corrente.
class RegistryCondominoExerciseSection extends StatelessWidget {
  const RegistryCondominoExerciseSection({
    super.key,
    required this.availableUnita,
    required this.selectedUnitaImmobiliareId,
    required this.onSelectUnitaImmobiliare,
    required this.scalaController,
    required this.internoController,
    required this.saldoInizialeController,
    required this.titolaritaTipo,
    required this.onTitolaritaChanged,
    required this.decimalFieldValidator,
  });

  final List<UnitaImmobiliare> availableUnita;
  final String? selectedUnitaImmobiliareId;
  final ValueChanged<String?>? onSelectUnitaImmobiliare;
  final TextEditingController scalaController;
  final TextEditingController internoController;
  final TextEditingController saldoInizialeController;
  final CondominoTitolaritaTipo titolaritaTipo;
  final ValueChanged<CondominoTitolaritaTipo>? onTitolaritaChanged;
  final FormFieldValidator<String> decimalFieldValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Posizione esercizio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Unita e saldo iniziale restano locali all\'esercizio selezionato.',
          style: TextStyle(color: Color(0xFF52606D)),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String?>(
          initialValue: availableUnita.any(
            (unit) => unit.id == selectedUnitaImmobiliareId,
          )
              ? selectedUnitaImmobiliareId
              : null,
          decoration: const InputDecoration(
            labelText: 'Unita immobiliare (opzionale)',
          ),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Nessuna unita selezionata'),
            ),
            ...availableUnita.map(
              (unit) => DropdownMenuItem<String?>(
                value: unit.id,
                child: Text(unit.label),
              ),
            ),
          ],
          onChanged: onSelectUnitaImmobiliare,
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
        const SizedBox(height: 12),
        DropdownButtonFormField<CondominoTitolaritaTipo>(
          initialValue: titolaritaTipo,
          decoration: const InputDecoration(labelText: 'Titolarita'),
          items: CondominoTitolaritaTipo.values
              .map(
                (tipo) => DropdownMenuItem<CondominoTitolaritaTipo>(
                  value: tipo,
                  child: Text(tipo.label),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) return;
            onTitolaritaChanged?.call(value);
          },
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

/// Sezione di associazione dell'utente app condiviso del condomino.
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
          'Accesso app condiviso',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'L\'utente app collegato viene riutilizzato su tutti gli esercizi dello stesso profilo.',
          style: TextStyle(color: Color(0xFF52606D)),
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
            decoration: const InputDecoration(labelText: 'Utente app'),
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
                return 'Seleziona utente app';
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
