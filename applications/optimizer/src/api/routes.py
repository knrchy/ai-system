"""
FastAPI routes for optimizer service
"""
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from sqlalchemy.orm import Session
from uuid import UUID
import logging


from ..models.database import get_db
from ..models.schemas import (
    OptimizationRequest,
    OptimizationResponse,
    OptimizationStatus,
    OptimizationResult
)
from ..services.optimization_service import OptimizationService
from ..services.result_service import ResultService


logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/v1", tags=["optimizer"])




@router.post("/optimize", response_model=OptimizationResponse)
async def start_optimization(
    request: OptimizationRequest,
    db: Session = Depends(get_db)
):
    """
    Start parameter optimization
    
    This will run multiple backtests with different parameter combinations
    and return the best performing parameters.
    
    Example:
    ```json
    {
      "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
      "parameters": [
        {"name": "stop_loss", "min_value": 20, "max_value": 80, "step": 2}
      ],
      "optimization_type": "grid_search"
    }
    ```
    """
    logger.info(f"Starting optimization for backtest: {request.backtest_id}")
    
    try:
        service = OptimizationService(db)
        result = service.start_optimization(
            backtest_id=request.backtest_id,
            parameter_ranges=[p.dict() for p in request.parameters],
            optimization_type=request.optimization_type,
            max_iterations=request.max_iterations
        )
        
        return OptimizationResponse(**result)
        
    except Exception as e:
        logger.error(f"Error starting optimization: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/optimize/{optimization_id}/status", response_model=OptimizationStatus)
async def get_optimization_status(
    optimization_id: UUID,
    db: Session = Depends(get_db)
):
    """Get status of an optimization job"""
    try:
        service = OptimizationService(db)
        status = service.get_optimization_status(optimization_id)
        
        return OptimizationStatus(**status)
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error getting status: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/optimize/{optimization_id}/results")
async def get_optimization_results(
    optimization_id: UUID,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """
    Get optimization results
    
    Returns the top performing parameter combinations
    """
    try:
        service = ResultService()
        results = service.get_optimization_results(optimization_id, limit)
        
        return {
            'optimization_id': str(optimization_id),
            'total_results': len(results),
            'results': results
        }
        
    except Exception as e:
        logger.error(f"Error getting results: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/workers/status")
async def get_worker_status():
    """Get status of Celery workers"""
    from ..celery_app import celery_app
    
    try:
        # Get active workers
        inspect = celery_app.control.inspect()
        
        active = inspect.active()
        stats = inspect.stats()
        
        workers = []
        if stats:
            for worker_name, worker_stats in stats.items():
                workers.append({
                    'name': worker_name,
                    'status': 'online',
                    'pool': worker_stats.get('pool', {}),
                    'active_tasks': len(active.get(worker_name, [])) if active else 0
                })
        
        return {
            'total_workers': len(workers),
            'workers': workers
        }
        
    except Exception as e:
        logger.error(f"Error getting worker status: {e}")
        return {
            'total_workers': 0,
            'workers': [],
            'error': str(e)
        }




@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "optimizer"
    }
