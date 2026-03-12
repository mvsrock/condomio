# Running Configs (Flutter)

Questo file e' il riferimento unico per avvio locale su web, desktop e Android.

## Prerequisiti

- Keycloak: `http://localhost:8082` (oppure IP LAN se usi telefono fisico)
- Core API: `http://localhost:8090` (oppure IP LAN se usi telefono fisico)
- Operations API (job async): `http://localhost:8094`
- Flutter app path: `condominio-ui-flutter/condominio_ui_flutter`

## Backend locale (core + operations)

Avvia `core`:

```powershell
cd C:\Users\marco.simone\Desktop\smartmetering\regenesy\Condomio\core
$env:APP_INTERNAL_OPERATIONS_SHARED_KEY="change-me-ops-key"
.\mvnw.cmd spring-boot:run
```

Avvia `operations-service`:

```powershell
cd C:\Users\marco.simone\Desktop\smartmetering\regenesy\Condomio\operations
$env:APP_INTERNAL_OPERATIONS_SHARED_KEY="change-me-ops-key"
.\mvnw.cmd spring-boot:run
```

Nota:
- `core` espone ancora `/jobs` al Flutter, ma ora fa proxy verso `operations-service`.
- quindi per usare job/report async devono essere attivi entrambi.

## Dove andare

```powershell
cd C:\Users\marco.simone\Desktop\smartmetering\regenesy\Condomio\condominio-ui-flutter\condominio_ui_flutter
```

## Web (Chrome)

```powershell
flutter run -d chrome --web-port 8089 --dart-define=APP_PROFILE=web --dart-define=KEYCLOAK_SERVER_URL=http://localhost:8082 --dart-define=CORE_API_URL=http://localhost:8090
```

## Desktop (Windows)

```powershell
flutter run -d windows --dart-define=APP_PROFILE=desktop --dart-define=KEYCLOAK_SERVER_URL=http://localhost:8082 --dart-define=CORE_API_URL=http://localhost:8090
```

## Android Emulator

```powershell
flutter run -d emulator-5554 --dart-define=APP_PROFILE=android-emulator --dart-define=KEYCLOAK_SERVER_URL=http://10.0.2.2:8082 --dart-define=CORE_API_URL=http://10.0.2.2:8090
```

## Android Device (telefono reale)

Esempio completo con IP LAN del PC `192.168.178.57`:

```powershell
flutter run -d f6296aec --dart-define=APP_PROFILE=android-device --dart-define=KEYCLOAK_SERVER_URL=http://192.168.178.57:8082 --dart-define=CORE_API_URL=http://192.168.178.57:8090
```

Se cambia IP o device id:
- sostituisci `f6296aec` con il tuo id da `flutter devices`
- sostituisci `192.168.178.57` con il tuo IP LAN corrente

## DART Defines supportati

- `APP_PROFILE`: `web`, `desktop`, `android-emulator`, `android-device`, `ios`, `auto`
- `KEYCLOAK_SERVER_URL`
- `CORE_API_URL`
- `KEYCLOAK_REALM` (default: `condominio`)
- `KEYCLOAK_CLIENT_ID` (default: `condominio`)
- `APP_REDIRECT_URI` (override redirect login)
- `APP_LOGOUT_REDIRECT_URI` (override redirect logout)
- `APP_HOME_URI` (home web post logout)
- `APP_BUNDLE_ID` (default: `it.mvs.condominiouiflutter`)

## Redirect URI attesi in Keycloak (client `condominio`)

- Web login callback: `http://localhost:8089/callback`
- Web base app: `http://localhost:8089`
- Desktop callback: `http://127.0.0.1:47899/callback`
- Mobile login callback: `it.mvs.condominiouiflutter:/oauthredirect`
- Mobile logout callback: `it.mvs.condominiouiflutter:/logout`
