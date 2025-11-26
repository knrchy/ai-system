# API Gateway

Unified API gateway for all Trading AI System services.

## Features

- Single entry point for all services
- JWT authentication
- Rate limiting
- Request routing
- CORS handling
- Service health monitoring

## Endpoints

All services accessible through `/api/v1`:

### Data Pipeline
- `POST /api/v1/data/ingest`
- `GET /api/v1/data/backtests`
- `GET /api/v1/data/backtests/{id}`

### RAG Engine
- `POST /api/v1/rag/query`
- `POST /api/v1/rag/embeddings/generate`
- `GET /api/v1/rag/embeddings/{id}/status`

### Optimizer
- `POST /api/v1/optimize/start`
- `GET /api/v1/optimize/status/{id}`
- `GET /api/v1/optimize/results/{id}`
- `POST /api/v1/optimize/genetic`

## Local Development

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
uvicorn src.main:app --reload --host 0.0.0.0 --port 8080
Docker
-----------------------------------0-----------------------------------------
docker build -t trading-ai/api-gateway:latest .
docker run -p 8080:8080 trading-ai/api-gateway:latest
-----------------------------------...-----------------------------------------

--
