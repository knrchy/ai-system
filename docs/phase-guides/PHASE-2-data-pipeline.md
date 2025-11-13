# Phase 2: Data Pipeline & Storage


> Complete guide for building the data ingestion pipeline


**Duration**: 3-4 days  
**Difficulty**: Intermediate  
**Prerequisites**: Phase 1 completed


---


## 📋 Overview


Phase 2 builds the data ingestion and processing pipeline:


**What You'll Build**:
- ✅ Database schema for trading data
- ✅ JSON parser for cTrader exports
- ✅ CSV parser for transaction logs
- ✅ Data validation system
- ✅ FastAPI service for data ingestion
- ✅ Kubernetes deployment


**What You'll Learn**:
- Database schema design
- Data parsing and validation
- FastAPI development
- Docker containerization
- Kubernetes service deployment


---


## 🚀 Step-by-Step Guide


### Step 1: Create Database Schema


```bash
cd ~/trading-ai-system


# Connect to PostgreSQL
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')


# Apply schema
kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db < applications/data-pipeline/schema/001_initial_schema.sql
Verify schema creation:


-----------------------------------0-----------------------------------------
kubectl exec -it -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db


# List tables
\dt


# Expected output:
# backtests
# trades
# parameters
# daily_summary
# ingestion_jobs


# Exit
\q
Step 2: Build Docker Image
-----------------------------------0-----------------------------------------
chmod +x scripts/build-data-pipeline.sh
./scripts/build-data-pipeline.sh
Expected output:


-----------------------------------...-----------------------------------------
🔨 Building Data Pipeline Docker Image
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Building Docker image...
[+] Building 45.2s (12/12) FINISHED
✓ Docker image built successfully


Image: trading-ai/data-pipeline:latest
Step 3: Deploy to Kubernetes
-----------------------------------0-----------------------------------------
chmod +x scripts/deploy-data-pipeline.sh
./scripts/deploy-data-pipeline.sh
Expected output:


-----------------------------------...-----------------------------------------
🚀 Deploying Data Pipeline Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Step 1: Creating database schema
✓ Database schema created


Step 2: Building Docker image
✓ Docker image built successfully


Step 3: Deploying to Kubernetes
deployment.apps/data-pipeline created
service/data-pipeline created


Step 4: Waiting for deployment...
deployment.apps/data-pipeline condition met


✓ Data Pipeline deployed successfully


Service Information:
  Internal: http://data-pipeline.trading-system.svc.cluster.local:8000
  External: http://localhost:30800


API Documentation:
  Swagger UI: http://localhost:30800/docs
  ReDoc: http://localhost:30800/redoc


✅ Deployment Complete!
Step 4: Verify Deployment
-----------------------------------0-----------------------------------------
# Check pods
kubectl get pods -n trading-system


# Expected output:
# NAME                             READY   STATUS    RESTARTS   AGE
# data-pipeline-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
# data-pipeline-xxxxxxxxxx-xxxxx   1/1     Running   0          2m


# Check service
kubectl get svc -n trading-system data-pipeline


# Test API
curl http://localhost:30800/health
Step 5: Run Tests
-----------------------------------0-----------------------------------------
chmod +x scripts/test-data-pipeline.sh
./scripts/test-data-pipeline.sh
Expected output:


-----------------------------------...-----------------------------------------
🧪 Testing Data Pipeline Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Testing: Health check
✓ PASSED (Status: 200)


Testing: Root endpoint
✓ PASSED (Status: 200)


Testing: API docs
✓ PASSED (Status: 200)


Testing: List backtests
✓ PASSED (Status: 200)


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Results Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Passed: 4
Failed: 0


✅ All tests passed!
💻 Usage Examples
Example 1: Upload Backtest Data via API
Using curl:


-----------------------------------0-----------------------------------------
curl -X POST "http://localhost:30800/api/v1/ingest" \
  -F "json_file=@/path/to/results.json" \
  -F "name=My First Backtest" \
  -F "description=10-year EMA strategy" \
  -F "initial_balance=10000"
Expected response:


json
-----------------------------------...-----------------------------------------
{
  "job_id": "123e4567-e89b-12d3-a456-426614174000",
  "backtest_id": "123e4567-e89b-12d3-a456-426614174001",
  "status": "completed",
  "message": "Successfully ingested 15234 trades"
}
Example 2: Using Python Client
python
-----------------------------------...-----------------------------------------
import requests


# Upload files
url = "http://localhost:30800/api/v1/ingest"


files = {
    'json_file': open('results.json', 'rb'),
    'csv_file': open('transactions.csv', 'rb')
}


data = {
    'name': 'My Backtest',
    'description': 'Test backtest',
    'initial_balance': 10000.00
}


response = requests.post(url, files=files, data=data)
print(response.json())


# Get backtest details
backtest_id = response.json()['backtest_id']
backtest = requests.get(f"{url}/backtests/{backtest_id}")
print(backtest.json())
Example 3: Query Database Directly
-----------------------------------0-----------------------------------------
# Connect to PostgreSQL
kubectl exec -it -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db
List all backtests:


sql
-----------------------------------...-----------------------------------------
SELECT id, name, total_trades, win_rate, net_profit, created_at
FROM backtests
ORDER BY created_at DESC
LIMIT 10;
Get trades for a specific backtest:


sql
-----------------------------------...-----------------------------------------
SELECT 
    open_time,
    symbol,
    direction,
    entry_price,
    exit_price,
    profit,
    pips
FROM trades
WHERE backtest_id = 'your-backtest-id'
ORDER BY open_time
LIMIT 100;
Daily performance summary:


sql
-----------------------------------...-----------------------------------------
SELECT 
    trade_date,
    total_trades,
    winning_trades,
    net_profit,
    win_rate
FROM daily_summary
WHERE backtest_id = 'your-backtest-id'
ORDER BY trade_date;
Top performing symbols:


sql
-----------------------------------...-----------------------------------------
SELECT 
    symbol,
    COUNT(*) as trade_count,
    SUM(profit) as total_profit,
    AVG(profit) as avg_profit,
    ROUND(AVG(CASE WHEN profit > 0 THEN 1 ELSE 0 END) * 100, 2) as win_rate
FROM trades
WHERE backtest_id = 'your-backtest-id'
GROUP BY symbol
ORDER BY total_profit DESC;
🐛 Troubleshooting
Issue 1: Schema Creation Fails
Symptoms:


-----------------------------------...-----------------------------------------
ERROR: relation "backtests" already exists
Solution:


-----------------------------------0-----------------------------------------
# Drop and recreate schema
kubectl exec -it -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db


DROP TABLE IF EXISTS trades CASCADE;
DROP TABLE IF EXISTS backtests CASCADE;
DROP TABLE IF EXISTS parameters CASCADE;
DROP TABLE IF EXISTS daily_summary CASCADE;
DROP TABLE IF EXISTS ingestion_jobs CASCADE;


\q


# Reapply schema
kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db < applications/data-pipeline/schema/001_initial_schema.sql
Issue 2: Pod Not Starting
Symptoms:


-----------------------------------...-----------------------------------------
kubectl get pods -n trading-system
# Shows CrashLoopBackOff or Error
Solution:


-----------------------------------0-----------------------------------------
# Check logs
kubectl logs -n trading-system deployment/data-pipeline


# Common issues:
# 1. Database connection failed
# Check DATABASE_URL in configmap


# 2. Missing dependencies
# Rebuild Docker image


# 3. Port already in use
# Check if NodePort 30800 is available
Issue 3: File Upload Fails
Symptoms:


-----------------------------------...-----------------------------------------
{"detail":"File too large"}
Solution:


-----------------------------------0-----------------------------------------
# Increase file size limit
kubectl edit configmap data-pipeline-config -n trading-system


# Add:
MAX_FILE_SIZE_MB: "1000"


# Restart deployment
kubectl rollout restart deployment/data-pipeline -n trading-system
## ✅ Phase 2 Checklist


- [ ] Database schema created
- [ ] Docker image built
- [ ] Service deployed to Kubernetes
- [ ] All tests passing
- [ ] API accessible at http://localhost:30800
- [ ] Can upload test file successfully
- [ ] Database queries working
- [ ] Swagger docs accessible


**When all items are checked, Phase 2 is complete!** 🎉


---


## 📊 What You've Built


### Database Tables


1. **backtests** - Stores backtest metadata and summary
2. **trades** - Individual trade records
3. **parameters** - Bot parameters
4. **daily_summary** - Daily aggregated performance
5. **ingestion_jobs** - Tracks data ingestion jobs


### API Endpoints


- `POST /api/v1/ingest` - Upload backtest data
- `GET /api/v1/backtests` - List all backtests
- `GET /api/v1/backtests/{id}` - Get backtest details
- `GET /api/v1/jobs/{id}` - Get job status
- `DELETE /api/v1/backtests/{id}` - Delete backtest
- `GET /health` - Health check


### Services


- **Data Pipeline API** - FastAPI service for data ingestion
- **PostgreSQL** - Structured data storage
- **File Storage** - Raw file persistence


---


## 🎯 Next Steps


### Immediate Actions


1. **Upload Your First Backtest**:
```bash
# Prepare your cTrader export files
# - results.json
# - transactions.csv (optional)
# - parameters.json (optional)


