"""
Bayesian Optimization implementation
"""
from skopt import gp_minimize
from skopt.space import Real, Integer
from skopt.utils import use_named_args
import numpy as np
from typing import List, Dict, Any, Callable
import logging


logger = logging.getLogger(__name__)




class BayesianOptimizer:
    """
    Bayesian optimization for efficient parameter search
    
    Uses Gaussian Process to model the objective function and
    intelligently select next points to evaluate
    """
    
    def __init__(
        self,
        parameters: List[Dict[str, Any]],
        objective: str,
        evaluation_function: Callable,
        n_initial_points: int = 10,
        n_iterations: int = 50
    ):
        self.parameters = parameters
        self.objective = objective
        self.evaluation_function = evaluation_function
        self.n_initial_points = n_initial_points
        self.n_iterations = n_iterations
        
        self._setup_space()
    
    def _setup_space(self):
        """Setup search space"""
        self.space = []
        self.param_names = []
        
        for param in self.parameters:
            self.param_names.append(param['name'])
            
            if param['type'] == 'int':
                self.space.append(Integer(param['min'], param['max'], name=param['name']))
            else:
                self.space.append(Real(param['min'], param['max'], name=param['name']))
    
    def optimize(self) -> Dict[str, Any]:
        """
        Run Bayesian optimization
        
        Returns:
            Dictionary with optimization results
        """
        logger.info(f"Starting Bayesian optimization: {self.n_iterations} iterations")
        
        # Define objective function
        @use_named_args(self.space)
        def objective(**params):
            # Evaluate
            results = self.evaluation_function(params)
            
            # Get objective value (negate if maximizing)
            value = results.get(self.objective, 0)
            
            # Bayesian optimization minimizes, so negate profit
            if self.objective in ['net_profit', 'profit_factor', 'sharpe_ratio']:
                value = -value
            
            return value
        
        # Run optimization
        result = gp_minimize(
            objective,
            self.space,
            n_calls=self.n_iterations,
            n_initial_points=self.n_initial_points,
            random_state=42,
            verbose=True
        )
        
        # Extract best parameters
        best_params = {
            self.param_names[i]: result.x[i]
            for i in range(len(self.param_names))
        }
        
        # Get best objective value (un-negate if needed)
        best_value = result.fun
        if self.objective in ['net_profit', 'profit_factor', 'sharpe_ratio']:
            best_value = -best_value
        
        logger.info(f"Optimization complete. Best {self.objective}: {best_value}")
        
        return {
            'best_parameters': best_params,
            'best_objective_value': best_value,
            'iterations_completed': len(result.func_vals),
            'convergence_data': result.func_vals.tolist()
        }
