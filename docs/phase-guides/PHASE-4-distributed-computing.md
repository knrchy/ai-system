# Phase 4: Distributed Computing & Task Queue


> Complete guide for building the distributed optimization system


**Duration**: 3-4 days  
**Difficulty**: Advanced  
**Prerequisites**: Phase 1, 2, 3 completed


---


## 📋 Overview


Phase 4 adds distributed computing capabilities for parallel parameter optimization.


**What You Built**:
- ✅ Celery task queue
- ✅ Redis message broker
- ✅ Distributed workers
- ✅ Optimization service
- ✅ Auto-scaling workers
- ✅ Flower monitoring


---


## 🚀 Step-by-Step Guide


### Step 1: Build Optimizer


```bash
cd ~/trading-ai-system


chmod +x scripts/build-optimizer.sh
./scripts/build-optimizer.sh
Expected output:


-----------------------------------...-----------------------------------------
🔨 Building Optimizer Docker Image
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Building Docker image...
[+] Building 65.3s (12/12) FINISHED
✓ Docker image built successfully


Image: trading-ai/optimizer:latest
Step 2: Deploy to Kubernetes
-----------------------------------0-----------------------------------------
chmod +x scripts/deploy-optimizer.sh
./scripts/deploy-optimizer.sh
Expected output:


-----------------------------------...-----------------------------------------
🚀 Deploying Optimizer Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Step 1: Creating database tables
✓ Database tables created


Step 2: Building Docker image
✓ Docker image built successfully


Step 3: Deploying to Kubernetes
deployment.apps/optimizer-api created
deployment.apps/celery-worker created
deployment.apps/flower created


Step 4: Waiting for deployments...
✓ Optimizer deployed successfully


Service Information:
  Optimizer API: http://localhost:30802
  Flower (Monitoring): http://localhost:30555


✅ Deployment Complete!
Step 3: Verify Deployment
-----------------------------------0-----------------------------------------
# Check pods
kubectl get pods -n trading-system


# Test API
curl http://localhost:30802/health


# Check workers
curl http://localhost:30802/api/v1/workers/status | jq '.'


# Run tests
chmod +x scripts/test-optimizer.sh
./scripts/test-optimizer.sh
Step 4: Run Your First Optimization
-----------------------------------0-----------------------------------------
# Get your backtest ID
BACKTEST_ID=$(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[0].id')


# Run optimization
chmod +x scripts/run-optimization.sh
./scripts/run-optimization.sh $BACKTEST_ID stop_loss 20 80 2
Expected output:


-----------------------------------...-----------------------------------------
⚡ Run Parameter Optimization
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Backtest ID: 123e4567-e89b-12d3-a456-426614174000
Parameter: stop_loss
Range: 20 to 80 (step: 2)


Total combinations to test: 31


Continue? (yes/no): yes


Starting optimization...


Response:
{
  "optimization_id": "456e7890-e89b-12d3-a456-426614174000",
  "status": "running",
  "total_tasks": 31,
  "message": "Optimization started with 31 parameter combinations"
}


✅ Optimization started!


Optimization ID: 456e7890-e89b-12d3-a456-426614174000


Monitor progress:
  ./scripts/check-optimization-status.sh 456e7890-e89b-12d3-a456-426614174000
Step 5: Monitor Progress
-----------------------------------0-----------------------------------------
chmod +x scripts/check-optimization-status.sh
./scripts/check-optimization-status.sh <optimization-id>
Live output:


-----------------------------------...-----------------------------------------
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Optimization Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Optimization ID: 456e7890-e89b-12d3-a456-426614174000
Status: running
Progress: 67.7%
Completed: 21 / 31 tasks


[=================================                 ] 67.7%


Refreshing in 5 seconds... (Ctrl+C to stop)
Step 6: Get Results
-----------------------------------0-----------------------------------------
chmod +x scripts/get-optimization-results.sh
./scripts/get-optimization-results.sh <optimization-id>
Expected output:


-----------------------------------...-----------------------------------------
🏆 Get Optimization Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Fetching results for: 456e7890-e89b-12d3-a456-426614174000


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Top Results Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Rank 1: stop_loss=38
  → Profit: $847392.00 | Win Rate: 74.1% | Sharpe: 2.34


Rank 2: stop_loss=36
  → Profit: $831245.00 | Win Rate: 73.8% | Sharpe: 2.29


Rank 3: stop_loss=40
  → Profit: $829103.00 | Win Rate: 74.3% | Sharpe: 2.28


Best Parameters:
{
  "stop_loss": 38
}
💻 Usage Examples
Example 1: Single Parameter Optimization
-----------------------------------0-----------------------------------------
./scripts/run-optimization.sh <backtest-id> stop

### Example 1: Single Parameter Optimization


```bash
./scripts/run-optimization.sh <backtest-id> stop_loss 20 80 2
Example 2: Multi-Parameter Optimization (via API)
-----------------------------------0-----------------------------------------
curl -X POST http://localhost:30802/api/v1/optimize \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "your-backtest-id",
    "parameters": [
      {"name": "stop_loss", "min_value": 20, "max_value": 80, "step": 2},
      {"name": "take_profit", "min_value": 40, "max_value": 200, "step": 10}
    ],
    "optimization_type": "grid_search"
  }'
