import 'package:flutter/material.dart';

class RegistryCessazioneResult {
  const RegistryCessazioneResult({
    required this.dataCessazione,
    required this.motivo,
  });

  final DateTime dataCessazione;
  final String? motivo;
}

class RegistrySubentroResult {
  const RegistrySubentroResult({
    required this.dataSubentro,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.telefono,
    required this.saldoIniziale,
    required this.carryOverSaldo,
  });

  final DateTime dataSubentro;
  final String nome;
  final String cognome;
  final String email;
  final String telefono;
  final double saldoIniziale;
  final bool carryOverSaldo;
}

class RegistryCessazioneDialog extends StatefulWidget {
  const RegistryCessazioneDialog({super.key, required this.initialDate});

  final DateTime initialDate;

  @override
  State<RegistryCessazioneDialog> createState() => _RegistryCessazioneDialogState();
}

class _RegistryCessazioneDialogState extends State<RegistryCessazioneDialog> {
  late DateTime _selectedDate;
  final _motivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cessa posizione'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Data cessazione'),
            subtitle: Text(_formatDate(_selectedDate)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickDate,
          ),
          TextField(
            controller: _motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo',
              hintText: 'es. vendita unita',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            RegistryCessazioneResult(
              dataCessazione: _selectedDate,
              motivo: _motivoController.text.trim().isEmpty
                  ? null
                  : _motivoController.text.trim(),
            ),
          ),
          child: const Text('Conferma'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedDate = selected);
  }
}

class RegistrySubentroDialog extends StatefulWidget {
  const RegistrySubentroDialog({
    super.key,
    required this.initialDate,
    required this.initialNome,
    required this.initialCognome,
    required this.initialEmail,
    required this.initialTelefono,
  });

  final DateTime initialDate;
  final String initialNome;
  final String initialCognome;
  final String initialEmail;
  final String initialTelefono;

  @override
  State<RegistrySubentroDialog> createState() => _RegistrySubentroDialogState();
}

class _RegistrySubentroDialogState extends State<RegistrySubentroDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late final TextEditingController _nomeController;
  late final TextEditingController _cognomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefonoController;
  final _saldoController = TextEditingController(text: '0');
  bool _carryOverSaldo = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _nomeController = TextEditingController(text: widget.initialNome);
    _cognomeController = TextEditingController(text: widget.initialCognome);
    _emailController = TextEditingController(text: widget.initialEmail);
    _telefonoController = TextEditingController(text: widget.initialTelefono);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registra subentro'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Data subentro'),
                  subtitle: Text(_formatDate(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cognomeController,
                  decoration: const InputDecoration(labelText: 'Cognome'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _optionalEmail,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(labelText: 'Telefono'),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Riporta saldo del precedente'),
                  value: _carryOverSaldo,
                  onChanged: (value) => setState(() => _carryOverSaldo = value),
                ),
                if (!_carryOverSaldo) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _saldoController,
                    decoration: const InputDecoration(labelText: 'Saldo iniziale nuovo soggetto'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _decimal,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Conferma subentro'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null) {
      return;
    }
    setState(() => _selectedDate = selected);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      RegistrySubentroResult(
        dataSubentro: _selectedDate,
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        saldoIniziale: _carryOverSaldo
            ? 0
            : double.parse(_saldoController.text.trim().replaceAll(',', '.')),
        carryOverSaldo: _carryOverSaldo,
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obbligatorio';
    }
    return null;
  }

  String? _optionalEmail(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    return normalized.contains('@') ? null : 'Email non valida';
  }

  String? _decimal(String? value) {
    final normalized = (value ?? '').trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return 'Campo obbligatorio';
    }
    return double.tryParse(normalized) == null ? 'Numero non valido' : null;
  }
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month/${local.year}';
}
