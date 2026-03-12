# Operations Service

Microservizio dedicato alle operazioni asincrone di `Condomio`.

## Ruolo nel sistema

- espone API `/jobs` (queue/stato/download);
- salva stato job su Mongo (`async_job`);
- esegue i job in background;
- delega la business logic a `core` tramite bridge interno signed.

## Flusso end-to-end

1. Flutter chiama `core` su `/jobs/...`.
2. `core` fa proxy verso `operations-service` via OpenFeign + discovery.
3. `operations-service` esegue il job e, quando serve dominio contabile, chiama:
   - `POST /internal/operations/report-export`
   - `POST /internal/operations/morosita/solleciti-automatici`
   - `POST /internal/operations/morosita/reminder-scadenze`
4. Il bridge interno e' protetto da header `X-Ops-Key`.

## Configurazioni chiave

- `app.core.internal.shared-key` su `operations-service`
- `app.internal.operations.shared-key` su `core`

I due valori devono coincidere.
