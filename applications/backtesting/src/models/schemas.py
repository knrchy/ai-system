"""
Pydantic schemas for backtesting service
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime, date




class BacktestRequest(BaseModel):
    """Request to run a backtest"""
    backtest_id: Optional[UUID] = None
    strategy_name: str
    parameters: Dict[str, Any] = {}
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    initial_cash: float = Field(default=10000.0, gt=0)
    commission: float = Field(default=0.001, ge=0)
    
    class Config:
        json_schema_extra = {
            "example": {
                "strategy_name": "ema_crossover",
                "parameters": {
                    "fast_period": 20,
                    "slow_period": 50
                },
                "initial_cash": 10000.0
            }
        }




class BacktestResponse(BaseModel):
    """Response from backtest execution"""
    backtest_id: UUID
    status: str
    total_trades: int
    winning_trades: int
    losing_trades: int
    win_rate: float
    net_profit: float
    gross_profit: float
    gross_loss: float
    profit_factor: Optional[float]
    sharpe_ratio: Optional[float]
    max_drawdown: float
    final_value: float
    
    class Config:
        json_schema_extra = {
            "example": {
                "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
                "status": "completed",
                "total_trades": 1234,
                "winning_trades": 845,
                "win_rate": 68.5,
                "net_profit": 45678.50
            }
        }




class StrategyInfo(BaseModel):
    """Information about available strategy"""
    name: str
    description: str
    parameters: List[Dict[str, Any]]
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "ema_crossover",
                "description": "EMA crossover strategy",
                "parameters": [
                    {"name": "fast_period", "type": "int", "default": 20},
                    {"name": "slow_period", "type": "int", "default": 50}
                ]
            }
        }
