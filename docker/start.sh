#!/bin/sh
set -e

# Ports: PORT is the external port (Cloud Run sets this), BACKEND_PORT is where uvicorn listens internally
PORT=${PORT:-8080}
BACKEND_PORT=${BACKEND_PORT:-8081}

# Generate nginx config from template if present
if [ -f /etc/nginx/conf.d/default.conf.template ]; then
  sed -e "s/__PORT__/${PORT}/g" -e "s/__BACKEND_PORT__/${BACKEND_PORT}/g" /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
fi

# Start backend bound to localhost on BACKEND_PORT
python -m uvicorn server.app:app --host 127.0.0.1 --port $BACKEND_PORT &

# Start nginx in foreground
exec nginx -g 'daemon off;'