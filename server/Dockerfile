FROM python:3.11-slim

WORKDIR /app

# Install build deps and runtime deps
COPY requirements.txt ./requirements.txt
RUN python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Cloud Run expects the service to bind to the port specified in $PORT
ENV PORT=8080
EXPOSE 8080

ENV PYTHONUNBUFFERED=1

# Use shell form so $PORT is expanded at runtime
# When building from the `server/` directory the module is `app:app` (not `server.app`).
CMD sh -c "python -m uvicorn app:app --host 0.0.0.0 --port $PORT"
