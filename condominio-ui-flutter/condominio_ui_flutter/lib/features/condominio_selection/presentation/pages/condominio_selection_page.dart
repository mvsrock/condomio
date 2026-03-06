import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/application/auth_notifier.dart';
import '../../application/managed_condominio_notifier.dart';
import '../../domain/managed_condominio.dart';
import '../../domain/managed_condominio_root.dart';
import '../widgets/condominio_selection_sections.dart';

/// Schermata obbligatoria post-login:
/// - selezione del contesto esercizio
/// - creazione condominio root
/// - creazione nuovo esercizio solo dopo chiusura del precedente
class CondominioSelectionPage extends ConsumerStatefulWidget {
  const CondominioSelectionPage({super.key});

  @override
  ConsumerState<CondominioSelectionPage> createState() =>
      _CondominioSelectionPageState();
}

class _CondominioSelectionPageState
    extends ConsumerState<CondominioSelectionPage> {
  final _createRootFormKey = GlobalKey<FormState>();
  final _createExerciseFormKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _annoCtrl = TextEditingController(text: '${DateTime.now().year}');
  final _saldoInizialeCtrl = TextEditingController(text: '0');
  final _exerciseAnnoCtrl = TextEditingController(
    text: '${DateTime.now().year}',
  );
  final _exerciseSaldoInizialeCtrl = TextEditingController(text: '0');

  String? _selectedRootId;
  bool _carryOverBalances = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(managedCondominioProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _annoCtrl.dispose();
    _saldoInizialeCtrl.dispose();
    _exerciseAnnoCtrl.dispose();
    _exerciseSaldoInizialeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managedCondominioProvider);
    final notifier = ref.read(managedCondominioProvider.notifier);
    final canCreate = ref.watch(canCreateCondominioProvider);
    final selected = ref.watch(selectedManagedCondominioProvider);

    _ensureExerciseRootSelection(state);

    final effectiveRootId = _selectedRootId ??
        (state.roots.isNotEmpty ? state.roots.first.id : null);
    final latestExercise = effectiveRootId == null
        ? null
        : _latestExerciseForRoot(effectiveRootId, state.items);
    final hasOpenExercise = effectiveRootId == null
        ? false
        : _hasOpenExerciseForRoot(effectiveRootId, state.items);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona esercizio'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Conferma logout'),
                  content: const Text('Vuoi uscire dalla sessione corrente?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Annulla'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && mounted) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Aggiorna',
            onPressed: state.isLoading ? null : notifier.loadCondomini,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.errorMessage != null)
                CondominioSelectionErrorCard(message: state.errorMessage!),
              ManagedCondominiiCard(
                isLoading: state.isLoading,
                canCreate: canCreate,
                items: state.items,
                selectedId: state.selectedId,
                selectedIsClosed: selected?.isClosed ?? false,
                isClosingExercise: state.isClosingExercise,
                onSelect: notifier.select,
                onContinue: () => context.go('/home/dashboard'),
                onCloseSelected: () async {
                  final current = ref.read(selectedManagedCondominioProvider);
                  if (current == null || current.isClosed) {
                    return;
                  }
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Chiudi esercizio'),
                      content: Text(
                        'Confermi la chiusura di ${current.displayLabel}? Le scritture verranno bloccate.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annulla'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Chiudi'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await notifier.closeSelectedExercise();
                  }
                },
              ),
              const SizedBox(height: 12),
              if (canCreate)
                CreateCondominioCard(
                  formKey: _createRootFormKey,
                  labelController: _labelCtrl,
                  annoController: _annoCtrl,
                  saldoInizialeController: _saldoInizialeCtrl,
                  isCreating: state.isCreating,
                  onSubmit: () async {
                    if (!_createRootFormKey.currentState!.validate()) {
                      return;
                    }
                    await notifier.createCondominio(
                      label: _labelCtrl.text,
                      anno: int.parse(_annoCtrl.text),
                      saldoIniziale: double.parse(
                        _saldoInizialeCtrl.text.trim().replaceAll(',', '.'),
                      ),
                    );
                    _labelCtrl.clear();
                    _saldoInizialeCtrl.text = '0';
                  },
                ),
              if (canCreate && state.roots.isNotEmpty) ...[
                const SizedBox(height: 12),
                CreateEsercizioCard(
                  formKey: _createExerciseFormKey,
                  roots: state.roots,
                  selectedRootId: effectiveRootId,
                  annoController: _exerciseAnnoCtrl,
                  saldoInizialeController: _exerciseSaldoInizialeCtrl,
                  isCreatingExercise: state.isCreatingExercise,
                  carryOverBalances: _carryOverBalances,
                  latestExercise: latestExercise,
                  hasOpenExercise: hasOpenExercise,
                  onRootChanged: (value) => _onRootChanged(value, state.items),
                  onCarryOverChanged: (value) =>
                      _onCarryOverChanged(value, latestExercise),
                  onSubmit: () async {
                    if (!_createExerciseFormKey.currentState!.validate()) {
                      return;
                    }
                    final rootId = effectiveRootId;
                    if (rootId == null) {
                      return;
                    }
                    final root = _findRootById(state.roots, rootId);
                    if (root == null) {
                      return;
                    }
                    await notifier.createExercise(
                      rootId: root.id,
                      label: root.label,
                      anno: int.parse(_exerciseAnnoCtrl.text),
                      saldoIniziale: double.parse(
                        _exerciseSaldoInizialeCtrl.text
                            .trim()
                            .replaceAll(',', '.'),
                      ),
                      carryOverBalances: _carryOverBalances,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _ensureExerciseRootSelection(ManagedCondominioState state) {
    if (state.roots.isEmpty) {
      if (_selectedRootId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _selectedRootId = null;
            _carryOverBalances = false;
          });
          _exerciseAnnoCtrl.text = '${DateTime.now().year}';
          _exerciseSaldoInizialeCtrl.text = '0';
        });
      }
      return;
    }

    final currentIsValid =
        _selectedRootId != null && _findRootById(state.roots, _selectedRootId!) != null;
    if (currentIsValid) {
      return;
    }

    final fallbackRootId = state.roots.first.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedRootId = fallbackRootId;
        _carryOverBalances = false;
      });
      _applyExerciseDefaultsForRoot(
        rootId: fallbackRootId,
        items: state.items,
      );
    });
  }

  void _onRootChanged(String? rootId, List<ManagedCondominio> items) {
    if (rootId == null) {
      return;
    }
    setState(() {
      _selectedRootId = rootId;
      _carryOverBalances = false;
    });
    _applyExerciseDefaultsForRoot(rootId: rootId, items: items);
  }

  void _onCarryOverChanged(bool value, ManagedCondominio? latestExercise) {
    setState(() {
      _carryOverBalances = value;
    });
    if (value && latestExercise != null) {
      _exerciseSaldoInizialeCtrl.text = _formatAmount(latestExercise.residuo);
      return;
    }
    if (!value) {
      _exerciseSaldoInizialeCtrl.text = '0';
    }
  }

  void _applyExerciseDefaultsForRoot({
    required String rootId,
    required List<ManagedCondominio> items,
  }) {
    final latest = _latestExerciseForRoot(rootId, items);
    final suggestedYear = latest == null ? DateTime.now().year : latest.anno + 1;
    _exerciseAnnoCtrl.text = '$suggestedYear';
    if (_carryOverBalances && latest != null) {
      _exerciseSaldoInizialeCtrl.text = _formatAmount(latest.residuo);
    } else {
      _exerciseSaldoInizialeCtrl.text = '0';
    }
  }

  ManagedCondominio? _latestExerciseForRoot(
    String rootId,
    List<ManagedCondominio> items,
  ) {
    ManagedCondominio? latest;
    for (final item in items) {
      if (item.condominioRootId != rootId) {
        continue;
      }
      if (latest == null || item.anno > latest.anno) {
        latest = item;
      }
    }
    return latest;
  }

  bool _hasOpenExerciseForRoot(String rootId, List<ManagedCondominio> items) {
    return items.any(
      (item) => item.condominioRootId == rootId && !item.isClosed,
    );
  }

  ManagedCondominioRoot? _findRootById(
    List<ManagedCondominioRoot> roots,
    String rootId,
  ) {
    for (final root in roots) {
      if (root.id == rootId) {
        return root;
      }
    }
    return null;
  }

  String _formatAmount(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