This will test: 31 × 17 = 527 combinations


Example 3: Random Search (Faster)
-----------------------------------0-----------------------------------------
curl -X POST http://localhost:30802/api/v1/optimize \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "your-backtest-id",
    "parameters": [
      {"name": "stop_loss", "min_value": 20, "max_value": 80, "step": 1},
      {"name": "take_profit", "min_value": 40, "max_value": 200, "step": 1}
    ],
    "optimization_type": "random_search",
    "max_iterations": 100
  }'
This will test: Only 100 random combinations (much faster)


Example 4: Using Python
python
-----------------------------------...-----------------------------------------
import requests
import time


# Start optimization
response = requests.post('http://localhost:30802/api/v1/optimize', json={
    'backtest_id': 'your-backtest-id',
    'parameters': [
        {'name': 'stop_loss', 'min_value': 20, 'max_value': 80, 'step': 2}
    ],
    'optimization_type': 'grid_search'
})


optimization_id = response.json()['optimization_id']
print(f"Optimization started: {optimization_id}")


# Poll for completion
while True:
    status = requests.get(f'http://localhost:30802/api/v1/optimize/{optimization_id}/status')
    data = status.json()
    
    print(f"Progress: {data['progress_percent']}%")
    
    if data['status'] == 'completed':
        break
    
    time.sleep(5)


# Get results
results = requests.get(f'http://localhost:30802/api/v1/optimize/{optimization_id}/results')
best = results.json()['results'][0]


print(f"Best parameters: {best['parameters']}")
print(f"Net profit: ${best['net_profit']}")
Example 5: Scale Workers for Large Jobs
-----------------------------------0-----------------------------------------
# Before starting large optimization, scale up workers
./scripts/scale-workers.sh 10


# Run optimization
./scripts/run-optimization.sh <backtest-id> stop_loss 10 100 1


# After completion, scale down
./scripts/scale-workers.sh 3
🌐 Flower Monitoring Dashboard
Access: http://localhost:30555


Features:


Real-time worker status
Active/completed/failed tasks
Task execution times
Worker resource usage
Task history
Screenshots of what you'll see:


Workers list with status
Task timeline
Success/failure rates
Performance graphs
🐛 Troubleshooting
Issue 1: Workers Not Starting
Symptoms:


-----------------------------------0-----------------------------------------
kubectl get pods -n trading-system -l app=celery-worker
# Shows CrashLoopBackOff
Solution:


-----------------------------------0-----------------------------------------
# Check logs
kubectl logs -n trading-system -l app=celery-worker


# Common issues:
# 1. Redis connection failed
kubectl get pods -n databases -l app=redis


# 2. Database connection failed
kubectl get pods -n databases -l app=postgres


# 3. Restart workers
kubectl rollout restart deployment/celery-worker -n trading-system
Issue 2: Tasks Stuck in Queue
Symptoms:


-----------------------------------...-----------------------------------------
Optimization running but progress = 0%
Solution:


-----------------------------------0-----------------------------------------
# Check worker status
curl http://localhost:30802/api/v1/workers/status


# If no workers online, check pods
kubectl get pods -n trading-system -l app=celery-worker


