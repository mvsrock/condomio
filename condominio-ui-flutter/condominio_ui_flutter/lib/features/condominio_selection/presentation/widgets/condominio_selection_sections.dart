import 'package:flutter/material.dart';

import '../../domain/managed_condominio.dart';
import '../../domain/managed_condominio_root.dart';

/// Banner errore semplice per la schermata di selezione condominio.
///
/// Rimane separato dalla page per mantenere la route focalizzata sui callback.
class CondominioSelectionErrorCard extends StatelessWidget {
  const CondominioSelectionErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          message,
          style: TextStyle(color: Colors.red.shade900),
        ),
      ),
    );
  }
}

/// Riepilogo rapido del contesto disponibile all'utente.
///
/// Rende immediato capire se mancano root, esercizi o una selezione attiva.
class CondominioSelectionOverviewStrip extends StatelessWidget {
  const CondominioSelectionOverviewStrip({
    super.key,
    required this.rootsCount,
    required this.openExercisesCount,
    required this.closedExercisesCount,
    required this.selectedExerciseLabel,
  });

  final int rootsCount;
  final int openExercisesCount;
  final int closedExercisesCount;
  final String? selectedExerciseLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _OverviewPill(
              icon: Icons.apartment_outlined,
              label: 'Condomini',
              value: '$rootsCount',
            ),
            _OverviewPill(
              icon: Icons.lock_open_outlined,
              label: 'Aperti',
              value: '$openExercisesCount',
            ),
            _OverviewPill(
              icon: Icons.history_toggle_off,
              label: 'Chiusi',
              value: '$closedExercisesCount',
            ),
            if (selectedExerciseLabel != null)
              _OverviewPill(
                icon: Icons.pin_drop_outlined,
                label: 'Selezionato',
                value: selectedExerciseLabel!,
                emphasized: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  const _OverviewPill({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final baseColor = emphasized ? const Color(0xFF155E75) : const Color(0xFF334155);
    final background = emphasized ? const Color(0xFFE3F0F4) : const Color(0xFFF1F5F9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: baseColor),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(
              color: baseColor,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card con elenco esercizi assegnati.
///
/// Gli esercizi aperti sono sempre mostrati in evidenza. Lo storico chiuso resta
/// disponibile, ma separato per rendere piu' chiaro il contesto operativo.
class ManagedCondominiiCard extends StatelessWidget {
  const ManagedCondominiiCard({
    super.key,
    required this.isLoading,
    required this.canCreate,
    required this.rootsCount,
    required this.items,
    required this.selectedId,
    required this.selectedIsClosed,
    required this.isClosingExercise,
    required this.onSelect,
    required this.onContinue,
    required this.onCloseSelected,
  });

  final bool isLoading;
  final bool canCreate;
  final int rootsCount;
  final List<ManagedCondominio> items;
  final String? selectedId;
  final bool selectedIsClosed;
  final bool isClosingExercise;
  final ValueChanged<String> onSelect;
  final VoidCallback onContinue;
  final Future<void> Function() onCloseSelected;

  @override
  Widget build(BuildContext context) {
    final hasItems = items.isNotEmpty;
    final openItems = items.where((item) => !item.isClosed).toList();
    final closedItems = items.where((item) => item.isClosed).toList();
    final selectedClosedItem = closedItems.any((item) => item.id == selectedId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esercizi assegnati',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleziona il contesto operativo. Gli esercizi chiusi si aprono in sola lettura.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (!hasItems)
                    Text(
                      canCreate
                          ? (rootsCount > 0
                                ? 'Non hai ancora esercizi. Crea il primo esercizio su un condominio esistente.'
                                : 'Non hai ancora condomini. Crea il primo per continuare.')
                          : 'Non hai condomini assegnati. Contatta un amministratore.',
                    ),
                  if (openItems.isNotEmpty) ...[
                    Text(
                      'Esercizi aperti',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...openItems.map(
                      (item) => _ExerciseTile(
                        item: item,
                        selectedId: selectedId,
                        onSelect: onSelect,
                      ),
                    ),
                  ],
                  if (closedItems.isNotEmpty) ...[
                    if (openItems.isNotEmpty) const SizedBox(height: 8),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      initiallyExpanded: selectedClosedItem,
                      title: Text(
                        'Storico chiuso',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text('${closedItems.length} esercizi'),
                      children: closedItems
                          .map(
                            (item) => _ExerciseTile(
                              item: item,
                              selectedId: selectedId,
                              onSelect: onSelect,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.end,
                    runSpacing: 8,
                    spacing: 12,
                    children: [
                      if (canCreate)
                        OutlinedButton.icon(
                          onPressed: selectedId == null ||
                                  selectedIsClosed ||
                                  isClosingExercise
                              ? null
                              : onCloseSelected,
                          icon: isClosingExercise
                              ? const SizedBox.square(
                                  dimension: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.lock_outline),
                          label: const Text('Chiudi esercizio'),
                        ),
                      FilledButton.icon(
                        onPressed: selectedId == null ? null : onContinue,
                        icon: Icon(
                          selectedIsClosed
                              ? Icons.visibility_outlined
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          selectedIsClosed ? 'Apri storico' : 'Continua',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.item,
    required this.selectedId,
    required this.onSelect,
  });

  final ManagedCondominio item;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onSelect(item.id),
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selectedId == item.id ? Icons.check_circle : Icons.circle_outlined,
      ),
      title: Row(
        children: [
          Expanded(child: Text(item.displayLabel)),
          _ExerciseStateChip(isClosed: item.isClosed),
        ],
      ),
      subtitle: Text('Residuo ${item.residuo.toStringAsFixed(2)}'),
    );
  }
}

class _ExerciseStateChip extends StatelessWidget {
  const _ExerciseStateChip({required this.isClosed});

  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    final color = isClosed
        ? const Color(0xFF9B1C1C)
        : const Color(0xFF155E75);
    final background = isClosed
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFE3F0F4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isClosed ? 'Chiuso' : 'Aperto',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }
}

/// Form di creazione nuovo esercizio sotto un root esistente.
///
/// La policy di ereditarieta' e' resa esplicita direttamente nel form:
/// anagrafica, accessi, quote, tabelle e configurazioni spesa vengono copiate;
/// movimenti, versamenti e rate restano confinati all'esercizio chiuso.
class CreateEsercizioCard extends StatelessWidget {
  const CreateEsercizioCard({
    super.key,
    required this.formKey,
    required this.roots,
    required this.selectedRootId,
    required this.gestioneController,
    required this.annoController,
    required this.saldoInizialeController,
    required this.isCreatingExercise,
    required this.carryOverBalances,
    required this.latestExercise,
    required this.hasOpenExercise,
    required this.onRootChanged,
    required this.onGestioneChanged,
    required this.onCarryOverChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final List<ManagedCondominioRoot> roots;
  final String? selectedRootId;
  final TextEditingController gestioneController;
  final TextEditingController annoController;
  final TextEditingController saldoInizialeController;
  final bool isCreatingExercise;
  final bool carryOverBalances;
  final ManagedCondominio? latestExercise;
  final bool hasOpenExercise;
  final ValueChanged<String?> onRootChanged;
  final ValueChanged<String> onGestioneChanged;
  final ValueChanged<bool> onCarryOverChanged;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final effectiveRootId = selectedRootId ?? (roots.isNotEmpty ? roots.first.id : null);
    final inheritedSaldo = latestExercise?.residuo ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crea nuovo esercizio',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: roots.any((root) => root.id == effectiveRootId)
                    ? effectiveRootId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Condominio reale',
                ),
                items: roots
                    .map(
                      (root) => DropdownMenuItem<String>(
                        value: root.id,
                        child: Text(root.label),
                      ),
                    )
                    .toList(),
                onChanged: onRootChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Seleziona il condominio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: gestioneController,
                decoration: const InputDecoration(
                  labelText: 'Gestione',
                  helperText:
                      'Esempi: Ordinaria, Riscaldamento, Straordinaria ascensore',
                ),
                onChanged: onGestioneChanged,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci la gestione';
                  }
                  return null;
                },
              ),
              if (latestExercise != null) ...[
                const SizedBox(height: 12),
                _LatestExerciseCard(
                  latestExercise: latestExercise!,
                  hasOpenExercise: hasOpenExercise,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: annoController,
                decoration: const InputDecoration(labelText: 'Anno esercizio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  if (year == null) return 'Anno non valido';
                  if (year < 1900 || year > 2100) {
                    return 'Anno fuori range';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: carryOverBalances,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: latestExercise == null
                    ? null
                    : (value) => onCarryOverChanged(value ?? false),
                title: const Text('Riporta saldi finali'),
                subtitle: Text(
                  latestExercise == null
                      ? 'Nessun esercizio precedente disponibile.'
                      : 'Il nuovo esercizio parte dal residuo finale ${inheritedSaldo.toStringAsFixed(2)} dell\'ultimo esercizio.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: saldoInizialeController,
                enabled: !carryOverBalances || latestExercise == null,
                decoration: InputDecoration(
                  labelText: 'Saldo iniziale esercizio',
                  helperText: carryOverBalances && latestExercise != null
                      ? 'Valore derivato automaticamente dal residuo finale dell\'esercizio precedente.'
                      : 'Puoi inserire un valore positivo o negativo.',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (parsed == null) return 'Saldo iniziale non valido';
                  if (!parsed.isFinite) return 'Saldo iniziale non valido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _InheritanceSummary(
                carryOverBalances: carryOverBalances,
                latestExercise: latestExercise,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isCreatingExercise || hasOpenExercise
                      ? null
                      : onSubmit,
                  icon: isCreatingExercise
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calendar_month_outlined),
                  label: const Text('Crea esercizio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestExerciseCard extends StatelessWidget {
  const _LatestExerciseCard({
    required this.latestExercise,
    required this.hasOpenExercise,
  });

  final ManagedCondominio latestExercise;
  final bool hasOpenExercise;

  @override
  Widget build(BuildContext context) {
    final warningColor = hasOpenExercise
        ? const Color(0xFF9B1C1C)
        : const Color(0xFF155E75);
    final backgroundColor = hasOpenExercise
        ? const Color(0xFFFEE2E2)
        : const Color(0xFFE3F0F4);
    final message = hasOpenExercise
        ? 'Chiudi prima l\'esercizio aperto ${latestExercise.displayLabel} per poterne creare uno nuovo nella stessa gestione.'
        : 'Ultimo esercizio disponibile per questa gestione: ${latestExercise.displayLabel}.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: warningColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Residuo finale ${latestExercise.residuo.toStringAsFixed(2)}',
            style: TextStyle(color: warningColor),
          ),
        ],
      ),
    );
  }
}

class _InheritanceSummary extends StatelessWidget {
  const _InheritanceSummary({
    required this.carryOverBalances,
    required this.latestExercise,
  });

  final bool carryOverBalances;
  final ManagedCondominio? latestExercise;

  @override
  Widget build(BuildContext context) {
    final saldoText = carryOverBalances && latestExercise != null
        ? 'I saldi iniziali vengono riportati dal residuo finale dell\'esercizio precedente.'
        : 'I saldi iniziali partono dal valore inserito nel form.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4ED),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Eredita: anagrafica condomini, accessi app, quote/millesimi, tabelle e configurazioni spesa.\n'
        'Non eredita: movimenti, versamenti e rate annuali.\n'
        '$saldoText',
      ),
    );
  }
}

/// Form di creazione condominio.
///
/// La validazione resta locale ai campi del form, mentre la page si occupa
/// dell'invocazione del notifier e del reset dei controller.
class CreateCondominioCard extends StatelessWidget {
  const CreateCondominioCard({
    super.key,
    required this.formKey,
    required this.labelController,
    required this.annoController,
    required this.saldoInizialeController,
    required this.isCreating,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController labelController;
  final TextEditingController annoController;
  final TextEditingController saldoInizialeController;
  final bool isCreating;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crea nuovo condominio',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Nome condominio',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                    ? 'Obbligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: annoController,
                decoration: const InputDecoration(labelText: 'Anno'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  if (year == null) return 'Anno non valido';
                  if (year < 1900 || year > 2100) {
                    return 'Anno fuori range';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: saldoInizialeController,
                decoration: const InputDecoration(
                  labelText: 'Saldo iniziale',
                  helperText: 'Puoi inserire un valore positivo o negativo',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (parsed == null) return 'Saldo iniziale non valido';
                  if (!parsed.isFinite) return 'Saldo iniziale non valido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: isCreating ? null : onSubmit,
                  icon: isCreating
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_home_work_outlined),
                  label: const Text('Crea condominio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
