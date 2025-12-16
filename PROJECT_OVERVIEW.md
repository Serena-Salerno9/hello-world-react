# Project Overview — Hello World React + FastAPI

Questo file riassume lo stato attuale del progetto e come funziona.

## Struttura principale

- `src/` — frontend React (Vite). Entry: `main.jsx`, component principale: `App.jsx`.
- `server/` — backend FastAPI (`app.py`) e mock Node server (`mock-server.js`).
- `package.json` — script utili:
  - `npm run dev` (avvia Vite frontend)
  - `npm run backend` (avvia FastAPI: `python -m uvicorn server.app:app --reload --port 8000`)
  - `npm run mock-backend` (avvia `server/mock-server.js` su porta 8000)
- `Dockerfile` — immagine container per il backend (legge `PORT` con default 8080)
- `docker-compose.yml` — compose per avviare frontend e backend in sviluppo
- `cloudbuild.yaml` — esempio di pipeline Cloud Build per build+deploy su Cloud Run
- `README.md` — istruzioni e comandi principali

## Cosa fa ogni parte

- Frontend: UI minimale con un bottone che chiama `GET /hello` su `http://localhost:8000/hello`.
- Backend: FastAPI espone `GET /hello` che risponde `{ "message": "Hello World" }`.
- Mock server: alternativa Node semplice che risponde allo stesso endpoint (utile se non hai Python).

## Eseguire in locale

Frontend:

```bash
npm install
npm run dev
# apri http://localhost:5173
```

Backend (dev):

```bash
python -m venv .venv
. \.venv\Scripts\Activate.ps1   # PowerShell
pip install -r server/requirements.txt
npm run backend
# oppure: python -m uvicorn server.app:app --reload --port 8000
```

Mock backend (se non hai Python):

```bash
npm run mock-backend
```

## Docker

Build e run immagini separate (backend, frontend):

Backend (from `server/`):

```bash
# Build backend image from server context
docker build -f server/Dockerfile -t hello-backend ./server
# Run backend image and bind port
docker run --rm -p 8080:8080 -e PORT=8080 hello-backend
# endpoint: http://localhost:8080/hello
```

Frontend (from `frontend/`):

```bash
# Build frontend image
docker build -f frontend/Dockerfile -t hello-frontend ./frontend
# Run frontend image (serves built app on port 8080)
docker run --rm -p 8080:8080 hello-frontend
# frontend: http://localhost:8080
```

Combined image (root `Dockerfile`, builds frontend then packages nginx + backend):

```bash
# Build combined image from repo root
docker build -t hello-app .
# Run combined container (nginx serves frontend on port 80, proxies /api/ to backend)
docker run --rm -p 80:80 -e PORT=8080 hello-app
# frontend: http://localhost:80
# api proxied: http://localhost:80/api/hello
```

Docker Compose (dev):

```bash
docker compose up --build
```

## Deploy su Cloud Run

Opzioni (Cloud Build):

- Build and push specific image using `gcloud builds submit` (example: backend):

```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-backend ./server
```

- Build and push the frontend-only image:

```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-frontend ./frontend
```

- Build and push the combined image (builds frontend and packages backend + nginx):

```bash
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-app .
```

- Or run the provided `cloudbuild.yaml` which builds & pushes all images and (optionally) deploys both `hello-backend` and `hello-app`:

```bash
gcloud builds submit --config cloudbuild.yaml .
```

Esempio di deploy (deploya l'immagine su Cloud Run):

```bash
gcloud run deploy hello-backend --image gcr.io/PROJECT_ID/hello-backend --project PROJECT_ID --region REGION --platform managed --allow-unauthenticated

# oppure deploy dell'app combinata (nginx + backend)
gcloud run deploy hello-app --image gcr.io/PROJECT_ID/hello-app --project PROJECT_ID --region REGION --platform managed --allow-unauthenticated
```

Note:

- Il `cloudbuild.yaml` incluso esegue per default la build/push di backend, frontend e combined e poi esegue i deploy (se vuoi evitare il deploy automatico, rimuovi o commenta la sezione `gcloud run deploy` dal file prima di eseguire).
- Puoi creare 3 Cloud Build triggers (backend, frontend, combined) se preferisci buildare automaticamente solo uno dei tre su push a branch specifico.

Note importanti:

- Cloud Run imposta la variabile d'ambiente `PORT`; il `Dockerfile` usa `$PORT` (default 8080).
- Se `uvicorn` non è sul PATH, usa `python -m uvicorn` (già usato negli script e nel `Dockerfile`).
- CORS: `server/app.py` permette origini `http://localhost:5173` e `http://localhost:5174` per lo sviluppo.

## CI/CD

Incluso `cloudbuild.yaml` come esempio di pipeline. Posso aggiungere anche una GitHub Actions workflow per build+deploy automatico su push.

## Troubleshooting rapido

- Se `curl http://localhost:8000/hello` restituisce `connection refused`, assicurati che il backend sia in esecuzione.
- Se il container non risponde, verifica che sia in ascolto sull'interfaccia `0.0.0.0` e sulla porta impostata da `PORT`.

Se vuoi, posso:

- aggiungere il workflow GitHub Actions per deploy automatico;
- creare una `Dockerfile` separata per il frontend per il deploy come immagine statica;
- eseguire io il deploy su Cloud Run (fornisci `PROJECT_ID` e `REGION`).
