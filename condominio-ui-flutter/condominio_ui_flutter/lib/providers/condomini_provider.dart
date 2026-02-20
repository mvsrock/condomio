import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/condomino.dart';

/// Stato anagrafica in memoria applicativa.
///
/// Nota:
/// - persistente SOLO finche' l'app resta in memoria;
/// - su refresh/logout+redirect web i dati tornano allo stato iniziale.
class CondominiNotifier extends StateNotifier<List<Condomino>> {
  CondominiNotifier() : super(_initialCondomini);

  /// Aggiorna un solo condomino per id.
  ///
  /// Riverpod notifica i listener del provider e ricostruisce
  /// solo i widget che stanno osservando `condominiProvider`.
  void updateCondomino(Condomino updated) {
    state = [
      for (final condomino in state)
        if (condomino.id == updated.id) updated else condomino,
    ];
  }
}

final condominiProvider = StateNotifierProvider<CondominiNotifier, List<Condomino>>((
  ref,
) {
  return CondominiNotifier();
});

const List<Condomino> _initialCondomini = [
  Condomino(
    id: 'C001',
    nome: 'Luca',
    cognome: 'Bianchi',
    scala: 'A',
    interno: '1',
    email: 'luca.bianchi@example.com',
    telefono: '+39 333 100 0001',
    millesimi: 74.50,
    residente: true,
  ),
  Condomino(
    id: 'C002',
    nome: 'Giulia',
    cognome: 'Rossi',
    scala: 'A',
    interno: '2',
    email: 'giulia.rossi@example.com',
    telefono: '+39 333 100 0002',
    millesimi: 68.25,
    residente: true,
  ),
  Condomino(
    id: 'C003',
    nome: 'Marco',
    cognome: 'Verdi',
    scala: 'A',
    interno: '3',
    email: 'marco.verdi@example.com',
    telefono: '+39 333 100 0003',
    millesimi: 71.00,
    residente: false,
  ),
  Condomino(
    id: 'C004',
    nome: 'Elena',
    cognome: 'Neri',
    scala: 'B',
    interno: '4',
    email: 'elena.neri@example.com',
    telefono: '+39 333 100 0004',
    millesimi: 82.10,
    residente: true,
  ),
  Condomino(
    id: 'C005',
    nome: 'Paolo',
    cognome: 'Gallo',
    scala: 'B',
    interno: '5',
    email: 'paolo.gallo@example.com',
    telefono: '+39 333 100 0005',
    millesimi: 77.90,
    residente: true,
  ),
  Condomino(
    id: 'C006',
    nome: 'Francesca',
    cognome: 'Romano',
    scala: 'B',
    interno: '6',
    email: 'francesca.romano@example.com',
    telefono: '+39 333 100 0006',
    millesimi: 73.35,
    residente: false,
  ),
  Condomino(
    id: 'C007',
    nome: 'Andrea',
    cognome: 'Greco',
    scala: 'C',
    interno: '7',
    email: 'andrea.greco@example.com',
    telefono: '+39 333 100 0007',
    millesimi: 69.20,
    residente: true,
  ),
  Condomino(
    id: 'C008',
    nome: 'Sara',
    cognome: 'Ferrari',
    scala: 'C',
    interno: '8',
    email: 'sara.ferrari@example.com',
    telefono: '+39 333 100 0008',
    millesimi: 76.45,
    residente: true,
  ),
  Condomino(
    id: 'C009',
    nome: 'Matteo',
    cognome: 'Esposito',
    scala: 'C',
    interno: '9',
    email: 'matteo.esposito@example.com',
    telefono: '+39 333 100 0009',
    millesimi: 80.70,
    residente: false,
  ),
  Condomino(
    id: 'C010',
    nome: 'Alessia',
    cognome: 'Marino',
    scala: 'D',
    interno: '10',
    email: 'alessia.marino@example.com',
    telefono: '+39 333 100 0010',
    millesimi: 78.40,
    residente: true,
  ),
  Condomino(
    id: 'C011',
    nome: 'Davide',
    cognome: 'Leone',
    scala: 'D',
    interno: '11',
    email: 'davide.leone@example.com',
    telefono: '+39 333 100 0011',
    millesimi: 66.85,
    residente: true,
  ),
  Condomino(
    id: 'C012',
    nome: 'Chiara',
    cognome: 'Costa',
    scala: 'D',
    interno: '12',
    email: 'chiara.costa@example.com',
    telefono: '+39 333 100 0012',
    millesimi: 81.30,
    residente: false,
  ),
];
