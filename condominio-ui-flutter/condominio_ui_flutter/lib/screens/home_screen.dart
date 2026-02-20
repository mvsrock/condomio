import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/condomino.dart';
import '../providers/auth_provider.dart';
import '../providers/condomini_provider.dart';
import '../providers/home_ui_provider.dart';
import '../providers/keycloak_provider.dart';
import '../utils/app_logger.dart';
import '../widgets/home/home_bottom_navigation.dart';
import '../widgets/home/home_content_surface.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/home_navigation_rail.dart';
import '../widgets/home/pages/dashboard_page.dart';
import '../widgets/home/pages/map_page.dart';
import '../widgets/home/pages/registry_page.dart';
import '../widgets/home/pages/session_page.dart';

/// Schermata visibile quando la sessione e' autenticata.
///
/// Layout:
/// - header in alto a tutta larghezza
/// - navigazione interna (`Dashboard`, `Mappa`, `Anagrafica`, `Sessione`)
/// - contenuto principale reattivo alla voce selezionata
///
/// Strategia rebuild (importante):
/// 1) Root `HomeScreen.build()` osserva SOLO `selectedIndex`.
///    Quindi questa root si ricostruisce quando cambi tab, non quando cambi hover riga.
/// 2) Lo stato anagrafica (`condomini`, `selectedCondominoId`)
///    viene osservato nel `Consumer` locale del case `2`.
///    Questo confina il refresh alla sola pagina anagrafica.
/// 3) Espansione azioni riga usa stato locale della riga (`StatefulWidget`),
///    quindi rebuilda solo quella singola riga.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    final keycloak = ref.read(keycloakServiceProvider);
    appLog('[HomeScreen] User is authenticated: ${keycloak.isAuthenticated}');
    appLog('[HomeScreen] Has access token: ${keycloak.accessToken != null}');
    appLog('[HomeScreen] Has ID token: ${keycloak.idToken != null}');
  }

  Future<void> _logout() async {
    ref.read(homeUiProvider.notifier).setLoggingOut(true);
    try {
      appLog('[HomeScreen] Initiating logout...');
      await ref.read(authStateProvider.notifier).logout();
    } catch (e) {
      appLog('[HomeScreen] Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
        ref.read(homeUiProvider.notifier).setLoggingOut(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trigger rebuild DI QUESTA ROOT:
    // - SI: quando cambia `state.selectedIndex` (es. click su rail/nav bottom)
    // - NO: quando cambia `selectedCondominoId`
    //       perche' qui non osserviamo l'intero provider ma solo il campo selezionato.
    final selectedIndex = ref.watch(
      homeUiProvider.select((state) => state.selectedIndex),
    );
    final isLoggingOut = ref.watch(
      homeUiProvider.select((state) => state.isLoggingOut),
    );
    final uiNotifier = ref.read(homeUiProvider.notifier);
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 960;

    if (isLoggingOut) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(onLogout: _logout),
            Expanded(
              child: isWide
                  ? Row(
                      children: [
                        HomeNavigationRail(
                          selectedIndex: selectedIndex,
                          onDestinationSelected: uiNotifier.selectTab,
                        ),
                        Expanded(
                          child: HomeContentSurface(
                            isWide: isWide,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              child: KeyedSubtree(
                                key: ValueKey(selectedIndex),
                                child: _buildPage(
                                  selectedIndex: selectedIndex,
                                  uiNotifier: uiNotifier,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : HomeContentSurface(
                      isWide: isWide,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(
                          key: ValueKey(selectedIndex),
                          child: _buildPage(
                            selectedIndex: selectedIndex,
                            uiNotifier: uiNotifier,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWide
          ? null
          : HomeBottomNavigation(
              selectedIndex: selectedIndex,
              onDestinationSelected: uiNotifier.selectTab,
            ),
    );
  }

  Widget _buildPage({
    required int selectedIndex,
    required HomeUiNotifier uiNotifier,
  }) {
    // Switch tab:
    // - `selectedIndex` determina quale pagina istanziare.
    // - `AnimatedSwitcher` anima la sostituzione del body.
    // - Header e navigazione restano fuori dallo switch: non vengono ricreati
    //   da cambi interni alla singola pagina.
    return switch (selectedIndex) {
      // Rebuild Dashboard solo su cambio dati Keycloak o cambio tab.
      0 => DashboardPage(keycloak: ref.watch(keycloakServiceProvider)),
      1 => const MapPage(),
      // Consumer locale della pagina anagrafica:
      // - osserva SOLO provider usati da questa pagina.
      // - se cambia anagrafica, non viene ricostruito il layout globale della home.
      2 => Consumer(
          builder: (context, ref, child) {
            final condomini = ref.watch(condominiProvider);
            // Ogni `select` ascolta un singolo campo, non l'intero stato home UI.
            final selectedCondominoId = ref.watch(
              homeUiProvider.select((state) => state.selectedCondominoId),
            );
            return RegistryPage(
              condomini: condomini,
              selectedCondominoId: selectedCondominoId,
              onCondominoRowTap: (selected) {
                uiNotifier.selectCondomino(selected.id);
              },
              onCondominoTap: (selected) {
                _openCondominoDetailScreen(selected);
              },
              onCondominoEdit: _openCondominoEditScreen,
            );
          },
        ),
      _ => SessionPage(keycloak: ref.watch(keycloakServiceProvider)),
    };
  }

  Future<void> _openCondominoDetailScreen(Condomino selected) async {
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

  Future<void> _openCondominoEditScreen(Condomino condomino) async {
    final updated = await Navigator.of(context).push<Condomino>(
      MaterialPageRoute(
        builder: (_) => _CondominoEditScreen(condomino: condomino),
      ),
    );
    if (updated != null) {
      ref.read(condominiProvider.notifier).updateCondomino(updated);
      if (mounted) {
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
  /// Snapshot locale del record mostrato in questa pagina.
  ///
  /// E' stato di vista temporaneo (solo dettaglio corrente), quindi resta locale
  /// e non viene messo in provider globale.
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
                            _ValuePill(
                              label: 'ID',
                              value: _current.id,
                            ),
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
  /// Stato form locale della switch residente.
  ///
  /// Non e' condiviso tra schermate: usarlo in `setState` evita rumore nel layer provider.
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
