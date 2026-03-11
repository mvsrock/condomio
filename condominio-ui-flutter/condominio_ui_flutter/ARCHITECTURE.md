# Architettura Flutter (Feature-First + Riverpod)

Questo progetto sta adottando una struttura **feature-first** per ridurre coupling, migliorare i rebuild mirati e separare chiaramente UI/logica/dati.

Riferimento cross-progetto:
- vedere anche `ENGINEERING_PATTERNS.md` in root repository per regole condivise FE/BE/Mongo/UX.

## Struttura target

```text
lib/
  main.dart
  app/ (opzionale, per temi/router/bootstrap condivisi)
  features/
    <feature_name>/
      presentation/   # UI (page/widgets)
      application/    # state management (notifier/provider)
      domain/         # modelli e regole di business
      data/           # repository/service/DTO/adapter esterni
```

## Regole dipendenze

Le dipendenze devono seguire questa direzione:

1. `presentation -> application`
2. `application -> domain`
3. `application -> data` (tramite repository/service)
4. `domain` non dipende da `presentation` o Flutter UI

## Routing

Il routing usa `go_router` con:

1. route auth top-level (`/login`, `/loading`, `/error`)
2. shell autenticata con branch indicizzati:
   `/home/dashboard`, `/home/map`, `/home/registry`, `/home/session`, `/home/documents`

La shell home usa `StatefulNavigationShell`:
- rail/bottom navigation comandano `goBranch(...)`
- il contenuto centrale e' il child route corrente
- l'URL rappresenta sempre la sezione attiva (deep link/back-forward coerenti)

## Layer responsibilities

### `presentation/`
- Contiene solo rendering e gestione eventi UI.
- Non contiene logica business complessa.
- Evitare computazioni pesanti in `build`; usare provider derivati.

### `application/`
- Contiene `StateNotifier`/`Provider` e stato della feature.
- Coordina use case e data source.
- Espone stato gia' pronto per la UI (lista filtrata, selezioni, flags loading).

### `domain/`
- Contiene entita' e regole di dominio.
- Nessuna dipendenza da widget/framework UI.

### `data/`
- Accesso a API/SDK/storage.
- Mapping tra formato esterno e modelli usati in app.

## Stato migrazione (attuale)

Feature migrate in struttura `features/*`:

- `auth`
- `registry`
- `documents`
- `map`

La migrazione e' completata senza compat shim: i riferimenti applicativi e test
puntano direttamente ai path in `lib/features/*`.

## Linee guida Riverpod per rebuild minimali

1. Usare `select(...)` quando serve un singolo campo.
2. Preferire provider derivati per filtro/sort/paginazione.
3. Evitare `ref.watch` multipli di blocchi non correlati nello stesso widget root.
4. Spezzare pagine grandi in sotto-widget `Consumer` indipendenti.
5. Tenere stato effimero locale nel widget (es. hover/espansione riga), non nel provider globale.
