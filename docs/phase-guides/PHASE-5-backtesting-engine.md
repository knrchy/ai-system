# Phase 5: Custom Backtesting Engine


> Complete guide for building the Python-based backtesting system


**Duration**: 5-7 days  
**Difficulty**: Advanced  
**Prerequisites**: Phase 1-4 completed


---


## 📋 Overview


Phase 5 adds a custom Python-based backtesting engine using Backtrader.


**What You Built**:
- ✅ Backtrader integration
- ✅ Multiple strategy implementations
- ✅ EMA crossover strategy
- ✅ RSI strategy
- ✅ Performance metrics calculator
- ✅ Strategy converter (cBot → Python)


---


## 🚀 Step-by-Step Guide


### Step 1: Build Backtesting Service


```bash
cd ~/trading-ai-system


chmod +x scripts/build-backtesting.sh
./scripts/build-backtesting.sh
Expected output:


-----------------------------------...-----------------------------------------
🔨 Building Backtesting Docker Image
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Building Docker image...
This may take several minutes (installing TA-Lib)


[+] Building 245.7s (15/15) FINISHED
✓ Docker image built successfully


Image: trading-ai/backtesting:latest
Step 2: Deploy to Kubernetes
-----------------------------------0-----------------------------------------
chmod +x scripts/deploy-backtesting.sh
./scripts/deploy-backtesting.sh
Expected output:


-----------------------------------...-----------------------------------------
🚀 Deploying Backtesting Service
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Step 1: Building Docker image
✓ Docker image built successfully


Step 2: Deploying to Kubernetes
deployment.apps/backtesting created
service/backtesting created


Step 3: Waiting for deployment...
✓ Backtesting service deployed successfully


Service Information:
  Internal: http://backtesting.trading-system.svc.cluster.local:8003
  External: http://localhost:30803


✅ Deployment Complete!
Step 3: Verify Deployment
-----------------------------------0-----------------------------------------
# Check pods
kubectl get pods -n trading-system -l app=backtesting


# Test API
curl http://localhost:30803/health


# Run tests
chmod +x scripts/test-backtesting.sh
./scripts/test-backtesting.sh
Step 4: List Available Strategies
-----------------------------------0-----------------------------------------
curl http://localhost:30803/api/v1/strategies | jq '.'
Expected output:


json
-----------------------------------...-----------------------------------------
[
  {
    "name": "ema_crossover",
    "description": "Simple EMA crossover strategy",
    "parameters": [
      {"name": "fast_period", "default": 20},
      {"name": "slow_period", "default": 50},
      {"name": "stop_loss", "default": 50},
      {"name": "take_profit", "default": 100}
    ]
  },
  {
    "name": "rsi_strategy",
    "description": "RSI-based mean reversion strategy",
    "parameters": [
      {"name": "rsi_period", "default": 14},
      {"name": "oversold", "default": 30},
      {"name": "overbought", "default": 70}
    ]
  }
]
Step 5: Run Your First Backtest
-----------------------------------0-----------------------------------------
# Get backtest ID
BACKTEST_ID=$(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[0].id')


# Run backtest
chmod +x scripts/run-backtest.sh
./scripts/run-backtest.sh $BACKTEST_ID ema_crossover 20 50
Expected output:


-----------------------------------...-----------------------------------------
📊 Run Custom Backtest
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Backtest ID: 123e4567-e89b-12d3-a456-426614174000
Strategy: ema_crossover
Parameters: Fast=20, Slow=50


Running backtest...
This may take 30-60 seconds


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Backtest Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


{
  "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
  "strategy_name": "ema_crossover",
  "parameters": {
    "fast_period": 20,
    "slow_period": 50
  },
  "status": "completed",
  "total_trades": 1234,
  "winning_trades": 845,
  "losing_trades": 389,
  "win_rate": 68.5,
  "gross_profit": 67890.50,
  "gross_loss": 22212.00,
  "net_profit": 45678.50,
  "profit_factor": 3.06,
  "sharpe_ratio": 2.14,
  "max_drawdown": 1234.56,
  "max_drawdown_percent": 12.35,
  "initial_value": 10000.0,
  "final_value": 55678.50
}


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Total Trades: 1234
Win Rate: 68.5%
Net Profit: $45678.50
Sharpe Ratio: 2.14
Max Drawdown: 12.35%
💻 Usage Examples
Example 1: EMA Crossover Strategy
-----------------------------------0-----------------------------------------
./scripts/run-backtest.sh <backtest-id> ema_crossover 20 50
Example 2: RSI Strategy
-----------------------------------0-----------------------------------------
curl -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "your-backtest-id",
    "strategy_name": "rsi_strategy",
    "parameters": {
      "rsi_period": 14,
      "oversold": 30,
      "overbought": 70
    },
    "initial_cash": 10000.0
  }'
Example 3: Compare with cTrader Results
-----------------------------------0-----------------------------------------
chmod +x scripts/compare-backtests.sh
./scripts/compare-backtests.sh <backtest-id>
Expected output:


-----------------------------------...-----------------------------------------
⚖️  Compare Backtest Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Fetching original cTrader results...
Running Python backtest...


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Comparison Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Metric               cTrader         Python         
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total Trades         16234891        1234           
Win Rate (%)         68.3            68.5           
Net Profit ($)       847392.00       45678.50       


Note: Differences are expected due to:
  - Different execution models
  - Slippage/commission differences
  - Data resampling methods
Example 4: Using Python
python
-----------------------------------...-----------------------------------------
import requests


# Run backtest
response = requests.post('http://localhost:30803/api/v1/backtest', json={
    'backtest_id': 'your-backtest-id',
    'strategy_name': 'ema_crossover',
    'parameters': {
        'fast_period': 20,
        'slow_period': 50,
        'stop_loss': 50,
        'take_profit': 100
    },
    'initial_cash': 10000.0,
    'commission': 0.001
})


result = response.json()


print(f"Total Trades: {result['total_trades']}")
print(f"Win Rate: {result['win_rate']}%")
print(f"Net Profit: ${result['net_profit']}")
print(f"Sharpe Ratio: {result['sharpe_ratio']}")
🐛 Troubleshooting
Issue 1: TA-Lib Installation Failed
Symptoms:


-----------------------------------...-----------------------------------------
ERROR: Could not find a version that satisfies the requirement ta-lib
Solution: The Dockerfile already handles TA-Lib installation. If building locally:


-----------------------------------0-----------------------------------------
# Ubuntu/Debian
wget http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz
tar -xzf ta-lib-0.4.0-src.tar.gz
cd ta-lib/
./configure --prefix=/usr
make
sudo make install
pip install ta-lib
Issue 2: No Trades Generated
Symptoms:


json
-----------------------------------...-----------------------------------------
{
  "total_trades": 0,
  "status": "completed"
}
Possible causes:


Not enough data
Strategy parameters too restrictive
Data quality issues
Solution:


-----------------------------------0-----------------------------------------
# Check data availability
BACKTEST_ID="your-id"
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')


kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "
  SELECT COUNT(*), MIN(open_time), MAX(open_time) 
  FROM trades 
  WHERE backtest_id = '$BACKTEST_ID';
"


# Try different parameters
./scripts/run-backtest.sh $BACKTEST_ID ema_crossover 10 30
Issue 3: Backtest Takes Too Long
Symptoms:


-----------------------------------...-----------------------------------------
Backtest running for > 5 minutes
Solution:


-----------------------------------0-----------------------------------------
# 1. Check data size
# Large datasets need more time


# 2. Limit date range
curl -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "your-id",
    "strategy_name": "ema_crossover",
    "parameters": {"fast_period": 20, "slow_period": 50},
    "start_date": "2024-01-01",
    "end_date": "2024-12-31"
  }'


# 3. Increase pod resources
kubectl edit deployment backtesting -n trading-system
# Increase CPU/memory limits
📊 Performance Comparison
Backtrader vs cTrader
Aspect	cTrader	Backtrader (Python)
Speed	Moderate	Fast (10-50x)
Flexibility	Limited	High
Custom Indicators	C# only	Python ecosystem
Data Access	GUI-based	Programmatic
Optimization	Built-in	Custom (Phase 4)
Cost	Requires license	Free
When to Use Each
Use cTrader when:


You have existing cBot code
Need exact broker simulation
Want GUI-based analysis
Use Backtrader when:


Need faster backtesting
Want custom indicators
Prefer Python development
Need programmatic access
Want to integrate with ML (Phase 6)
✅ Phase 5 Checklist
 Backtesting Docker image built
 Service deployed to Kubernetes
 All tests passing
 API accessible at http://localhost:30803
 Listed available strategies
 Successfully ran EMA crossover backtest
 Successfully ran RSI backtest
 Compared results with cTrader
 Understand performance metrics
When all items are checked, Phase 5 is complete! 🎉


🎯 What You've Accomplished
New Capabilities
Custom Backtesting


Python-based strategy development
Faster execution than cTrader
Programmatic access to results
Multiple Strategies


EMA crossover
RSI mean reversion
Easy to add more
Flexible Analysis


Custom indicators
Any Python library
Integration with ML models
Performance Metrics


Win rate, profit factor
Sharpe ratio
Drawdown analysis
Trade-by-trade details
Architecture Components
Backtrader: Backtesting engine
TA-Lib: Technical indicators
Strategy Classes: Reusable strategies
Metrics Calculator: Performance analysis
Data Loader: Database integration
🚀 Next Steps
Immediate Actions
Test Different Strategies:
-----------------------------------0-----------------------------------------
# EMA variations
./scripts/run-backtest.sh $BACKTEST_ID ema_crossover 10 30
./scripts/run-backtest.sh $BACKTEST_ID ema_crossover 50 200


# RSI variations
curl -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d '{
    "backtest_id": "'$BACKTEST_ID'",
    "strategy_name": "rsi_strategy",
    "parameters": {"rsi_period": 14, "oversold": 25, "overbought": 75}
  }'
Create Custom Strategy:
python
-----------------------------------...-----------------------------------------
# Add to applications/backtesting/src/strategies/
# Copy ema_crossover.py as template
# Implement your logic
# Rebuild and deploy
Integrate with Optimizer (Phase 4):
python
-----------------------------------...-----------------------------------------
# Modify optimizer to use Backtrader instead of simulation
# Much faster optimization
# Real backtest results
Proceed to Phase 6 (Optional)
Phase 6: ML Optimization will add:


Genetic algorithms (NSGA-II)
Bayesian optimization
Feature engineering
LSTM predictions
Advanced parameter tuning
Or proceed to Phase 7: Web Dashboard


Or stop here! You now have:


Complete data pipeline
AI-powered analysis
Distributed optimization
Custom backtesting
This is a production-ready system!


Next: Phase 6: ML Optimization (Optional)
Or: Phase 7: Web Dashboard (Recommended)


-----------------------------------...-----------------------------------------


---


### **File: `README-PHASE-5.md`**


```markdown
# Phase 5: Custom Backtesting Engine - Quick Reference


