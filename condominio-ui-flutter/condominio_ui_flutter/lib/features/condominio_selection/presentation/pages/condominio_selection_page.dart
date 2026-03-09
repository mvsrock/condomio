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
  static const _exerciseMode = _CreationMode.exercise;
  static const _rootMode = _CreationMode.root;

  final _createRootFormKey = GlobalKey<FormState>();
  final _createExerciseFormKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _annoCtrl = TextEditingController(text: '${DateTime.now().year}');
  final _saldoInizialeCtrl = TextEditingController(text: '0');
  final _exerciseGestioneCtrl = TextEditingController(text: 'Ordinaria');
  final _exerciseAnnoCtrl = TextEditingController(
    text: '${DateTime.now().year}',
  );
  final _exerciseSaldoInizialeCtrl = TextEditingController(text: '0');

  String? _selectedRootId;
  bool _carryOverBalances = false;
  _CreationMode _creationMode = _CreationMode.exercise;

  @override
  void initState() {
    super.initState();
    _exerciseGestioneCtrl.addListener(_handleGestioneChanged);
    Future.microtask(() {
      ref.read(managedCondominioProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _annoCtrl.dispose();
    _saldoInizialeCtrl.dispose();
    _exerciseGestioneCtrl.removeListener(_handleGestioneChanged);
    _exerciseGestioneCtrl.dispose();
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
    final openExercisesCount = state.items.where((item) => !item.isClosed).length;
    final closedExercisesCount = state.items.where((item) => item.isClosed).length;
    final canCreateExercise = canCreate && state.roots.isNotEmpty;
    if (!canCreateExercise && _creationMode != _rootMode) {
      _creationMode = _rootMode;
    }

    _ensureExerciseRootSelection(state);

    final effectiveRootId = _selectedRootId ??
        (state.roots.isNotEmpty ? state.roots.first.id : null);
    final effectiveGestioneCode = _normalizeGestione(_exerciseGestioneCtrl.text);
    final latestExercise = effectiveRootId == null
        ? null
        : _latestExerciseForRootAndGestione(
            effectiveRootId,
            effectiveGestioneCode,
            state.items,
          );
    final hasOpenExercise = effectiveRootId == null
        ? false
        : _hasOpenExerciseForRootAndGestione(
            effectiveRootId,
            effectiveGestioneCode,
            state.items,
          );

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
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 980;
              final selectionCard = ManagedCondominiiCard(
                isLoading: state.isLoading,
                canCreate: canCreate,
                rootsCount: state.roots.length,
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
              );

              final actionCards = <Widget>[
                if (canCreate)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F0F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_mosaic_outlined,
                                  color: Color(0xFF155E75),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Azioni di creazione',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Scegli una sola operazione: apri un nuovo esercizio o registra un nuovo condominio.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          if (canCreateExercise)
                            SegmentedButton<_CreationMode>(
                              segments: const [
                                ButtonSegment<_CreationMode>(
                                  value: _exerciseMode,
                                  icon: Icon(Icons.calendar_month_outlined),
                                  label: Text('Nuovo esercizio'),
                                ),
                                ButtonSegment<_CreationMode>(
                                  value: _rootMode,
                                  icon: Icon(Icons.add_home_work_outlined),
                                  label: Text('Nuovo condominio'),
                                ),
                              ],
                              selected: {_creationMode},
                              onSelectionChanged: (selection) {
                                if (selection.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _creationMode = selection.first;
                                });
                              },
                            )
                          else
                            const Text(
                              'Crea prima il primo condominio, poi potrai aprire nuovi esercizi.',
                            ),
                        ],
                      ),
                    ),
                  ),
                if (canCreate)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: (!canCreateExercise || _creationMode == _rootMode)
                        ? KeyedSubtree(
                            key: const ValueKey('create-root'),
                            child: CreateCondominioCard(
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
                                if (mounted) {
                                  setState(() {
                                    _creationMode = _exerciseMode;
                                  });
                                }
                              },
                            ),
                          )
                        : KeyedSubtree(
                            key: const ValueKey('create-exercise'),
                            child: CreateEsercizioCard(
                              formKey: _createExerciseFormKey,
                              roots: state.roots,
                              selectedRootId: effectiveRootId,
                              gestioneController: _exerciseGestioneCtrl,
                              annoController: _exerciseAnnoCtrl,
                              saldoInizialeController: _exerciseSaldoInizialeCtrl,
                              isCreatingExercise: state.isCreatingExercise,
                              carryOverBalances: _carryOverBalances,
                              latestExercise: latestExercise,
                              hasOpenExercise: hasOpenExercise,
                              onRootChanged: (value) => _onRootChanged(value, state.items),
                              onGestioneChanged: (_) => _applyExerciseDefaultsForCurrentContext(
                                items: state.items,
                              ),
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
                                  gestioneLabel: _exerciseGestioneCtrl.text,
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
                          ),
                  ),
              ];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.errorMessage != null)
                    CondominioSelectionErrorCard(message: state.errorMessage!),
                  CondominioSelectionOverviewStrip(
                    rootsCount: state.roots.length,
                    openExercisesCount: openExercisesCount,
                    closedExercisesCount: closedExercisesCount,
                    selectedExerciseLabel: selected?.displayLabel,
                  ),
                  const SizedBox(height: 12),
                  if (!isWide) ...[
                    selectionCard,
                    if (actionCards.isNotEmpty) const SizedBox(height: 12),
                    ..._withSpacing(actionCards, spacing: 12),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 8, child: selectionCard),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: _withSpacing(actionCards, spacing: 12),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
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
          _exerciseGestioneCtrl.text = 'Ordinaria';
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
      _applyExerciseDefaultsForRoot(rootId: fallbackRootId, items: state.items);
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
    final latestForRoot = _latestExerciseForRoot(rootId, items);
    if (latestForRoot != null) {
      _exerciseGestioneCtrl.text = latestForRoot.gestioneLabel;
    } else if (_exerciseGestioneCtrl.text.trim().isEmpty) {
      _exerciseGestioneCtrl.text = 'Ordinaria';
    }
    _applyExerciseDefaultsForCurrentContext(items: items);
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

  ManagedCondominio? _latestExerciseForRootAndGestione(
    String rootId,
    String gestioneCode,
    List<ManagedCondominio> items,
  ) {
    ManagedCondominio? latest;
    for (final item in items) {
      if (item.condominioRootId != rootId || item.gestioneCode != gestioneCode) {
        continue;
      }
      if (latest == null || item.anno > latest.anno) {
        latest = item;
      }
    }
    return latest;
  }

  bool _hasOpenExerciseForRootAndGestione(
    String rootId,
    String gestioneCode,
    List<ManagedCondominio> items,
  ) {
    return items.any(
      (item) =>
          item.condominioRootId == rootId &&
          item.gestioneCode == gestioneCode &&
          !item.isClosed,
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

  void _handleGestioneChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _applyExerciseDefaultsForCurrentContext({
    required List<ManagedCondominio> items,
  }) {
    final rootId = _selectedRootId;
    if (rootId == null) {
      return;
    }
    final latest = _latestExerciseForRootAndGestione(
      rootId,
      _normalizeGestione(_exerciseGestioneCtrl.text),
      items,
    );
    if (latest == null && _carryOverBalances) {
      setState(() {
        _carryOverBalances = false;
      });
    }
    final suggestedYear = latest == null ? DateTime.now().year : latest.anno + 1;
    _exerciseAnnoCtrl.text = '$suggestedYear';
    if (_carryOverBalances && latest != null) {
      _exerciseSaldoInizialeCtrl.text = _formatAmount(latest.residuo);
    } else {
      _exerciseSaldoInizialeCtrl.text = '0';
    }
  }

  String _normalizeGestione(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return 'ordinaria';
    }
    return normalized.toLowerCase();
  }

  List<Widget> _withSpacing(List<Widget> widgets, {required double spacing}) {
    if (widgets.isEmpty) {
      return const <Widget>[];
    }
    final result = <Widget>[];
    for (var index = 0; index < widgets.length; index++) {
      result.add(widgets[index]);
      if (index != widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}

enum _CreationMode { exercise, root }
