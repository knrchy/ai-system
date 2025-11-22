# Phase 3: RAG System & Vector Database


> Complete guide for building the AI-powered query system


**Duration**: 4-5 days  
**Difficulty**: Advanced  
**Prerequisites**: Phase 1 & 2 completed


---


## 📋 Overview


Phase 3 adds natural language querying capabilities using RAG (Retrieval Augmented Generation).


**What You Built**:
- ✅ Embedding generation service
- ✅ ChromaDB vector storage
- ✅ RAG query pipeline
- ✅ Ollama LLM integration
- ✅ Natural language API


---


## 🚀 Step-by-Step Guide


### Step 1: Build RAG Engine


```bash
cd ~/trading-ai-system


chmod +x scripts/build-rag-engine.sh
./scripts/build-rag-engine.sh
Expected output:


-----------------------------------...-----------------------------------------
🔨 Building RAG Engine Docker Image
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Building Docker image...
This may take several minutes (downloading embedding model)


[+] Building 180.5s (14/14) FINISHED
✓ Docker image built successfully


Image: trading-ai/rag-engine:latest
Step 2: Deploy to Kubernetes
-----------------------------------0-----------------------------------------
chmod +x scripts/deploy-rag-engine.sh
./scripts/deploy-rag-engine.sh
Expected output:


-----------------------------------...-----------------------------------------
🚀 Deploying RAG Engine Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Step 1: Building Docker image
✓ Docker image built successfully


Step 2: Deploying to Kubernetes
deployment.apps/rag-engine created
service/rag-engine created


Step 3: Waiting for deployment...
deployment.apps/rag-engine condition met


✓ RAG Engine deployed successfully


Service Information:
  Internal: http://rag-engine.trading-system.svc.cluster.local:8001
  External: http://localhost:30801


✅ Deployment Complete!
Step 3: Verify Deployment
-----------------------------------0-----------------------------------------
# Check pods
kubectl get pods -n trading-system


# Test API
curl http://localhost:30801/health


# Run tests
chmod +x scripts/test-rag-engine.sh
./scripts/test-rag-engine.sh
Step 4: Generate Embeddings
For your first backtest:


-----------------------------------0-----------------------------------------
# Get your backtest ID
curl http://localhost:30800/api/v1/backtests | jq '.[] | {id, name}'


# Generate embeddings
chmod +x scripts/generate-embeddings.sh
./scripts/generate-embeddings.sh <your-backtest-id>
Expected output:


-----------------------------------...-----------------------------------------
🧠 Generate Embeddings for Backtest
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Backtest ID: 123e4567-e89b-12d3-a456-426614174000
Force Regenerate: false


Generating embeddings...
This may take several minutes depending on data size


Response:
{
  "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
  "chunks_created": 365,
  "status": "created",
  "message": "Successfully created 365 embeddings"
}


✅ Embeddings ready!


Total chunks: 365


You can now query this backtest
Step 5: Query with Natural Language
-----------------------------------0-----------------------------------------
chmod +x scripts/query-rag.sh


# Ask your first question
./scripts/query-rag.sh <backtest-id> "What days should I avoid trading?"
Expected output:


-----------------------------------...-----------------------------------------
🤖 Query Trading Data with AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Backtest ID: 123e4567-e89b-12d3-a456-426614174000
Query: What days should I avoid trading?


Processing query...
This may take 10-30 seconds

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
AI Answer:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Based on the trading data analysis, I recommend avoiding trading on:


1. **Mondays between 15:00-17:00 UTC**: The data shows a 68% drawdown rate 
   during this period, with significantly lower win rates compared to other 
   time slots.


2. **Fridays after 20:00 UTC**: Trading performance deteriorates substantially 
   in late Friday sessions, likely due to reduced liquidity as markets prepare 
   for the weekend close. Average losses during this period are 23% higher.


3. **First week of each month**: Analysis reveals a consistent pattern of 
   underperformance during the first 5 trading days of the month, with win 
   rates dropping by approximately 15 percentage points.


Additionally, positions held over the weekend show 23% worse performance on 
average, suggesting it's advisable to close positions before Friday's market 
close.


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Retrieved Contexts: 10
Model Used: llama3.1:8b
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💻 Usage Examples
Example 1: Basic Query
-----------------------------------0-----------------------------------------
./scripts/query-rag.sh <backtest-id> "What are my most profitable symbols?"
Example 2: Time-Based Analysis
-----------------------------------0-----------------------------------------
./scripts/query-rag.sh <backtest-id> "What time of day is most profitable?"
Example 3: Risk Analysis
-----------------------------------0-----------------------------------------
./scripts/query-rag.sh <backtest-id> "When did I have the biggest drawdowns and why?"
Example 4: Pattern Discovery
-----------------------------------0-----------------------------------------
./scripts/query-rag.sh <backtest-id> "Find patterns in my losing trades"
Example 5: Using Python
python
-----------------------------------...-----------------------------------------
import requests


# Generate embeddings
response = requests.post('http://localhost:30801/api/v1/embeddings/generate', json={
    'backtest_id': 'your-backtest-id',
    'force_regenerate': False
})
print(response.json())


# Query with natural language
response = requests.post('http://localhost:30801/api/v1/query', json={
    'query': 'What days should I avoid trading?',
    'backtest_id': 'your-backtest-id',
    'top_k': 10
})


result = response.json()
print(f"Answer: {result['answer']}")
print(f"Contexts used: {len(result['contexts'])}")
Example 6: Using curl
-----------------------------------0-----------------------------------------
# Generate embeddings
curl -X POST http://localhost:30801/api/v1/embeddings/generate \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "your-id",
    "force_regenerate": false
  }'


# Query
curl -X POST http://localhost:30801/api/v1/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are my best trading hours?",
    "backtest_id": "your-id",
    "top_k": 10
  }' | jq '.answer'
🐛 Troubleshooting
Issue 1: Embedding Generation Slow
Symptoms:


-----------------------------------...-----------------------------------------
Generating embeddings takes > 10 minutes
Solution:


-----------------------------------0-----------------------------------------
# Check pod resources
kubectl top pod -n trading-system -l app=rag-engine


# If CPU/Memory maxed out, increase resources
kubectl edit deployment rag-engine -n trading-system


# Increase:
resources:
  requests:
    memory: "4Gi"
    cpu: "2000m"
  limits:
    memory: "8Gi"
    cpu: "4000m"
Issue 2: Ollama Connection Failed
Symptoms:


-----------------------------------...-----------------------------------------
Error generating answer from LLM
Solution:


-----------------------------------0-----------------------------------------
# Check Ollama is running
kubectl get pods -n trading-system -l app=ollama


# Test Ollama directly
curl http://localhost:31434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Hello",
  "stream": false
}'


# If model not found, pull it
OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n trading-system $OLLAMA_POD -- ollama pull llama3.1:8b
Issue 3: ChromaDB Connection Failed
Symptoms:


-----------------------------------...-----------------------------------------
Error connecting to ChromaDB
Solution:


-----------------------------------0-----------------------------------------
# Check ChromaDB is running
kubectl get pods -n databases -l app=chromadb


# Test ChromaDB API
curl http://localhost:30800/api/v1/heartbeat


# Check logs
kubectl logs -n databases -l app=chromadb
Issue 4: Query Returns Empty Answer
Symptoms:


-----------------------------------...-----------------------------------------
Answer: "No answer generated"
Possible causes:


No embeddings generated
Query too vague
Ollama timeout
Solution:


-----------------------------------0-----------------------------------------
# 1. Check embeddings exist
./scripts/check-embedding-status.sh <backtest-id>


# 2. Try more specific query
./scripts/query-rag.sh <backtest-id> "Show me trades on Mondays with profit > 50 pips"


# 3. Check Ollama logs
kubectl logs -n trading-system -l app=ollama
📊 Performance Metrics
Expected Performance (on i7 5th gen, 24GB RAM):


Operation	Time	Notes
Embedding generation (10K trades)	2-5 min	First time only
Embedding generation (100K trades)	10-15 min	First time only
Query processing	5-15 sec	Includes LLM generation
Vector search	<1 sec	ChromaDB lookup
LLM generation	3-10 sec	Depends on answer length
✅ Phase 3 Checklist
 RAG engine Docker image built
 Service deployed to Kubernetes
 All tests passing
 API accessible at http://localhost:30801
 Embeddings generated for at least one backtest
 Successfully queried with natural language
 Ollama responding correctly
 ChromaDB storing vectors
When all items are checked, Phase 3 is complete! 🎉


🎯 What You've Accomplished
New Capabilities
Natural Language Queries


Ask questions in plain English
Get AI-generated insights
No SQL knowledge required
Semantic Search


Find similar trading patterns
Discover hidden correlations
Context-aware retrieval
AI-Powered Analysis


Automated pattern detection
Intelligent recommendations
Data-driven explanations
Architecture Components
Embedding Service: Converts text to vectors
ChromaDB: Stores and searches vectors
RAG Pipeline: Retrieves context + generates answers
Ollama Integration: Local LLM for privacy
🚀 Next Steps
Immediate Actions
Generate Embeddings for All Backtests:
-----------------------------------0-----------------------------------------
# List all backtests
curl http://localhost:30800/api/v1/backtests | jq '.[] | .id'


# Generate for each
for id in $(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[] | .id'); do
  ./scripts/generate-embeddings.sh $id
done
Explore Different Queries:
-----------------------------------0-----------------------------------------
# Try various questions
./scripts/query-rag.sh <id> "What symbols perform best on Tuesdays?"
./scripts/query-rag.sh <id> "Analyze my risk management"
./scripts/query-rag.sh <id> "Compare morning vs evening trading"
Create Backup:
-----------------------------------0-----------------------------------------
./infrastructure/scripts/backup.sh
Proceed to Phase 4
Once you're comfortable with RAG queries, you're ready for Phase 4: Distributed Computing


Phase 4 will cover:


Celery task queue setup
Distributed parameter optimization
Multi-machine backtesting
Parallel processing
Worker auto-scaling
📚 Sample Queries to Try
Performance Analysis
"What days should I avoid trading?"
"What are my most profitable symbols?"
"What time of day is most profitable?"
"Compare my performance on Mondays vs Fridays"
Risk Analysis
"When did I have the biggest drawdowns?"
"What patterns led to my largest losses?"
"Analyze my risk-reward ratio"
"Show me trades with high drawdown that recovered"
Pattern Discovery
"Find patterns in my losing trades"
"What market conditions favor my strategy?"
"Identify my best trading sessions"
"What symbols should I avoid?"
Strategy Optimization
"What stop loss would have been optimal?"
"Should I trade during news events?"
"What position size works best?"
"Analyze my entry timing"
Next: Phase 4: Distributed Computing


-----------------------------------...-----------------------------------------
