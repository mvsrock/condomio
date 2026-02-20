import 'package:condominio_ui_flutter/models/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Helper enum AuthState funzionano correttamente', () {
    expect(AuthState.authenticated.isAuthenticated, isTrue);
    expect(AuthState.loading.isLoading, isTrue);
    expect(AuthState.error.isError, isTrue);

    expect(AuthState.unauthenticated.isAuthenticated, isFalse);
    expect(AuthState.unauthenticated.isLoading, isFalse);
    expect(AuthState.unauthenticated.isError, isFalse);
  });
}