# Upload via API
curl -X POST "http://localhost:30800/api/v1/ingest" \
  -F "json_file=@results.json" \
  -F "name=My First Backtest" \
  -F "initial_balance=10000"
Explore the Data:
-----------------------------------0-----------------------------------------
# Access Swagger UI
# Open browser: http://localhost:30800/docs


# Or query database directly
kubectl exec -it -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db
Create a Backup:
-----------------------------------0-----------------------------------------
./infrastructure/scripts/backup.sh
Proceed to Phase 3
Once you have successfully ingested data, you're ready for Phase 3: RAG System


Phase 3 will cover:


Setting up ChromaDB collections
Generating embeddings from trade data
Building the RAG query system
Integrating with Ollama LLM
Natural language queries over your data
📚 Additional Resources
API Documentation
Access the interactive API documentation:


Swagger UI: http://localhost:30800/docs
ReDoc: http://localhost:30800/redoc
Database Schema Reference
See applications/data-pipeline/schema/001_initial_schema.sql for complete schema definition.


Example Queries
Common SQL queries for analyzing your data:


Total profit by month:


sql
-----------------------------------...-----------------------------------------
SELECT 
    DATE_TRUNC('month', open_time) as month,
    COUNT(*) as trades,
    SUM(profit) as total_profit
