# Hello World React (Vite + FastAPI)

Semplice progetto React con un backend Python FastAPI che espone `/hello`.

**Stato attuale (punto di partenza per i build):**

- `server/Dockerfile`: Dockerfile per il backend (context `server/`).
- `frontend/Dockerfile`: Dockerfile per il frontend (context `frontend/`) e accetta `ARG VITE_API_URL` per incorporare l'URL del backend al build-time.
- `Dockerfile` (root): immagine combinata multi-stage che builda il frontend e impacchetta nginx + backend (usa template nginx + `start.sh`).
- `cloudbuild.yaml`: pipeline aggiornata per build/push di backend, frontend e combined, e supporta la substitution `_VITE_API_URL`.
- `server/app.py`: legge `ALLOWED_ORIGINS` (env, comma-separated) per configurare CORS; fallback alle origini dev `http://localhost:5173` e `http://localhost:5174`.

Frontend (React / Vite):

```bash
# 1) Installare dipendenze frontend
npm install

# 2) Avviare il server di sviluppo frontend
npm run dev
```

Aprire il browser su `http://localhost:5173`.

Backend (Python / FastAPI):

```bash
# 1) Creare un virtualenv e attivarlo (Windows PowerShell):
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 2) Installare dipendenze
pip install -r server/requirements.txt

# 3) Avviare il backend
uvicorn server.app:app --reload --port 8000
```

Il frontend chiama il backend su `http://localhost:8000/hello` quando premi il pulsante "Get Message From Backend".

Troubleshooting:

- If Vite chooses a different port (e.g. `5174`), open the shown URL (e.g. `http://localhost:5174`). The backend CORS is configured to allow `http://localhost:5173` and `http://localhost:5174` during development.
- Windows: if `python` is not found, install Python from https://python.org and ensure the "Add Python to PATH" option is enabled during installation.
- You can start the backend using the npm helper script: `npm run backend` (this still requires Python and the server dependencies to be installed in your environment).

Optional: if you don't have Python available, there's a lightweight Node mock backend you can use for development:

```bash
# Start the mock backend that serves /hello
npm run mock-backend
```

This serves the same JSON response as the FastAPI backend so you can continue developing the frontend without Python installed.

Docker (build + run)

Build backend-only image (from `server/`):

```bash
# Build the backend image from the server context
docker build -f server/Dockerfile -t hello-backend ./server

# Run the container and bind port 8080 to the host
docker run --rm -p 8080:8080 -e PORT=8080 hello-backend
```

Build frontend-only image (from `frontend/`):

```bash
# Build the frontend image
docker build -f frontend/Dockerfile -t hello-frontend ./frontend

# Run the frontend container (serves the built app on port 8080)
docker run --rm -p 8080:8080 hello-frontend
```

Build combined image (root `Dockerfile`, runs nginx + backend together):

```bash
# Build the combined image (builds frontend and packages backend + nginx)
docker build -t hello-app .

# Run the combined container (exposes nginx on port 80)
docker run --rm -p 80:80 -e PORT=8080 hello-app
```

The backend endpoint is available at `/api/hello` (proxied by nginx) and the frontend is served on `http://localhost:80`.

Cloud Run (build + deploy):

Esempio di workflow consigliato (seguendo il flusso: backend → frontend):

1. Redeploy backend _da zero_ (elimina il servizio esistente, build e deploy):

```bash
# Elimina il servizio Cloud Run esistente (opzionale: solo se vuoi un deploy "pulito")
gcloud run services delete hello-backend --region REGION --platform managed

# Build & push backend image (Artifact/GCR)
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-backend ./server

# Deploy backend (imposta ALLOWED_ORIGINS con il dominio del frontend se vuoi usare CORS più restrittivi)
gcloud run deploy hello-backend --image gcr.io/PROJECT_ID/hello-backend \
  --update-env-vars ALLOWED_ORIGINS="https://<your-frontend-url>" \
  --region REGION --platform managed --allow-unauthenticated

# Prendi l'URL fornito dal deploy (es. https://hello-backend-...run.app)
```

2. Build & deploy frontend (incorpora l'URL del backend al build-time usando `_VITE_API_URL`):

```bash
# Usando Cloud Build substitution (consigliato)
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-frontend \
  --substitutions=_VITE_API_URL="https://<backend-url>" ./frontend

# Deploy frontend su Cloud Run
gcloud run deploy hello-frontend --image gcr.io/PROJECT_ID/hello-frontend \
  --region REGION --platform managed --allow-unauthenticated
```

3. (Opzionale) Build & deploy combined image (nginx + backend) — utile per test end-to-end senza servizi separati:

```bash
# Build combined image (accetta VITE_API_URL come build-arg)
# il combined build incorpora il frontend ed impacchetta nginx + backend
docker build --build-arg VITE_API_URL="https://<backend-url>" -t hello-app .
# oppure con Cloud Build
gcloud builds submit --tag gcr.io/PROJECT_ID/hello-app --substitutions=_VITE_API_URL="https://<backend-url>" .
# Deploy combined app
gcloud run deploy hello-app --image gcr.io/PROJECT_ID/hello-app --region REGION --platform managed --allow-unauthenticated
```

Notes:

- Cloud Run imposta la variabile d'ambiente `PORT`; lo `start.sh` e la configurazione nginx gestiscono `PORT` (esterno) e `BACKEND_PORT` (interno) per il combined image.
- `VITE_API_URL` è una variabile che **deve** essere fornita al _build-time_ perché Vite la incorpori in `import.meta.env.VITE_API_URL`.
- Per CORS in produzione, usa `ALLOWED_ORIGINS` sul backend con il dominio reale del frontend; non usare `*` in produzione.
- Se preferisci, posso aggiungere comandi `gcloud` opzionali per creare trigger Cloud Build separati (backend/frontend/combined).

Docker Compose (frontend + backend):

```bash
# Build images and run both services
docker compose up --build

# Stop and remove containers
docker compose down
```

Notes:

- The Compose file mounts the project into the frontend container and runs `npm install` then `npm run dev -- --host 0.0.0.0`, so Vite is reachable at `http://localhost:5173`.
- If you prefer the frontend in a separate container image (not bind-mounted), create a `Dockerfile` for the frontend and update `docker-compose.yml` accordingly.

Continuous Deployment (Cloud Build):

A simple `cloudbuild.yaml` is included that builds and pushes the container image and deploys it to Cloud Run.

To run the Cloud Build pipeline manually (replace `PROJECT_ID` and `REGION`):

```bash
# Trigger a build using Cloud Build
gcloud builds submit --config cloudbuild.yaml --substitutions _REGION=us-central1 --project PROJECT_ID .
```

You can also create a Cloud Build trigger or set up a GitHub Action to call Cloud Build on push to `main` for automatic deploys.

If you want, I can also add a GitHub Actions workflow instead of/alongside Cloud Build to build and deploy on push. Would you like that?
