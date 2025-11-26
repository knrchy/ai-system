# Backtesting Service


Custom backtesting service using Backtrader framework.


## Features


- Multiple strategy implementations
- EMA crossover strategy
- RSI strategy
- Custom indicators
- Performance metrics calculation
- Strategy parameter optimization


## Strategies


### EMA Crossover
Buy when fast EMA crosses above slow EMA, sell when it crosses below.


**Parameters**:
- `fast_period`: Fast EMA period (default: 20)
- `slow_period`: Slow EMA period (default: 50)
- `stop_loss`: Stop loss in pips (default: 50)
- `take_profit`: Take profit in pips (default: 100)


### RSI Strategy
Mean reversion strategy based on RSI indicator.


**Parameters**:
- `rsi_period`: RSI period (default: 14)
- `oversold`: Oversold threshold (default: 30)
- `overbought`: Overbought threshold (default: 70)


## Local Development


### Setup


```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
Run
-----------------------------------0-----------------------------------------
uvicorn src.main:app --reload --host 0.0.0.0 --port 8003
API Endpoints
Run Backtest
-----------------------------------...-----------------------------------------
POST /api/v1/backtest
List Strategies
-----------------------------------...-----------------------------------------
GET /api/v1/strategies
Usage Example
python
-----------------------------------...-----------------------------------------
import requests


response = requests.post('http://localhost:8003/api/v1/backtest', json={
    'backtest_id': 'your-backtest-id',
    'strategy_name': 'ema_crossover',
    'parameters': {
        'fast_period': 20,
        'slow_period': 50
    },
    'initial_cash': 10000.0
})


print(response.json())
-----------------------------------...-----------------------------------------


---
