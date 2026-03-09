import 'package:condominio_ui_flutter/utils/api_error.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('ApiError mappa codice rata in messaggio business', () {
    final response = http.Response(
      '{"errorCodes":["validation.required.rata.codice"]}',
      400,
    );
    final error = ApiError.fromHttp(operation: 'addRata', response: response);
    expect(error.userMessage, 'Inserisci il codice rata.');
  });

  test('ApiError mappa codice unita immobiliare in messaggio business', () {
    final response = http.Response(
      '{"errorCodes":["validation.required.unitaImmobiliare.codice"]}',
      400,
    );
    final error = ApiError.fromHttp(
      operation: 'createUnitaImmobiliare',
      response: response,
    );
    expect(error.userMessage, 'Inserisci il codice dell\'unita immobiliare.');
  });

  test('ApiError mantiene fallback standard se codice non noto', () {
    final response = http.Response(
      '{"errorCodes":["validation.unknown.code"]}',
      400,
    );
    final error = ApiError.fromHttp(operation: 'unknown', response: response);
    expect(error.userMessage, 'validation.unknown.code');
  });
}

