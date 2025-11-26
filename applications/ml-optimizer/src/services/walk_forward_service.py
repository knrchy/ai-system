"""
Walk-forward analysis service
"""
import pandas as pd
from typing import Dict, Any, List, Tuple
from datetime import datetime, timedelta
import logging


logger = logging.getLogger(__name__)




class WalkForwardService:
    """
    Walk-forward analysis for strategy validation
    
    Splits data into training and testing windows, optimizes on training,
    tests on out-of-sample data, then rolls forward
    """
    
    def __init__(self):
        self.results = []
    
    def run_walk_forward(
        self,
        data: pd.DataFrame,
        optimization_function,
        backtest_function,
        train_period_days: int = 365,
        test_period_days: int = 90,
        step_days: int = 90
    ) -> Dict[str, Any]:
        """
        Run walk-forward analysis
        
        Args:
            data: Historical data
            optimization_function: Function to optimize parameters
            backtest_function: Function to backtest with parameters
            train_period_days: Training period in days
            test_period_days: Testing period in days
            step_days: Step size in days
            
        Returns:
            Walk-forward results
        """
        logger.info(f"Starting walk-forward analysis")
        logger.info(f"Train: {train_period_days} days, Test: {test_period_days} days, Step: {step_days} days")
        
        results = []
        
        # Get date range
        start_date = data.index.min()
        end_date = data.index.max()
        
        current_date = start_date + timedelta(days=train_period_days)
        
        iteration = 0
        while current_date + timedelta(days=test_period_days) <= end_date:
            iteration += 1
            
            # Define windows
            train_start = current_date - timedelta(days=train_period_days)
            train_end = current_date
            test_start = current_date
            test_end = current_date + timedelta(days=test_period_days)
            
            logger.info(f"Iteration {iteration}: Train {train_start.date()} to {train_end.date()}, Test {test_start.date()} to {test_end.date()}")
            
            # Split data
            train_data = data[(data.index >= train_start) & (data.index < train_end)]
            test_data = data[(data.index >= test_start) & (data.index < test_end)]
            
            # Optimize on training data
            optimal_params = optimization_function(train_data)
            
            # Test on out-of-sample data
            test_results = backtest_function(test_data, optimal_params)
            
            results.append({
                'iteration': iteration,
                'train_start': train_start,
                'train_end': train_end,
                'test_start': test_start,
                'test_end': test_end,
                'optimal_parameters': optimal_params,
                'test_performance': test_results
            })
            
            # Move forward
            current_date += timedelta(days=step_days)
        
        # Aggregate results
        total_profit = sum(r['test_performance'].get('net_profit', 0) for r in results)
        avg_profit = total_profit / len(results) if results else 0
        
        logger.info(f"Walk-forward complete: {len(results)} iterations, Total profit: {total_profit}")
        
        return {
            'iterations': results,
            'total_iterations': len(results),
            'total_profit': total_profit,
            'average_profit': avg_profit,
            'consistency': self._calculate_consistency(results)
        }
    
    def _calculate_consistency(self, results: List[Dict[str, Any]]) -> float:
        """
        Calculate consistency score (% of profitable periods)
        
        Args:
            results: List of walk-forward results
            
        Returns:
            Consistency score (0-1)
        """
        if not results:
            return 0.0
        
        profitable = sum(
            1 for r in results
            if r['test_performance'].get('net_profit', 0) > 0
        )
        
        return profitable / len(results)
