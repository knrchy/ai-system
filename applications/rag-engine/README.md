# RAG Engine Service


Natural language querying service for trading data using Retrieval Augmented Generation.


## Features


- Generate embeddings from trade data
- Semantic search using ChromaDB
- Natural language queries with Ollama LLM
- Context-aware answers


## Local Development


### Setup


```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate


# Install dependencies
pip install -r requirements.txt


# Copy environment file
cp .env.example .env
Run Locally
-----------------------------------0-----------------------------------------
uvicorn src.main:app --reload --host 0.0.0.0 --port 8001
API Endpoints
Generate Embeddings
-----------------------------------...-----------------------------------------
POST /api/v1/embeddings/generate
Query with Natural Language
-----------------------------------...-----------------------------------------
POST /api/v1/query
Check Embedding Status
-----------------------------------...-----------------------------------------
GET /api/v1/embeddings/{backtest_id}/status
Delete Embeddings
-----------------------------------...-----------------------------------------
DELETE /api/v1/embeddings/{backtest_id}
Usage Example
python
-----------------------------------...-----------------------------------------
import requests


# 1. Generate embeddings
response = requests.post('http://localhost:8001/api/v1/embeddings/generate', json={
    'backtest_id': 'your-backtest-id',
    'force_regenerate': False
})


# 2. Query with natural language
response = requests.post('http://localhost:8001/api/v1/query', json={
    'query': 'What days should I avoid trading?',
    'backtest_id': 'your-backtest-id',
    'top_k': 10
})


print(response.json()['answer'])
Architecture
-----------------------------------...-----------------------------------------
Query → Embedding → Vector Search → Context Retrieval → LLM → Answer
-----------------------------------...-----------------------------------------


---
