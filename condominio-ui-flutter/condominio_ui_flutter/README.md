# condominio_ui_flutter

A new Flutter project.

## Profili runtime Keycloak (web + mobile + desktop)

L'app supporta profili tramite `--dart-define`, quindi non serve piu' modificare i file a mano.

### Profili disponibili

- `APP_PROFILE=web`
  - `KEYCLOAK_SERVER_URL` default: `http://localhost:8082`
  - redirect default: `http://localhost:8089/callback`
- `APP_PROFILE=android-emulator`
  - `KEYCLOAK_SERVER_URL` default: `http://10.0.2.2:8082`
  - redirect mobile (wrapper): `it.mvs.condominiouiflutter://login-callback`
- `APP_PROFILE=android-device`
  - richiede `KEYCLOAK_SERVER_URL=http://<IP_DEL_PC>:8082`
  - redirect mobile (wrapper): `it.mvs.condominiouiflutter://login-callback`
- `APP_PROFILE=desktop`
  - `KEYCLOAK_SERVER_URL` default: `http://localhost:8082`
  - redirect default: `http://127.0.0.1:47899/callback`

Se non passi `APP_PROFILE`, il default e':
- web browser -> `web`
- Android -> `android-emulator`
- iOS -> `ios`
- Windows/Linux/macOS -> `desktop`

### Comandi pronti

Web:

```bash
flutter run -d chrome --dart-define=APP_PROFILE=web
```

Android Emulator:

```bash
flutter run -d emulator-5554 --dart-define=APP_PROFILE=android-emulator
```

Android Device fisico:

```bash
flutter run -d <DEVICE_ID> \
  --dart-define=APP_PROFILE=android-device \
  --dart-define=KEYCLOAK_SERVER_URL=http://192.168.1.20:8082
```

Desktop (Windows/Linux/macOS):

```bash
flutter run -d windows --dart-define=APP_PROFILE=desktop
```

```bash
flutter run -d linux --dart-define=APP_PROFILE=desktop
```

```bash
flutter run -d macos --dart-define=APP_PROFILE=desktop
```

### Cosa configurare in Keycloak

- Client `condominio` con flow Authorization Code + PKCE.
- Redirect URI web: `http://localhost:8089/callback`
- Redirect URI mobile: `it.mvs.condominiouiflutter://login-callback`
- Redirect URI desktop: `http://127.0.0.1:47899/callback`
- Logout redirect web (opzionale): `http://localhost:8089/`
- Post logout redirect mobile: `it.mvs.condominiouiflutter://login-callback`

Nota: se usi device fisico Android, telefono e PC devono stare sulla stessa rete LAN.

## Note debug

- Se modifichi file nativi Android (`AndroidManifest.xml`, Gradle), fai restart completo (`flutter run`), non hot reload.
- In debug USB, se chiudi l'app dal telefono il processo termina: devi rilanciare `flutter run`.