FROM trades
WHERE backtest_id = 'your-id'
GROUP BY month
ORDER BY month;
Win rate by day of week:


sql
-----------------------------------...-----------------------------------------
SELECT 
    TO_CHAR(open_time, 'Day') as day_of_week,
    COUNT(*) as total_trades,
    SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END) as winning_trades,
    ROUND(AVG(CASE WHEN profit > 0 THEN 1 ELSE 0 END) * 100, 2) as win_rate
FROM trades
WHERE backtest_id = 'your-id'
GROUP BY day_of_week, EXTRACT(DOW FROM open_time)
ORDER BY EXTRACT(DOW FROM open_time);
Drawdown analysis:


sql
-----------------------------------...-----------------------------------------
SELECT 
    open_time,
    balance_after,
    drawdown,
    drawdown_percent
FROM trades
WHERE backtest_id = 'your-id'
ORDER BY drawdown_percent DESC
LIMIT 20;
🔄 Maintenance
Regular Tasks
Daily:


Monitor API health: curl http://localhost:30800/health
Check pod status: kubectl get pods -n trading-system
Weekly:


Review ingestion jobs: Check for failed jobs in database
Database maintenance: Run VACUUM ANALYZE on large tables
Backup: Create weekly backup
Monthly:


Clean old ingestion jobs
Archive old backtest data if needed
Review disk usage
Monitoring Queries
Check ingestion job status:


sql
-----------------------------------...-----------------------------------------
SELECT 
    status,
    COUNT(*) as count
FROM ingestion_jobs
GROUP BY status;
Recent failed jobs:


sql
-----------------------------------...-----------------------------------------
SELECT 
    id,
    job_type,
    error_message,
    created_at
