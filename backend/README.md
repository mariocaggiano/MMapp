# MMA Tracker – Backend (NestJS)

Benvenuto nel backend. Questo repo include:
- App NestJS con Postgres via `pg`.
- Guard per autenticazione: Firebase in prod, `NO_AUTH=true` in dev.
- Migrazioni SQL (001_init.sql, 002_helpers.sql).
- Docker Compose per Postgres/Redis/Adminer.

## Avvio rapido (dev)
1. **Prerequisiti**: Node 20+, Docker, psql.
2. `docker compose up -d`
3. Copia `.env.example` in `.env` e lascia `NO_AUTH=true` per bypassare Firebase.
4. Crea DB + migrazioni:
   ```bash
   export DATABASE_URL=postgres://postgres:postgres@localhost:5432/mmatracker
   psql "$DATABASE_URL" -c 'select 1;'  # verifica
   npm run migrate:up
   ```
5. Avvia backend:
   ```bash
   npm run start:dev
   ```
6. Test rapido:
   ```bash
   curl -H 'Authorization: Bearer dev' -H 'X-User-Id: 00000000-0000-0000-0000-000000000001' http://localhost:3000/api/v1/health
   ```

## Note Auth
- **DEV**: `NO_AUTH=true` → il guard accetta qualunque Bearer e usa `X-User-Id` come utente. Se l'utente non esiste viene creato.
- **PROD**: impostare variabili Firebase ed eliminare `NO_AUTH` o metterlo a `false`.

## Struttura
```
backend/
  src/
    main.ts
    app.module.ts
    common/
      guards/firebase-auth.guard.ts
      decorators/user.decorator.ts
    db/
      db.module.ts
      db.service.ts
    users/
      users.module.ts
      users.controller.ts
      users.service.ts
    sessions/
      sessions.module.ts
      sessions.controller.ts
      sessions.service.ts
      dto/
    weights/
      weights.module.ts
      weights.controller.ts
      weights.service.ts
    pro/
      pro.module.ts
      pro.controller.ts
      pro.service.ts
    health/
      health.module.ts
      health.controller.ts
  migrations/
    001_init.sql
    002_helpers.sql
  docker-compose.yml
```

## OpenAPI
L'OpenAPI YAML è fornita a parte nel documento condiviso. In una fase successiva si può generare automaticamente dal codice con Swagger.
