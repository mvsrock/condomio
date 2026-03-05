import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/application/auth_notifier.dart';
import '../../application/managed_condominio_notifier.dart';

/// Schermata obbligatoria post-login:
/// - selezione condominio da amministrare
/// - creazione condominio se la lista e' vuota
class CondominioSelectionPage extends ConsumerStatefulWidget {
  const CondominioSelectionPage({super.key});

  @override
  ConsumerState<CondominioSelectionPage> createState() =>
      _CondominioSelectionPageState();
}

class _CondominioSelectionPageState
    extends ConsumerState<CondominioSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _annoCtrl = TextEditingController(text: '${DateTime.now().year}');
  final _saldoInizialeCtrl = TextEditingController(text: '0');

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(managedCondominioProvider);
    final notifier = ref.read(managedCondominioProvider.notifier);
    final canCreate = ref.watch(canCreateCondominioProvider);
    final hasItems = state.items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleziona Condominio'),
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
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: state.isLoading
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
                              'Condomini assegnati',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            if (!hasItems)
                              Text(
                                canCreate
                                    ? 'Non hai ancora condomini. Crea il primo per continuare.'
                                    : 'Non hai condomini assegnati. Contatta un amministratore.',
                              ),
                            if (hasItems)
                              ...state.items.map(
                                (item) => ListTile(
                                  onTap: () => notifier.select(item.id),
                                  leading: Icon(
                                    state.selectedId == item.id
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                  ),
                                  title: Text(item.label),
                                  subtitle: Text(
                                    'Anno ${item.anno} - Residuo ${item.residuo.toStringAsFixed(2)}',
                                  ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: state.selectedId == null
                                    ? null
                                    : () => context.go('/home/dashboard'),
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Continua'),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (canCreate)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crea nuovo condominio',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _labelCtrl,
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
                            controller: _annoCtrl,
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
                            controller: _saldoInizialeCtrl,
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
                              onPressed: state.isCreating
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      await notifier.createCondominio(
                                        label: _labelCtrl.text,
                                        anno: int.parse(_annoCtrl.text),
                                        saldoIniziale: double.parse(
                                          _saldoInizialeCtrl.text
                                              .trim()
                                              .replaceAll(',', '.'),
                                        ),
                                      );
                                      _labelCtrl.clear();
                                      _saldoInizialeCtrl.text = '0';
                                    },
                              icon: state.isCreating
                                  ? const SizedBox.square(
                                      dimension: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add_home_work_outlined),
                              label: const Text('Crea condominio'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
