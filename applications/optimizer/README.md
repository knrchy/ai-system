# Optimizer Service


Distributed parameter optimization service using Celery task queue.


## Features


- Grid search optimization
- Random search optimization
- Genetic algorithm optimization (basic)
- Distributed task execution
- Real-time progress tracking
- Result ranking and storage


## Architecture


API → Celery Tasks → Workers (distributed) → Results


-----------------------------------...-----------------------------------------


## Local Development


### Setup


```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate


# Install dependencies
pip install -r requirements.txt
Run API Server
-----------------------------------0-----------------------------------------
uvicorn src.main:app --reload --host 0.0.0.0 --port 8002
Run Celery Worker
-----------------------------------0-----------------------------------------
celery -A src.celery_app worker --loglevel=info --concurrency=4
Run Flower (Monitoring)
-----------------------------------0-----------------------------------------
celery -A src.celery_app flower --port=5555
Docker
Build
-----------------------------------0-----------------------------------------
docker build -t trading-ai/optimizer:latest .
Run API
-----------------------------------0-----------------------------------------
docker run -p 8002:8002 trading-ai/optimizer:latest
Run Worker
-----------------------------------0-----------------------------------------
docker run trading-ai/optimizer:latest \
  celery -A src.celery_app worker --loglevel=info
API Endpoints
Start Optimization
-----------------------------------...-----------------------------------------
POST /api/v1/optimize
Get Status
-----------------------------------...-----------------------------------------
GET /api/v1/optimize/{optimization_id}/status
Get Results
-----------------------------------...-----------------------------------------
GET /api/v1/optimize/{optimization_id}/results
Worker Status
-----------------------------------...-----------------------------------------
GET /api/v1/workers/status
Usage Example
python
-----------------------------------...-----------------------------------------
import requests


# Start optimization
response = requests.post('http://localhost:8002/api/v1/optimize', json={
    'backtest_id': 'your-backtest-id',
    'parameters': [
        {'name': 'stop_loss', 'min_value': 20, 'max_value': 80, 'step': 2}
    ],
    'optimization_type': 'grid_search'
})


optimization_id = response.json()['optimization_id']


# Check status
status = requests.get(f'http://localhost:8002/api/v1/optimize/{optimization_id}/status')
print(status.json())


# Get results
results = requests.get(f'http://localhost:8002/api/v1/optimize/{optimization_id}/results')
print(results.json())
-----------------------------------...-----------------------------------------


---