FROM ingestion_jobs
WHERE status = 'failed'
ORDER BY created_at DESC
LIMIT 10;
Database size:


sql
-----------------------------------...-----------------------------------------
SELECT 
    pg_size_pretty(pg_database_size('trading_db')) as database_size;
Next: Phase 3: RAG System


-----------------------------------...-----------------------------------------


---


### **File: `README-PHASE-2.md`**


```markdown
# Phase 2: Data Pipeline - Quick Reference


## Files Created


### Application Code
- `applications/data-pipeline/requirements.txt`
- `applications/data-pipeline/Dockerfile`
- `applications/data-pipeline/.env.example`
- `applications/data-pipeline/src/config.py`
- `applications/data-pipeline/src/main.py`
- `applications/data-pipeline/src/models/database.py`
- `applications/data-pipeline/src/models/schemas.py`
- `applications/data-pipeline/src/parsers/json_parser.py`
- `applications/data-pipeline/src/parsers/csv_parser.py`
- `applications/data-pipeline/src/parsers/validator.py`
- `applications/data-pipeline/src/services/ingestion_service.py`
- `applications/data-pipeline/src/api/routes.py`


### Database
- `applications/data-pipeline/schema/001_initial_schema.sql`


### Kubernetes
- `kubernetes/services/data-pipeline/deployment.yaml`


### Scripts
- `scripts/build-data-pipeline.sh`
- `scripts/deploy-data-pipeline.sh`
- `scripts/test-data-pipeline.sh`


### Documentation
- `docs/phase-guides/PHASE-2-data-pipeline.md`


---


## Quick Start


```bash
# 1. Deploy data pipeline
./scripts/deploy-data-pipeline.sh


# 2. Test deployment
./scripts/test-data-pipeline.sh


# 3. Upload data
curl -X POST "http://localhost:30800/api/v1/ingest" \
  -F "json_file=@results.json" \
  -F "name=Test Backtest" \
  -F "initial_balance=10000"


# 4. View API docs
# Open: http://localhost:30800/docs
Service Endpoints
API: http://localhost:30800
Health: http://localhost:30800/health
Docs: http://localhost:30800/docs
ReDoc: http://localhost:30800/redoc
Database Access
-----------------------------------0-----------------------------------------
# Connect to PostgreSQL
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db


# List tables
\dt


# Query backtests
SELECT * FROM backtests ORDER BY created_at DESC LIMIT 5;
Common Commands
-----------------------------------0-----------------------------------------
# View logs
kubectl logs -f deployment/data-pipeline -n trading-system


# Restart service
kubectl rollout restart deployment/data-pipeline -n trading-system


# Scale replicas
kubectl scale deployment/data-pipeline --replicas=3 -n trading-system


# Delete service
kubectl delete -f kubernetes/services/data-pipeline/deployment.yaml
Troubleshooting
Pod not starting?


-----------------------------------0-----------------------------------------
kubectl describe pod -n trading-system -l app=data-pipeline
kubectl logs -n trading-system -l app=data-pipeline
Database connection issues?


-----------------------------------0-----------------------------------------
# Test database connectivity
kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "SELECT 1;"
API not responding?


-----------------------------------0-----------------------------------------
# Check service
kubectl get svc -n trading-system data-pipeline


# Port forward
kubectl port-forward -n trading-system svc/data-pipeline 8000:8000
# Then access: http://localhost:8000
-----------------------------------...-----------------------------------------


---


**✅ PHASE 2 COMPLETE!**


---


## 📊 Phase 2 Summary


You now have:


1. ✅ **Database Schema** - 5 tables for trading data
2. ✅ **JSON Parser** - Parse cTrader exports
3. ✅ **CSV Parser** - Handle large transaction logs
4. ✅ **Data Validator** - Ensure data quality
5. ✅ **FastAPI Service** - RESTful API for data ingestion
6. ✅ **Kubernetes Deployment** - Scalable service deployment
7. ✅ **API Documentation** - Interactive Swagger UI


**Total Files Created**: 20+ files


---


**Ready to proceed to Phase 3?** Type "**phase 3**" or "**done**" if you want to stop here.
