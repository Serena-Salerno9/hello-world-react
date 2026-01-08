# 🚀 Hello World React (Vite) + FastAPI

Progetto **Full-Stack** moderno con architettura a micro-servizi separati, completamente containerizzato con **Docker** e ottimizzato per il deploy su **Google Cloud Run**.

---

## 🏗️ Architettura del Progetto

Il progetto è diviso in due componenti indipendenti e disaccoppiate che comunicano tramite API:

* **Frontend**: React + Vite, servito da Nginx (Porta 8080).
* **Backend**: FastAPI (Python), servito da Uvicorn (Porta 8000).

---

## 💻 Sviluppo Locale (Senza Docker)

### Backend (Python)

1. Entra nella cartella: `cd server`
2. Crea venv: `python -m venv venv`
3. Attiva venv:
    * Windows: `.\venv\Scripts\activate`
    * Mac/Linux: `source venv/bin/activate`
4. Installa dipendenze: `pip install -r requirements.txt`
5. Avvia: `uvicorn app:app --reload --port 8000`

### Frontend (React)

1. Entra nella cartella: `cd frontend`
2. Installa dipendenze: `npm install`
3. Avvia: `npm run dev`
    * L'app sarà disponibile su: http://localhost:5173

---

## 🐳 Docker Compose (Test Locale)

Per avviare l'intera infrastruttura (Frontend + Backend) con un solo comando:

    docker-compose up --build

**Link locali dopo l'avvio:**
* **Frontend**: http://localhost:8080
* **Backend**: http://localhost:8000

---

## 🚀 Deploy su Google Cloud Run

Il deploy è automatizzato tramite **Cloud Build** con una pipeline a catena coordinata:

1.  **Pipeline Backend (cloudbuild-backend.yaml)**:
    Esegue il build dell'immagine Python, la pusha su Artifact Registry e aggiorna il servizio hello-backend. Al termine, invoca automaticamente il trigger del frontend.

2.  **Pipeline Frontend (cloudbuild-frontend.yaml)**:
    Esegue il build di React iniettando l'URL del backend tramite la variabile VITE_API_URL. L'immagine finale utilizza Nginx sulla porta 8080.

### Variabili di Sostituzione (Substitutions)

I file YAML utilizzano variabili centralizzate per facilitare la manutenzione:

* **_GCP_PROJECT_ID**: ID del progetto Google Cloud.
* **_REPOSITORY**: Nome del repository Artifact Registry.
* **_REGION**: Regione del deploy (es. europe-west1).
* **_BACKEND_URL**: L'URL pubblico generato da Cloud Run per il servizio backend.

---

## 🛠️ Note Tecniche Importanti

* **CORS**: Il backend in `app.py` accetta richieste da localhost (dev) e dal dominio reale del frontend (tramite la variabile ALLOWED_ORIGINS).
* **Iniezione URL**: L'URL del backend viene iniettato nel frontend durante la fase di build. È un passaggio fondamentale perché React possa comunicare con l'API in cloud.
* **Pulizia**: File pesanti come `node_modules`, `dist` e `__pycache__` sono correttamente esclusi tramite file `.dockerignore`.
