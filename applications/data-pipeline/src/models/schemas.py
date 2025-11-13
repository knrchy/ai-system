"""
Pydantic schemas for request/response validation
"""
from pydantic import BaseModel, Field, validator
from typing import Optional, Dict, Any, List
from datetime import datetime
from uuid import UUID
from decimal import Decimal




class BacktestCreate(BaseModel):
    """Schema for creating a backtest"""
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    initial_balance: Decimal = Field(..., gt=0)
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "EMA Crossover Strategy 2024",
                "description": "10-year backtest with EMA 20/50 crossover",
                "initial_balance": 10000.00
            }
        }




class BacktestResponse(BaseModel):
    """Schema for backtest response"""
    id: UUID
    name: str
    description: Optional[str]
    start_date: Optional[datetime]
    end_date: Optional[datetime]
    initial_balance: Decimal
    final_balance: Optional[Decimal]
    net_profit: Optional[Decimal]
    total_trades: int
    winning_trades: int
    losing_trades: int
    win_rate: Optional[Decimal]
    status: str
    created_at: datetime
    
    class Config:
        from_attributes = True




class TradeCreate(BaseModel):
    """Schema for creating a trade"""
    backtest_id: UUID
    open_time: datetime
    close_time: Optional[datetime]
    symbol: str
    direction: str
    entry_price: Decimal
    exit_price: Optional[Decimal]
    volume: Decimal
    profit: Optional[Decimal]
    
    @validator('direction')
    def validate_direction(cls, v):
        if v not in ['BUY', 'SELL']:
            raise ValueError('Direction must be BUY or SELL')
        return v




class IngestionRequest(BaseModel):
    """Schema for data ingestion request"""
    name: str
    description: Optional[str] = None
    initial_balance: Decimal = Field(default=10000.00, gt=0)
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "10yr_backtest_v1",
                "description": "Full 10-year backtest",
                "initial_balance": 10000.00
            }
        }




class IngestionResponse(BaseModel):
    """Schema for ingestion response"""
    job_id: UUID
    backtest_id: UUID
    status: str
    message: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "job_id": "123e4567-e89b-12d3-a456-426614174000",
                "backtest_id": "123e4567-e89b-12d3-a456-426614174001",
                "status": "processing",
                "message": "Data ingestion started"
            }
        }




class JobStatus(BaseModel):
    """Schema for job status"""
    id: UUID
    status: str
    job_type: str
    records_total: Optional[int]
    records_processed: Optional[int]
    records_failed: Optional[int]
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    error_message: Optional[str]
    
    class Config:
        from_attributes = True
