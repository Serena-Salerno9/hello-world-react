Hello World React (Vite) + FastAPI
Progetto Full-Stack moderno con architettura a micro-servizi separati, containerizzato con Docker e pronto per il deploy su Google Cloud Run.

🏗️ Architettura del Progetto
Il progetto è diviso in due componenti indipendenti:

Frontend: React + Vite servito da Nginx (Porta 8080).

Backend: FastAPI (Python) servito da Uvicorn (Porta 8000).

💻 Sviluppo Locale (Senza Docker)
Backend (Python)
Entra nella cartella: cd server

Crea venv: python -m venv venv e attivalo.

Installa: pip install -r requirements.txt

Avvia: uvicorn app:app --reload --port 8000

Frontend (React)
Entra nella cartella: cd frontend

Installa: npm install

Avvia: npm run dev L'app sarà disponibile su http://localhost:5173.

🐳 Docker Compose (Test Locale)
Per avviare l'intera infrastruttura (Frontend + Backend) con un solo comando:

Bash

docker-compose up --build
Frontend: http://localhost:8080

Backend: http://localhost:8000

🚀 Deploy su Google Cloud Run
Il deploy è automatizzato tramite Cloud Build con una pipeline a catena: il build del backend scatena automaticamente quello del frontend per garantire la coerenza.

1. Pipeline Backend (cloudbuild-backend.yaml)
   Esegue il build dell'immagine Python, la pusha su Artifact Registry e aggiorna il servizio hello-backend. Alla fine, lancia il trigger fe-trigger.

2. Pipeline Frontend (cloudbuild-frontend.yaml)
   Esegue il build di React iniettando l'URL del backend tramite --build-arg VITE_API_URL. L'immagine finale usa Nginx per servire i file statici sulla porta 8080.

Variabili di Sostituzione (Substitutions)
Entrambi i file YAML usano variabili pulite per facilitare la manutenzione:

\_GCP_PROJECT_ID: ID del progetto Google Cloud.

\_REPOSITORY: Nome del repository Artifact Registry.

\_REGION: Regione (es. europe-west1).

\_BACKEND_URL: (Solo FE) L'URL pubblico del backend Cloud Run.

🛠️ Note Tecniche Importanti
CORS: Il backend in app.py è configurato per accettare richieste da localhost (sviluppo) e dal dominio reale del frontend (tramite la variabile ALLOWED_ORIGINS).

Iniezione URL: L'URL del backend deve essere fornito al frontend durante la fase di build di Docker, altrimenti React non saprà a chi inviare le richieste una volta online.

Pulizia: I file **pycache**, node_modules e dist sono esclusi tramite file .dockerignore dedicati in ogni sottocartella.
