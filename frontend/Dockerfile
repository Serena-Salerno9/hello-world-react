# Stage Build
# ----------------------------------------------------------------------
FROM node:18-alpine as build

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json (if present) to leverage Docker cache
COPY package*.json ./

# Install dependencies (ci is cleaner, fallback to install)
RUN npm ci --silent || npm install --silent

# Copy all the remaining source files (including vite.config.mjs and src/)
COPY . ./

# Build the React application. 
# VITE_API_URL is passed via --build-arg during docker build 
ARG VITE_API_URL
ENV VITE_API_URL=${VITE_API_URL}

# Esegue la compilazione React (il nostro fix vite.config.mjs lo fa funzionare)
RUN npm run build


# Stage Production (Correzione Nginx per Cloud Run)
# ----------------------------------------------------------------------
FROM nginx:alpine as final

# Rimuove la configurazione Nginx di default (che ascolta sulla 80)
RUN rm /etc/nginx/conf.d/default.conf

# Copia la nostra configurazione personalizzata (che ascolta sulla 8080)
# Il file nginx.conf deve trovarsi nella stessa cartella del Dockerfile
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Cloud Run si aspetta che il container ascolti sulla variabile d'ambiente $PORT, 
# che in Cloud Run è 8080.
EXPOSE 8080 

# Copia i file compilati di React dallo stage precedente
COPY --from=build /app/dist /usr/share/nginx/html

# Avvia Nginx
CMD ["nginx", "-g", "daemon off;"]