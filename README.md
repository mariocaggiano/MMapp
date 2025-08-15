# MMA Tracker – Monorepo MVP

Contiene:
- **backend/** NestJS + Postgres (pg)
- **client/** Flutter minimale (schermata test)

## Requisiti
- Node 20+, Docker, psql
- Flutter SDK 3.22+ (per client)

## Avvio Backend
```bash
cd backend
cp .env.example .env
docker compose -f ../docker-compose.yml up -d
npm ci
export DATABASE_URL=postgres://postgres:postgres@localhost:5432/mmatracker
npm run migrate:up
npm run start:dev
```

### Test rapido
```bash
curl -H 'Authorization: Bearer dev' -H 'X-User-Id: 00000000-0000-0000-0000-000000000001' http://localhost:3000/api/v1/health
```

## Avvio Client (demo)
> Genera le cartelle di piattaforma con `flutter create .` dentro `client/`.
```bash
cd client
flutter create .
flutter run -d chrome
# Oppure: flutter run su device/emulatore
```

**Nota**: il client punta a `http://localhost:3000` e usa header dev (NO_AUTH).


## Avvio su Gitpod (one-click)

1. Crea una **repo GitHub** e carica il contenuto di questa cartella (o carica direttamente lo zip).
2. Apri: `https://gitpod.io/#https://github.com/<TUO-USER>/<TUA-REPO>`
3. Attendi il provisioning (2–5 min la prima volta). Gitpod aprirà 3 terminal:
   - **Init DB & deps** (si chiude da solo a fine init)
   - **API** (backend su :3000, docs su /docs)
   - **Flutter Web** (app su :8081)
