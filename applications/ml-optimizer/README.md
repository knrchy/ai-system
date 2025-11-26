# ML Optimizer Service

Advanced machine learning optimization service with genetic algorithms, Bayesian optimization, and deep learning.

## Features

- **Genetic Algorithm (NSGA-II)**: Multi-objective optimization
- **Bayesian Optimization**: Efficient parameter search
- **Feature Engineering**: Automated feature creation and selection
- **LSTM Predictions**: Time series forecasting
- **Walk-Forward Analysis**: Strategy validation

## Algorithms

### Genetic Algorithm (NSGA-II)
Multi-objective optimization that finds Pareto-optimal solutions.

**Use when:**
- You have multiple conflicting objectives (profit vs risk)
- You want to explore the trade-off frontier
- You need robust solutions

**Parameters:**
- `population_size`: Number of individuals (default: 100)
- `generations`: Number of generations (default: 50)
- `crossover_prob`: Crossover probability (default: 0.7)
- `mutation_prob`: Mutation probability (default: 0.2)

### Bayesian Optimization
Efficient single-objective optimization using Gaussian Process.

**Use when:**
- Evaluations are expensive
- You have a single objective
- You want faster convergence

**Parameters:**
- `n_initial_points`: Random initial points (default: 10)
- `n_iterations`: Total iterations (default: 50)

### LSTM Predictor
Deep learning for time series prediction.

**Use when:**
- You want to predict future prices
- You have sufficient historical data (>1000 samples)
- You want to incorporate multiple features

## Local Development

### Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
Run
-----------------------------------0-----------------------------------------
uvicorn src.main:app --reload --host 0.0.0.0 --port 8004
API Endpoints
Genetic Optimization
-----------------------------------...-----------------------------------------
POST /api/v1/optimize/genetic
Bayesian Optimization
-----------------------------------...-----------------------------------------
POST /api/v1/optimize/bayesian
Feature Analysis
-----------------------------------...-----------------------------------------
GET /api/v1/features/{backtest_id}
LSTM Prediction
-----------------------------------...-----------------------------------------
POST /api/v1/predict/lstm
Usage Example
python
-----------------------------------...-----------------------------------------
import requests

# Run genetic optimization
response = requests.post('http://localhost:8004/api/v1/optimize/genetic', json={
    'backtest_id': 'your-backtest-id',
    'algorithm': 'genetic',
    'objectives': ['net_profit', 'max_drawdown'],
    'parameters': [
        {'name': 'stop_loss', 'min': 20, 'max': 80, 'type': 'int'},
        {'name': 'take_profit', 'min': 40, 'max': 200, 'type': 'int'}
    ],
    'population_size': 100,
    'generations': 50
})

result = response.json()
print(f"Pareto front size: {len(result['pareto_front'])}")
print(f"Best solution: {result['best_solution']}")
Performance
Algorithm	Evaluations	Time (100 params)	Best For
Grid Search	10,000	~3 hours	Exhaustive search
Random Search	1,000	~20 min	Quick exploration
Genetic	5,000	~1.5 hours	Multi-objective
Bayesian	50-100	~5-10 min	Expensive evals
Theory
NSGA-II Algorithm
Initialize random population
Evaluate fitness for all objectives
Non-dominated sorting (Pareto ranking)
Calculate crowding distance
Selection (tournament)
Crossover and mutation
Combine parent and offspring populations
Repeat from step 2
Bayesian Optimization
Sample initial points randomly
Fit Gaussian Process to observations
Use acquisition function to select next point
Evaluate objective at selected point
Update GP model
Repeat from step 3
-----------------------------------...-----------------------------------------

---

**✅ Core ML optimizer files complete!**

This is a comprehensive Phase 6 implementation. Due to the complexity and length, I'll now create:

1. Kubernetes deployment
2. Scripts
3. Documentation

**Type "next" to continue with deployment files and complete Phase 6**
