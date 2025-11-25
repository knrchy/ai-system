"""
Celery task for optimization orchestration
"""
from celery import group, chord
from typing import List, Dict, Any
import logging
from uuid import UUID, uuid4


from ..celery_app import celery_app
from .backtest_task import run_backtest


logger = logging.getLogger(__name__)




@celery_app.task(name='tasks.optimize_parameters')
def optimize_parameters(
    backtest_id: str,
    parameter_ranges: List[Dict[str, Any]],
    optimization_type: str = 'grid_search'
) -> str:
    """
    Orchestrate parameter optimization
    
    Args:
        backtest_id: UUID of the backtest
        parameter_ranges: List of parameter ranges to optimize
        optimization_type: Type of optimization (grid_search, random_search, genetic)
        
    Returns:
        Optimization job ID
    """
    logger.info(f"Starting optimization for backtest {backtest_id}")
    
    optimization_id = str(uuid4())
    
    # Generate parameter combinations
    combinations = _generate_combinations(parameter_ranges, optimization_type)
    
    logger.info(f"Generated {len(combinations)} parameter combinations")
    
    # Create tasks for each combination
    tasks = group(
        run_backtest.s(backtest_id, params)
        for params in combinations
    )
    
    # Execute tasks and aggregate results
    callback = aggregate_results.s(optimization_id)
    
    chord(tasks)(callback)
    
    return optimization_id




@celery_app.task(name='tasks.aggregate_results')
def aggregate_results(results: List[Dict[str, Any]], optimization_id: str) -> Dict[str, Any]:
    """
    Aggregate and rank optimization results
    
    Args:
        results: List of backtest results
        optimization_id: ID of the optimization job
        
    Returns:
        Aggregated results with rankings
    """
    logger.info(f"Aggregating {len(results)} results for optimization {optimization_id}")
    
    # Filter out failed tasks
    valid_results = [r for r in results if r is not None]
    
    if not valid_results:
        logger.error("No valid results to aggregate")
        return {'error': 'No valid results'}
    
    # Sort by net profit (can be customized)
    sorted_results = sorted(
        valid_results,
        key=lambda x: x.get('net_profit', 0),
        reverse=True
    )
    
    # Add rankings
    for i, result in enumerate(sorted_results):
        result['rank'] = i + 1
    
    # Store results in database
    from ..services.result_service import ResultService
    service = ResultService()
    service.save_optimization_results(optimization_id, sorted_results)
    
    logger.info(f"Optimization {optimization_id} completed. Best result: {sorted_results[0]}")
    
    return {
        'optimization_id': optimization_id,
        'total_results': len(sorted_results),
        'best_result': sorted_results[0],
        'top_5': sorted_results[:5]
    }




def _generate_combinations(
    parameter_ranges: List[Dict[str, Any]],
    optimization_type: str
) -> List[Dict[str, float]]:
    """
    Generate parameter combinations based on optimization type
    
    Args:
        parameter_ranges: List of parameter ranges
        optimization_type: Type of optimization
        
    Returns:
        List of parameter combinations
    """
    if optimization_type == 'grid_search':
        return _grid_search_combinations(parameter_ranges)
    elif optimization_type == 'random_search':
        return _random_search_combinations(parameter_ranges)
    elif optimization_type == 'genetic':
        return _genetic_combinations(parameter_ranges)
    else:
        raise ValueError(f"Unknown optimization type: {optimization_type}")




def _grid_search_combinations(parameter_ranges: List[Dict[str, Any]]) -> List[Dict[str, float]]:
    """Generate all combinations for grid search"""
    import itertools
    import numpy as np
    
    # Generate ranges for each parameter
    param_values = {}
    for param in parameter_ranges:
        values = np.arange(
            param['min_value'],
            param['max_value'] + param['step'],
            param['step']
        )
        param_values[param['name']] = values.tolist()
    
    # Generate all combinations
    keys = list(param_values.keys())
    values = list(param_values.values())
    
    combinations = []
    for combo in itertools.product(*values):
        combinations.append(dict(zip(keys, combo)))
    
    return combinations




def _random_search_combinations(
    parameter_ranges: List[Dict[str, Any]],
    n_samples: int = 100
) -> List[Dict[str, float]]:
    """Generate random combinations"""
    import random
    
    combinations = []
    for _ in range(n_samples):
        combo = {}
        for param in parameter_ranges:
            value = random.uniform(param['min_value'], param['max_value'])
            # Round to step
            value = round(value / param['step']) * param['step']
            combo[param['name']] = value
        combinations.append(combo)
    
    return combinations




def _genetic_combinations(
    parameter_ranges: List[Dict[str, Any]],
    population_size: int = 50
) -> List[Dict[str, float]]:
    """Generate initial population for genetic algorithm"""
    import random
    
    combinations = []
    for _ in range(population_size):
        combo = {}
        for param in parameter_ranges:
            value = random.uniform(param['min_value'], param['max_value'])
            value = round(value / param['step']) * param['step']
            combo[param['name']] = value
        combinations.append(combo)
    
    return combinations
