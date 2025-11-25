"""
Optimization service
"""
from typing import List, Dict, Any
from uuid import UUID
import logging
from sqlalchemy.orm import Session


from ..models.database import OptimizationJob
from ..tasks.optimization_task import optimize_parameters
from ..celery_app import celery_app


logger = logging.getLogger(__name__)




class OptimizationService:
    """Service for managing optimizations"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def start_optimization(
        self,
        backtest_id: UUID,
        parameter_ranges: List[Dict[str, Any]],
        optimization_type: str = 'grid_search',
        max_iterations: int = None
    ) -> Dict[str, Any]:
        """
        Start a new optimization job
        
        Args:
            backtest_id: UUID of the backtest
            parameter_ranges: List of parameter ranges
            optimization_type: Type of optimization
            max_iterations: Maximum iterations (for random/genetic)
            
        Returns:
            Job information
        """
        logger.info(f"Starting optimization for backtest {backtest_id}")
        
        # Calculate total tasks
        if optimization_type == 'grid_search':
            total_tasks = self._calculate_grid_size(parameter_ranges)
        elif optimization_type == 'random_search':
            total_tasks = max_iterations or 100
        else:  # genetic
            total_tasks = max_iterations or 50
        
        # Create database record
        job = OptimizationJob(
            backtest_id=backtest_id,
            optimization_type=optimization_type,
            parameter_ranges=parameter_ranges,
            total_tasks=total_tasks,
            status='pending'
        )
        
        self.db.add(job)
        self.db.commit()
        self.db.refresh(job)
        
        # Start Celery task
        task = optimize_parameters.delay(
            str(backtest_id),
            parameter_ranges,
            optimization_type
        )
        
        # Update job with task ID
        job.celery_task_id = task.id
        job.status = 'running'
        self.db.commit()
        
        logger.info(f"Optimization job {job.id} started with {total_tasks} tasks")
        
        return {
            'optimization_id': str(job.id),
            'status': 'running',
            'total_tasks': total_tasks,
            'message': f'Optimization started with {total_tasks} parameter combinations'
        }
    
    def get_optimization_status(self, optimization_id: UUID) -> Dict[str, Any]:
        """Get status of an optimization job"""
        job = self.db.query(OptimizationJob).filter(
            OptimizationJob.id == optimization_id
        ).first()
        
        if not job:
            raise ValueError(f"Optimization {optimization_id} not found")
        
        # Get Celery task status
        if job.celery_task_id:
            task = celery_app.AsyncResult(job.celery_task_id)
            
            # Count completed tasks
            completed = 0
            failed = 0
            
            # This is simplified - in production, track individual task states
            if task.state == 'SUCCESS':
                completed = job.total_tasks
            elif task.state == 'FAILURE':
                failed = job.total_tasks
            
            progress = (completed / job.total_tasks * 100) if job.total_tasks > 0 else 0
        else:
            completed = 0
            failed = 0
            progress = 0
        
        return {
            'optimization_id': str(job.id),
            'status': job.status,
            'total_tasks': job.total_tasks,
            'completed_tasks': completed,
            'failed_tasks': failed,
            'progress_percent': round(progress, 2),
            'started_at': job.created_at,
            'completed_at': job.completed_at
        }
    
    def _calculate_grid_size(self, parameter_ranges: List[Dict[str, Any]]) -> int:
        """Calculate total combinations for grid search"""
        import numpy as np
        
        total = 1
        for param in parameter_ranges:
            n_values = len(np.arange(
                param['min_value'],
                param['max_value'] + param['step'],
                param['step']
            ))
            total *= n_values
        
        return total