# View Flower dashboard
# Open: http://localhost:30555


# Restart workers if needed
kubectl delete pods -n trading-system -l app=celery-worker
Issue 3: Optimization Too Slow
Symptoms:


-----------------------------------...-----------------------------------------
31 tasks taking > 30 minutes
Solutions:


Option 1: Add more workers


-----------------------------------0-----------------------------------------
./scripts/scale-workers.sh 10
Option 2: Add worker nodes


-----------------------------------0-----------------------------------------
# On new machine
./infrastructure/scripts/add-worker.sh


# Workers will auto-scale to new nodes
Option 3: Use random search instead


-----------------------------------0-----------------------------------------
# Instead of grid search (tests all combinations)
# Use random search (tests subset)
"optimization_type": "random_search",
"max_iterations": 100
Issue 4: Out of Memory
Symptoms:


-----------------------------------...-----------------------------------------
Worker pods restarting frequently
OOMKilled in pod status
Solution:


-----------------------------------0-----------------------------------------
# Increase worker memory
kubectl edit deployment celery-worker -n trading-system


# Change:
resources:
  limits:
    memory: "8Gi"  # Increase from 4Gi
📊 Performance Benchmarks
Expected Performance (i7 5th gen, 24GB RAM, 3 workers):


Scenario	Tasks	Time	Notes
Single param (31 combos)	31	2-3 min	3 workers × 4 cores
Two params (527 combos)	527	30-40 min	Grid search
Two params (100 combos)	100	6-8 min	Random search
Three params (1000 combos)	1000	60-80 min	Grid search
With 10 workers (adding 2 more machines):


31 tasks: ~1 minute
527 tasks: ~12 minutes
1000 tasks: ~20 minutes
Speedup: ~3-4x with 3x more workers


✅ Phase 4 Checklist
 Optimizer Docker image built
 Service deployed to Kubernetes
 All tests passing
 API accessible at http://localhost:30802
 Flower accessible at http://localhost:30555
 Workers showing as online
 Successfully ran test optimization
 Results retrieved and ranked
 Can scale workers up/down
When all items are checked, Phase 4 is complete! 🎉


🎯 What You've Accomplished
New Capabilities
Distributed Optimization


Run 100s of backtests in parallel
Utilize multiple machines
10-100x faster than sequential
Auto-Scaling


Workers scale based on load
Efficient resource utilization
Easy to add more machines
Real-Time Monitoring


Flower dashboard
Live progress tracking
Task success/failure rates
Flexible Optimization


