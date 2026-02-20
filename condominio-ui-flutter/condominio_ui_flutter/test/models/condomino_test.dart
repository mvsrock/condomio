import 'package:condominio_ui_flutter/models/condomino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Condomino espone nominativo e unita in formato atteso', () {
    const condomino = Condomino(
      id: 'C001',
      nome: 'Luca',
      cognome: 'Bianchi',
      scala: 'A',
      interno: '1',
      email: 'luca@example.com',
      telefono: '+39 333 000 0000',
      millesimi: 75.5,
      residente: true,
    );

    expect(condomino.nominativo, 'Luca Bianchi');
    expect(condomino.unita, 'Scala A - Int. 1');
  });
}