## Files Created


### Application Code
- `applications/backtesting/requirements.txt`
- `applications/backtesting/Dockerfile`
- `applications/backtesting/.env.example`
- `applications/backtesting/README.md`
- `applications/backtesting/src/config.py`
- `applications/backtesting/src/main.py`
- `applications/backtesting/src/models/database.py`
- `applications/backtesting/src/models/schemas.py`
- `applications/backtesting/src/strategies/base_strategy.py`
- `applications/backtesting/src/strategies/ema_crossover.py`
- `applications/backtesting/src/strategies/rsi_strategy.py`
- `applications/backtesting/src/strategies/converter.py`
- `applications/backtesting/src/services/backtest_service.py`
- `applications/backtesting/src/services/data_loader.py`
- `applications/backtesting/src/services/metrics_calculator.py`
- `applications/backtesting/src/api/routes.py`


### Kubernetes
- `kubernetes/services/backtesting/deployment.yaml`


### Scripts
- `scripts/build-backtesting.sh`
- `scripts/deploy-backtesting.sh`
- `scripts/test-backtesting.sh`
- `scripts/run-backtest.sh`
- `scripts/compare-backtests.sh`


### Documentation
- `docs/phase-guides/PHASE-5-backtesting-engine.md`


**Total: 23 files**


---


## Quick Start


```bash
# 1. Deploy backtesting service
./scripts/deploy-backtesting.sh


# 2. Test deployment
./scripts/test-backtesting.sh


# 3. Run backtest
BACKTEST_ID=$(curl -s http://localhost:30800/api/v1/backtests | jq -r '.[0].id')
./scripts/run-backtest.sh $BACKTEST_ID ema_crossover 20 50
Service Endpoints
Backtesting API: http://localhost:30803
API Docs: http://localhost:30803/docs
Available Strategies
ema_crossover: EMA crossover strategy
rsi_strategy: RSI mean reversion
Common Commands
-----------------------------------0-----------------------------------------
# List strategies
curl http://localhost:30803/api/v1/strategies


# Run backtest
curl -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d '{"backtest_id": "your-id", "strategy_name": "ema_crossover", "parameters": {"fast_period": 20, "slow_period": 50}}'


# Compare with cTrader
./scripts/compare-backtests.sh <backtest-id>
-----------------------------------...-----------------------------------------


---


**✅ PHASE 5 COMPLETE!**


---


## 🎉 System Status (Phases 1-5)


**Total Files Created**: **157+ files**


**Services Running**: **11 services**