Grid search (exhaustive)
Random search (faster)
Genetic algorithms (future)
Architecture Components
Celery: Distributed task queue
Redis: Message broker & result backend
Workers: Execute optimization tasks
API: Orchestrate optimizations
Flower: Monitor workers & tasks
🚀 Next Steps
Immediate Actions
Run Real Optimization:
-----------------------------------0-----------------------------------------
# Get your backtest
BACKTEST_ID=$(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[0].id')


# Optimize stop loss
./scripts/run-optimization.sh $BACKTEST_ID stop_loss 20 80 2


# Monitor in Flower
# Open: http://localhost:30555
Add More Machines (if available):
-----------------------------------0-----------------------------------------
# On each new machine
./infrastructure/scripts/add-worker.sh


# Workers will auto-deploy via Kubernetes
Experiment with Parameters:
-----------------------------------0-----------------------------------------
# Try different parameters
./scripts/run-optimization.sh $BACKTEST_ID take_profit 50 200 10


# Try multi-parameter (via API)
# See Example 2 above
Proceed to Phase 5
Once you're comfortable with distributed optimization, you're ready for Phase 5: Custom Backtesting Engine


Phase 5 will cover:


Backtrader integration
Custom strategy implementation
Recreating cBot logic in Python
Walk-forward analysis
Custom indicators
Or stop here! You now have:


Data storage & querying
AI-powered analysis
Distributed optimization
This is already a powerful system!


📚 Additional Resources
Celery Documentation
Official docs: https://docs.celeryproject.org/
Best practices: https://docs.celeryproject.org/en/stable/userguide/tasks.html
Flower Documentation
GitHub: https://github.com/mher/flower
Monitoring guide: https://flower.readthedocs.io/
Optimization Strategies
Grid Search: Exhaustive search of all combinations
Random Search: Sample random combinations
Bayesian Optimization: Smart sampling (Phase 6)
Genetic Algorithms: Evolution-based (Phase 6)
Next: Phase 5: Custom Backtesting Engine (Optional)


-----------------------------------...-----------------------------------------


---


### **File: `README-PHASE-4.md`**


```markdown
# Phase 4: Distributed Computing - Quick Reference


## Files Created


### Application Code
- `applications/optimizer/requirements.txt`
- `applications/optimizer/Dockerfile`
- `applications/optimizer/.env.example`
- `applications/optimizer/README.md`
- `applications/optimizer/src/config.py`
- `applications/optimizer/src/main.py`
- `applications/optimizer/src/celery_app.py`
- `applications/optimizer/src/models/database.py`
- `applications/optimizer/src/models/schemas.py`
- `applications/optimizer/src/tasks/backtest_task.py`
- `applications/optimizer/src/tasks/optimization_task.py`
- `applications/optimizer/src/services/optimization_service.py`
- `applications/optimizer/src/services/result_service.py`
- `applications/optimizer/src/api/routes.py`


### Kubernetes
- `kubernetes/services/optimizer/deployment.yaml`


### Scripts
- `scripts/build-optimizer.sh`
- `scripts/deploy-optimizer.sh`
- `scripts/test-optimizer.sh`
- `scripts/run-optimization.sh`
- `scripts/check-optimization-status.sh`
- `scripts/get-optimization-results.sh`
- `scripts/scale-workers.sh`


### Documentation
- `docs/phase-guides/PHASE-4-distributed-computing.md`


**Total: 23 files**


---


## Quick Start


```bash
# 1. Deploy optimizer
./scripts/deploy-optimizer.sh


# 2. Test deployment
./scripts/test-optimizer.sh


# 3. Run optimization
BACKTEST_ID=$(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[0].id')
./scripts/run-optimization.sh $BACKTEST_ID stop_loss 20 80 2


# 4. Monitor progress
# Open: http://localhost:30555 (Flower)
Service Endpoints
Optimizer API: http://localhost:30802
Flower Monitoring: http://localhost:30555
API Docs: http://localhost:30802/docs
Common Commands
-----------------------------------0-----------------------------------------
# Check workers
curl http://localhost:30802/api/v1/workers/status


# Scale workers
./scripts/scale-workers.sh 10


# View logs
kubectl logs -f deployment/celery-worker -n trading-system


# Restart workers
kubectl rollout restart deployment/celery-worker -n trading-system
-----------------------------------...-----------------------------------------


---


**✅ PHASE 4 COMPLETE!**


---


## 🎉 Complete System Summary (Phases 1-4)


**Total Files Created**: **111+ files**


**Services Running**:
1. PostgreSQL
2. Redis
3. ChromaDB
4. Ollama
5. Data Pipeline API
6. RAG Engine API
7. Optimizer API
8. Celery Workers (3-10 instances)
9. Flower Monitoring
10. Prometheus + Grafana


**Capabilities**:
- ✅ Upload & store trading data
- ✅ Query with SQL
- ✅ Ask questions in natural language
- ✅ Get AI insights
- ✅ Semantic search
- ✅ Distributed parameter optimization
- ✅ 10-100x faster optimization
- ✅ Auto-scaling workers
- ✅ Real-time monitoring


---


**What would you like to do?** Type:
- **"done"** - I'm finished, this is perfect
- **"phase 5"** - Continue to Custom Backtesting Engine
- **"test"** - I want to test everything
- **"summary"** - Show final summary of all phases
Copy




continue please
-----------------------------------answ-----------------------------------------
🚀 Moving Forward - Decision Point
🎊 Congratulations! You've Built an Amazing System
You now have Phases 1-4 complete:


✅ Phase 1: Infrastructure (K3s, databases, monitoring)
✅ Phase 2: Data Pipeline (ingestion, storage)
✅ Phase 3: RAG System (AI queries, semantic search)
✅ Phase 4: Distributed Computing (parallel optimization)


Total: 111+ files, 10 services, fully functional system

