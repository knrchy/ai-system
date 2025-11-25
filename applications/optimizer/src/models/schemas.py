"""
Pydantic schemas for optimizer service
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime




class ParameterRange(BaseModel):
    """Parameter range for optimization"""
    name: str
    min_value: float
    max_value: float
    step: float
    
    class Config:
        json_schema_extra = {
            "example": {
                "name": "stop_loss",
                "min_value": 20,
                "max_value": 80,
                "step": 2
            }
        }




class OptimizationRequest(BaseModel):
    """Request to start optimization"""
    backtest_id: UUID
    parameters: List[ParameterRange]
    optimization_type: str = Field(default="grid_search", pattern="^(grid_search|random_search|genetic)$")
    max_iterations: Optional[int] = Field(default=None, ge=1)
    
    class Config:
        json_schema_extra = {
            "example": {
                "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
                "parameters": [
                    {"name": "stop_loss", "min_value": 20, "max_value": 80, "step": 2}
                ],
                "optimization_type": "grid_search"
            }
        }




class OptimizationResponse(BaseModel):
    """Response from optimization request"""
    optimization_id: UUID
    status: str
    total_tasks: int
    message: str




class TaskStatus(BaseModel):
    """Status of a single task"""
    task_id: str
    status: str
    progress: Optional[float]
    result: Optional[Dict[str, Any]]
    error: Optional[str]




class OptimizationStatus(BaseModel):
    """Status of optimization job"""
    optimization_id: UUID
    status: str
    total_tasks: int
    completed_tasks: int
    failed_tasks: int
    progress_percent: float
    best_result: Optional[Dict[str, Any]]
    started_at: Optional[datetime]
    completed_at: Optional[datetime]




class OptimizationResult(BaseModel):
    """Single optimization result"""
    parameters: Dict[str, float]
    metrics: Dict[str, float]
    rank: Optional[int]
