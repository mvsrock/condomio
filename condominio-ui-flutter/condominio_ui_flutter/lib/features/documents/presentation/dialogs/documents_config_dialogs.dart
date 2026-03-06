import 'package:flutter/material.dart';

import '../../domain/condominio_document_model.dart';
import '../../domain/condomino_document_model.dart';
import '../../domain/tabella_model.dart';

/// Dialog condiviso per configurare i codici spesa e la loro ripartizione
/// percentuale sulle tabelle del condominio selezionato.
class DocumentsConfigurazioniSpesaDialog extends StatefulWidget {
  const DocumentsConfigurazioniSpesaDialog({
    super.key,
    required this.initial,
    required this.tabelle,
  });

  final List<DocumentsConfigurazioneSpesaDraft> initial;
  final List<TabellaModel> tabelle;

  @override
  State<DocumentsConfigurazioniSpesaDialog> createState() =>
      _DocumentsConfigurazioniSpesaDialogState();
}

class _DocumentsConfigurazioniSpesaDialogState
    extends State<DocumentsConfigurazioniSpesaDialog> {
  late List<DocumentsConfigurazioneSpesaDraft> _items;
  bool _rebuildStorico = false;

  @override
  void initState() {
    super.initState();
    _items = widget.initial.map((e) => e.copy()).toList(growable: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configura riparto spese'),
      content: SizedBox(
        width: 760,
        height: 520,
        child: ListView(
          children: [
            const Text(
              'Le modifiche vengono applicate quando premi "Salva".',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Nessuna configurazione presente.'),
              ),
            for (var i = 0; i < _items.length; i++) _buildConfigurazioneCard(i),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addConfigurazione,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi codice spesa'),
            ),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rebuildStorico,
              onChanged: (value) {
                setState(() => _rebuildStorico = value ?? false);
              },
              title: const Text('Ricostruisci storico'),
              subtitle: const Text(
                'Applica le modifiche a tutte le spese gia registrate '
                'dell\'anno corrente.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  Widget _buildConfigurazioneCard(int index) {
    final item = _items[index];
    return Card(
      key: ValueKey('cfg-${item.uid}'),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('cfg-code-${item.uid}'),
                    initialValue: item.codice,
                    decoration: const InputDecoration(labelText: 'Codice spesa'),
                    onChanged: (value) => item.codice = value,
                  ),
                ),
                IconButton(
                  tooltip: 'Duplica configurazione',
                  onPressed: () => setState(() {
                    final duplicate = item.copy();
                    duplicate.codice = '${item.codice}_copy';
                    _items.insert(index + 1, duplicate);
                  }),
                  icon: const Icon(Icons.copy_outlined),
                ),
                IconButton(
                  tooltip: 'Sposta su',
                  onPressed: index == 0
                      ? null
                      : () => setState(() {
                          final current = _items.removeAt(index);
                          _items.insert(index - 1, current);
                        }),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: 'Sposta giu',
                  onPressed: index >= _items.length - 1
                      ? null
                      : () => setState(() {
                          final current = _items.removeAt(index);
                          _items.insert(index + 1, current);
                        }),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  tooltip: 'Rimuovi configurazione',
                  onPressed: () => setState(() => _items.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (var splitIndex = 0; splitIndex < item.splits.length; splitIndex++)
              _buildSplitRow(item: item, splitIndex: splitIndex),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() {
                final fallback = widget.tabelle.isNotEmpty
                    ? widget.tabelle.first
                    : null;
                item.splits.add(
                  DocumentsTabellaSplitDraft(
                    uid: _DocumentsDraftId.next(),
                    codiceTabella: fallback?.codice ?? '',
                    descrizioneTabella: fallback?.descrizione ?? '',
                    percentuale: 0,
                  ),
                );
              }),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi tabella'),
            ),
            const SizedBox(height: 4),
            Text(
              'Totale percentuale: ${item.totalPercent}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: item.totalPercent == 100 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitRow({
    required DocumentsConfigurazioneSpesaDraft item,
    required int splitIndex,
  }) {
    final split = item.splits[splitIndex];
    return Padding(
      key: ValueKey('split-${item.uid}-${split.uid}'),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              key: ValueKey('split-table-${item.uid}-${split.uid}'),
              initialValue: split.codiceTabella.isEmpty
                  ? null
                  : split.codiceTabella,
              decoration: const InputDecoration(labelText: 'Tabella'),
              items: widget.tabelle
                  .map(
                    (tabella) => DropdownMenuItem<String>(
                      value: tabella.codice,
                      child: Text(
                        '${tabella.codice} - ${tabella.descrizione}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = widget.tabelle.firstWhere(
                  (tabella) => tabella.codice == value,
                );
                setState(() {
                  split.codiceTabella = selected.codice;
                  split.descrizioneTabella = selected.descrizione;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              key: ValueKey('split-pct-${item.uid}-${split.uid}'),
              initialValue: '${split.percentuale}',
              decoration: const InputDecoration(labelText: '%'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? 0;
                setState(() => split.percentuale = parsed);
              },
            ),
          ),
          IconButton(
            tooltip: 'Rimuovi tabella',
            onPressed: () => setState(() => item.splits.removeAt(splitIndex)),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  void _addConfigurazione() {
    final fallback = widget.tabelle.isNotEmpty ? widget.tabelle.first : null;
    setState(() {
      _items.add(
        DocumentsConfigurazioneSpesaDraft(
          uid: _DocumentsDraftId.next(),
          codice: '',
          splits: [
            DocumentsTabellaSplitDraft(
              uid: _DocumentsDraftId.next(),
              codiceTabella: fallback?.codice ?? '',
              descrizioneTabella: fallback?.descrizione ?? '',
              percentuale: 100,
            ),
          ],
        ),
      );
    });
  }

  void _onSave() {
    final seenCodes = <String>{};
    for (final item in _items) {
      if (item.codice.trim().isEmpty) {
        _showError('Ogni configurazione deve avere un codice spesa');
        return;
      }
      final normalizedCode = item.codice.trim().toLowerCase();
      if (seenCodes.contains(normalizedCode)) {
        _showError('Codici spesa duplicati non consentiti');
        return;
      }
      seenCodes.add(normalizedCode);
      if (item.splits.isEmpty) {
        _showError('Ogni configurazione deve avere almeno una tabella');
        return;
      }
      final seenTables = <String>{};
      for (final split in item.splits) {
        final tableCode = split.codiceTabella.trim().toLowerCase();
        if (tableCode.isEmpty) {
          _showError('Seleziona la tabella per tutte le righe');
          return;
        }
        if (seenTables.contains(tableCode)) {
          _showError('Tabella duplicata nella configurazione "${item.codice}"');
          return;
        }
        seenTables.add(tableCode);
      }
      if (item.totalPercent != 100) {
        _showError(
          'Il totale percentuali per "${item.codice}" deve essere 100%',
        );
        return;
      }
    }
    Navigator.of(context).pop(
      DocumentsConfigurazioniSaveResult(
        items: _items,
        rebuildStorico: _rebuildStorico,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Stato editabile di una configurazione spesa usato dal dialog.
class DocumentsConfigurazioneSpesaDraft {
  DocumentsConfigurazioneSpesaDraft({
    required this.uid,
    required this.codice,
    required this.splits,
  });

  final int uid;
  String codice;
  List<DocumentsTabellaSplitDraft> splits;

  int get totalPercent =>
      splits.fold<int>(0, (sum, split) => sum + split.percentuale);

  factory DocumentsConfigurazioneSpesaDraft.fromModel(
    ConfigurazioneSpesaModel model,
  ) {
    return DocumentsConfigurazioneSpesaDraft(
      uid: _DocumentsDraftId.next(),
      codice: model.codice,
      splits: model.tabelle
          .map(
            (tabella) => DocumentsTabellaSplitDraft(
              uid: _DocumentsDraftId.next(),
              codiceTabella: tabella.codice,
              descrizioneTabella: tabella.descrizione,
              percentuale: tabella.percentuale,
            ),
          )
          .toList(growable: true),
    );
  }

  DocumentsConfigurazioneSpesaDraft copy() {
    return DocumentsConfigurazioneSpesaDraft(
      uid: _DocumentsDraftId.next(),
      codice: codice,
      splits: splits.map((split) => split.copy()).toList(growable: true),
    );
  }
}

class DocumentsConfigurazioniSaveResult {
  const DocumentsConfigurazioniSaveResult({
    required this.items,
    required this.rebuildStorico,
  });

  final List<DocumentsConfigurazioneSpesaDraft> items;
  final bool rebuildStorico;
}

/// Dialog condiviso per modificare le quote tabellari di un singolo condomino.
class DocumentsCondominoQuoteDialog extends StatefulWidget {
  const DocumentsCondominoQuoteDialog({
    super.key,
    required this.condomino,
    required this.allCondomini,
    required this.tabelle,
  });

  final CondominoDocumentModel condomino;
  final List<CondominoDocumentModel> allCondomini;
  final List<TabellaModel> tabelle;

  @override
  State<DocumentsCondominoQuoteDialog> createState() =>
      _DocumentsCondominoQuoteDialogState();
}

class _DocumentsCondominoQuoteDialogState
    extends State<DocumentsCondominoQuoteDialog> {
  late List<DocumentsCondominoQuotaDraft> _rows;
  late List<_DocumentsTabellaQuoteHealth> _health;
  bool _rebuildStorico = false;

  @override
  void initState() {
    super.initState();
    _rows = _buildInitialRows();
    _health = _computeHealth();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Quote - ${widget.condomino.nominativo}'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: ListView(
          children: [
            for (var i = 0; i < _rows.length; i++) _buildRow(i),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi tabella'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Verifica coerenza quote tabella',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ..._health.map(_buildHealthRow),
            const SizedBox(height: 6),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rebuildStorico,
              onChanged: (value) {
                setState(() => _rebuildStorico = value ?? false);
              },
              title: const Text('Ricostruisci storico'),
              subtitle: const Text(
                'Applica le nuove quote anche alle spese gia registrate '
                'dell\'anno corrente.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  List<DocumentsCondominoQuotaDraft> _buildInitialRows() {
    final byCode = <String, TabellaConfigModel>{};
    for (final tabella in widget.condomino.config.tabelle) {
      byCode[tabella.codiceTabella.trim().toLowerCase()] = tabella;
    }
    final rows = <DocumentsCondominoQuotaDraft>[];
    for (final tabella in widget.tabelle) {
      final existing = byCode[tabella.codice.trim().toLowerCase()];
      rows.add(
        DocumentsCondominoQuotaDraft(
          codiceTabella: tabella.codice,
          descrizioneTabella: tabella.descrizione,
          numeratore: existing?.numeratore ?? 0,
          denominatore: existing?.denominatore ?? 1000,
        ),
      );
    }
    if (rows.isEmpty) {
      rows.add(
        DocumentsCondominoQuotaDraft(
          codiceTabella: '',
          descrizioneTabella: '',
          numeratore: 0,
          denominatore: 1000,
        ),
      );
    }
    return rows;
  }

  Widget _buildRow(int index) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              initialValue: row.codiceTabella.isEmpty ? null : row.codiceTabella,
              decoration: const InputDecoration(labelText: 'Tabella'),
              items: widget.tabelle
                  .map(
                    (tabella) => DropdownMenuItem<String>(
                      value: tabella.codice,
                      child: Text('${tabella.codice} - ${tabella.descrizione}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                final selected = widget.tabelle.firstWhere(
                  (tabella) => tabella.codice == value,
                );
                setState(() {
                  row.codiceTabella = selected.codice;
                  row.descrizioneTabella = selected.descrizione;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: row.numeratore.toStringAsFixed(2),
              decoration: const InputDecoration(labelText: 'Numeratore'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  row.numeratore =
                      double.tryParse(value.replaceAll(',', '.')) ?? 0;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: row.denominatore.toStringAsFixed(2),
              decoration: const InputDecoration(labelText: 'Denominatore'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  row.denominatore =
                      double.tryParse(value.replaceAll(',', '.')) ?? 0;
                  _health = _computeHealth();
                });
              },
            ),
          ),
          IconButton(
            tooltip: 'Rimuovi',
            onPressed: () => setState(() {
              _rows.removeAt(index);
              _health = _computeHealth();
            }),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  void _addRow() {
    final fallback = widget.tabelle.isNotEmpty ? widget.tabelle.first : null;
    setState(() {
      _rows.add(
        DocumentsCondominoQuotaDraft(
          codiceTabella: fallback?.codice ?? '',
          descrizioneTabella: fallback?.descrizione ?? '',
          numeratore: 0,
          denominatore: 1000,
        ),
      );
      _health = _computeHealth();
    });
  }

  Future<void> _onSave() async {
    final seen = <String>{};
    for (final row in _rows) {
      final code = row.codiceTabella.trim().toLowerCase();
      if (code.isEmpty) {
        _showError('Seleziona la tabella per tutte le righe');
        return;
      }
      if (seen.contains(code)) {
        _showError('Tabella duplicata nelle quote condomino');
        return;
      }
      seen.add(code);
      if (row.denominatore <= 0) {
        _showError('Il denominatore deve essere > 0');
        return;
      }
      if (row.numeratore < 0) {
        _showError('Il numeratore non puo\' essere negativo');
        return;
      }
    }
    final issues = _computeHealth()
        .where((health) => !health.coherent)
        .toList(growable: false);
    if (issues.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quote tabella non coerenti'),
          content: const Text(
            'Alcune tabelle non sono ancora allineate (somma numeratori / denominatore).\n'
            'Potrai comunque salvare ora e completare le quote sugli altri condomini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Torna a modificare'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salva comunque'),
            ),
          ],
        ),
      );
      if (proceed != true) {
        return;
      }
    }
    if (!mounted) return;
    Navigator.of(context).pop(
      DocumentsQuoteSaveResult(
        rows: _rows,
        rebuildStorico: _rebuildStorico,
      ),
    );
  }

  Widget _buildHealthRow(_DocumentsTabellaQuoteHealth health) {
    final color = health.coherent ? Colors.green : Colors.orange;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        health.coherent
            ? Icons.check_circle_outline
            : Icons.warning_amber_outlined,
        color: color,
      ),
      title: Text(health.codice),
      subtitle: Text(health.message),
      trailing: Text(
        health.coherent ? 'OK' : 'Da verificare',
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }

  List<_DocumentsTabellaQuoteHealth> _computeHealth() {
    final byCodeCurrent = <String, DocumentsCondominoQuotaDraft>{};
    for (final row in _rows) {
      final code = row.codiceTabella.trim().toLowerCase();
      if (code.isEmpty) continue;
      byCodeCurrent[code] = row;
    }

    final result = <_DocumentsTabellaQuoteHealth>[];
    for (final tabella in widget.tabelle) {
      final code = tabella.codice.trim().toLowerCase();
      if (code.isEmpty) continue;

      double? denRef;
      double sumNum = 0;
      bool denomMismatch = false;
      final missing = <String>[];

      for (final condomino in widget.allCondomini) {
        double num = 0;
        double den = 0;
        bool found = false;

        if (condomino.id == widget.condomino.id) {
          final row = byCodeCurrent[code];
          if (row != null) {
            num = row.numeratore;
            den = row.denominatore;
            found = true;
          }
        } else {
          for (final cfg in condomino.config.tabelle) {
            if (cfg.codiceTabella.trim().toLowerCase() == code) {
              num = cfg.numeratore;
              den = cfg.denominatore;
              found = true;
              break;
            }
          }
        }

        if (!found || num <= 0 || den <= 0) {
          missing.add(condomino.nominativo);
          continue;
        }

        if (denRef == null) {
          denRef = den;
        } else if ((denRef - den).abs() > 0.0001) {
          denomMismatch = true;
        }
        sumNum += num;
      }

      final coherent = missing.isEmpty &&
          !denomMismatch &&
          denRef != null &&
          (sumNum - denRef).abs() <= 0.0001;

      String message;
      if (missing.isNotEmpty) {
        message = 'Mancano quote per: ${missing.join(', ')}';
      } else if (denomMismatch) {
        message = 'Denominatore non coerente tra condomini';
      } else if (denRef == null) {
        message = 'Nessuna quota valida';
      } else {
        message = 'Somma numeratori ${sumNum.toStringAsFixed(2)} / '
            'denominatore ${denRef.toStringAsFixed(2)}';
      }

      result.add(
        _DocumentsTabellaQuoteHealth(
          codice: tabella.codice,
          coherent: coherent,
          message: message,
        ),
      );
    }
    return result;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class DocumentsCondominoQuotaDraft {
  DocumentsCondominoQuotaDraft({
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.numeratore,
    required this.denominatore,
  });

  String codiceTabella;
  String descrizioneTabella;
  double numeratore;
  double denominatore;
}

class DocumentsQuoteSaveResult {
  const DocumentsQuoteSaveResult({
    required this.rows,
    required this.rebuildStorico,
  });

  final List<DocumentsCondominoQuotaDraft> rows;
  final bool rebuildStorico;
}

class DocumentsTabellaSplitDraft {
  DocumentsTabellaSplitDraft({
    required this.uid,
    required this.codiceTabella,
    required this.descrizioneTabella,
    required this.percentuale,
  });

  final int uid;
  String codiceTabella;
  String descrizioneTabella;
  int percentuale;

  DocumentsTabellaSplitDraft copy() {
    return DocumentsTabellaSplitDraft(
      uid: _DocumentsDraftId.next(),
      codiceTabella: codiceTabella,
      descrizioneTabella: descrizioneTabella,
      percentuale: percentuale,
    );
  }
}

class _DocumentsDraftId {
  static int _counter = 0;

  static int next() => ++_counter;
}

class _DocumentsTabellaQuoteHealth {
  const _DocumentsTabellaQuoteHealth({
    required this.codice,
    required this.coherent,
    required this.message,
  });

  final String codice;
  final bool coherent;
  final String message;
}
