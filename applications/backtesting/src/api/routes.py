"""
FastAPI routes for backtesting service
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
import logging


from ..models.database import get_db
from ..models.schemas import (
    BacktestRequest,
    BacktestResponse,
    StrategyInfo
)
from ..services.backtest_service import BacktestService


logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/v1", tags=["backtesting"])




@router.post("/backtest", response_model=BacktestResponse)
async def run_backtest(
    request: BacktestRequest,
    db: Session = Depends(get_db)
):
    """
    Run a backtest with specified strategy
    
    Example:
    ```json
    {
      "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
      "strategy_name": "ema_crossover",
      "parameters": {
        "fast_period": 20,
        "slow_period": 50
      },
      "initial_cash": 10000.0
    }
    ```
    """
    logger.info(f"Backtest request: {request.strategy_name}")
    
    try:
        service = BacktestService(db)
        result = service.run_backtest(
            backtest_id=request.backtest_id,
            strategy_name=request.strategy_name,
            parameters=request.parameters,
            start_date=request.start_date,
            end_date=request.end_date,
            initial_cash=request.initial_cash,
            commission=request.commission
        )
        
        return BacktestResponse(**result)
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Error running backtest: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/strategies", response_model=list[StrategyInfo])
async def list_strategies(db: Session = Depends(get_db)):
    """List available strategies"""
    service = BacktestService(db)
    strategies = service.list_strategies()
    return strategies




@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "backtesting"
    }
