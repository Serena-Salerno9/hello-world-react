### Combined image: builds the frontend then runs both nginx (serving static files)
### and the Python backend (uvicorn) in a single container.

FROM node:18-alpine AS frontend-build
WORKDIR /app
ARG VITE_API_URL=""
ENV VITE_API_URL=${VITE_API_URL}
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci --silent || npm install --silent
COPY frontend ./
RUN npm run build

FROM python:3.11-slim
WORKDIR /app

# Install python deps and nginx
COPY server/requirements.txt ./requirements.txt
RUN apt-get update \
    && apt-get install -y nginx \
    && python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && rm -rf /var/lib/apt/lists/*

# Copy application and frontend built files
COPY server ./server
COPY --from=frontend-build /app/dist /usr/share/nginx/html

# Nginx config template and start script
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf.template
COPY docker/start.sh /start.sh
RUN chmod +x /start.sh

ENV PORT=8080
EXPOSE 80
ENV PYTHONUNBUFFERED=1

CMD ["/start.sh"]
