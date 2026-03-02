import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/application/home_ui_notifier.dart';
import '../../application/condomini_notifier.dart';
import '../../domain/condomino.dart';
import 'registry_page.dart';

/// Container route-level della tab Anagrafica.
///
/// Responsabilita':
/// - collega `RegistryPage` allo stato UI condiviso (`homeUiProvider`)
/// - gestisce apertura dettaglio/modifica tramite `Navigator`
/// - propaga eventuali update al provider dominio `condominiProvider`
class RegistryTabPage extends ConsumerWidget {
  const RegistryTabPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCondominoId = ref.watch(
      homeUiProvider.select((state) => state.selectedCondominoId),
    );
    final uiNotifier = ref.read(homeUiProvider.notifier);

    return RegistryPage(
      selectedCondominoId: selectedCondominoId,
      onCondominoRowTap: (selected) => uiNotifier.selectCondomino(selected.id),
      onCondominoTap: (selected) => _openCondominoDetailScreen(
        context: context,
        ref: ref,
        selected: selected,
      ),
      onCondominoEdit: (condomino) => _openCondominoEditScreen(
        context: context,
        ref: ref,
        condomino: condomino,
      ),
    );
  }

  Future<void> _openCondominoDetailScreen({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino selected,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _CondominoDetailScreen(
          condomino: selected,
          onUpdated: (updated) {
            ref.read(condominiProvider.notifier).updateCondomino(updated);
          },
        ),
      ),
    );
  }

  Future<void> _openCondominoEditScreen({
    required BuildContext context,
    required WidgetRef ref,
    required Condomino condomino,
  }) async {
    final updated = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => _CondominoEditScreen(condomino: condomino),
      ),
    );
    if (updated != null) {
      ref.read(condominiProvider.notifier).updateCondomino(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modifica salvata.')),
        );
      }
    }
  }
}

class _CondominoDetailScreen extends StatefulWidget {
  const _CondominoDetailScreen({
    required this.condomino,
    required this.onUpdated,
  });

  final Condomino condomino;
  final ValueChanged<Condomino> onUpdated;

  @override
  State<_CondominoDetailScreen> createState() => _CondominoDetailScreenState();
}

class _CondominoDetailScreenState extends State<_CondominoDetailScreen> {
  late Condomino _current;

  @override
  void initState() {
    super.initState();
    _current = widget.condomino;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio condomino'),
        actions: [
          FilledButton.tonalIcon(
            onPressed: _openEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modifica'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Card(
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
                                      _current.nominativo,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _current.unita,
                                      style: const TextStyle(
                                        color: Color(0xFF486581),
                                      ),
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
                            _ValuePill(label: 'ID', value: _current.id),
                            _ValuePill(
                              label: 'Millesimi',
                              value: _current.millesimi.toStringAsFixed(2),
                            ),
                            _ValuePill(
                              label: 'Stato',
                              value: _current.residente
                                  ? 'Residente'
                                  : 'Non residente',
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _DetailRow(label: 'Email', value: _current.email),
                        _DetailRow(label: 'Telefono', value: _current.telefono),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => _CondominoEditScreen(condomino: _current),
      ),
    );
    if (updated == null) return;
    widget.onUpdated(updated);
    if (!mounted) return;
    setState(() => _current = updated);
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

class _ValuePill extends StatelessWidget {
  const _ValuePill({required this.label, required this.value});

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

class _CondominoEditScreen extends StatefulWidget {
  const _CondominoEditScreen({required this.condomino});

  final Condomino condomino;

  @override
  State<_CondominoEditScreen> createState() => _CondominoEditScreenState();
}

class _CondominoEditScreenState extends State<_CondominoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cognomeController;
  late final TextEditingController _scalaController;
  late final TextEditingController _internoController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  late final TextEditingController _millesimiController;
  late bool _residente;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.condomino.nome);
    _cognomeController = TextEditingController(text: widget.condomino.cognome);
    _scalaController = TextEditingController(text: widget.condomino.scala);
    _internoController = TextEditingController(text: widget.condomino.interno);
    _emailController = TextEditingController(text: widget.condomino.email);
    _telefonoController = TextEditingController(text: widget.condomino.telefono);
    _millesimiController = TextEditingController(
      text: widget.condomino.millesimi.toStringAsFixed(2),
    );
    _residente = widget.condomino.residente;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _scalaController.dispose();
    _internoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _millesimiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica condomino'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2F6FA), Color(0xFFE7EEF5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Dati anagrafici',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _nomeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Campo obbligatorio'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cognomeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Cognome',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Campo obbligatorio'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _scalaController,
                                  decoration: const InputDecoration(
                                    labelText: 'Scala',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _internoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Interno',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Contatti e quote',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(labelText: 'Telefono'),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _millesimiController,
                            decoration: const InputDecoration(
                              labelText: 'Millesimi',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Campo obbligatorio';
                              }
                              final parsed = double.tryParse(
                                value.trim().replaceAll(',', '.'),
                              );
                              if (parsed == null) {
                                return 'Valore non valido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Residente'),
                            value: _residente,
                            onChanged: (value) {
                              setState(() => _residente = value);
                            },
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _save,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Salva modifiche'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final parsedMillesimi = double.parse(
      _millesimiController.text.trim().replaceAll(',', '.'),
    );
    Navigator.of(context).pop(
      widget.condomino.copyWith(
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        scala: _scalaController.text.trim(),
        interno: _internoController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        millesimi: parsedMillesimi,
        residente: _residente,
      ),
    );
  }
}
