# 🚀 Hello World React (Vite) + FastAPI

Progetto Full-Stack moderno con architettura a micro-servizi separati, completamente containerizzato con Docker e ottimizzato per il deploy su Google Cloud Run.

## 🏗️ Architettura del Progetto

Il progetto è diviso in due componenti indipendenti e disaccoppiate:

Frontend: React + Vite, impacchettato con Nginx (Porta 8080).

Backend: FastAPI (Python), servito da Uvicorn (Porta 8000).

## 💻 Sviluppo Locale (Senza Docker)

### Backend (Python)

Entra nella cartella: cd server

Crea venv: python -m venv venv

Attiva venv:

Windows: .\venv\Scripts\activate

Mac/Linux: source venv/bin/activate

Installa dipendenze: pip install -r requirements.txt

Avvia: uvicorn app:app --reload --port 8000

### Frontend (React)

Entra nella cartella: cd frontend

Installa dipendenze: npm install

Avvia: npm run dev

L'app sarà disponibile su: http://localhost:5173

## 🐳 Docker Compose (Test Locale)

Per avviare l'intera infrastruttura con un solo comando:

Bash

docker-compose up --build
Frontend: http://localhost:8080

Backend: http://localhost:8000

## 🚀 Deploy su Google Cloud Run

Il deploy è automatizzato tramite Cloud Build con una pipeline a catena:

Pipeline Backend (cloudbuild-backend.yaml): Esegue il build dell'immagine Python, la pusha su Artifact Registry e aggiorna il servizio hello-backend. Al termine, invoca automaticamente il trigger fe-trigger.

Pipeline Frontend (cloudbuild-frontend.yaml): Esegue il build di React iniettando l'URL del backend tramite --build-arg VITE_API_URL. L'immagine finale usa Nginx per servire i file statici.

### Variabili di Sostituzione (Substitutions)

I file YAML utilizzano le seguenti variabili per la massima flessibilità:

\_GCP_PROJECT_ID: ID del progetto Google Cloud.

\_REPOSITORY: Nome del repository Artifact Registry.

\_REGION: Regione (es. europe-west1).

\_BACKEND_URL: (Solo FE) L'URL pubblico del backend Cloud Run.

## 🛠️ Note Tecniche Importanti

CORS: Il backend in app.py accetta richieste da localhost e dal dominio reale del frontend tramite la variabile ALLOWED_ORIGINS.

Iniezione URL: L'URL del backend viene iniettato nel frontend al build-time. Senza questa variabile, le chiamate API falliranno in produzione.

Pulizia: Cartelle come **pycache**, node_modules e dist sono ignorate tramite file .dockerignore per garantire immagini leggere e sicure.
