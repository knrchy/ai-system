"""
Pydantic schemas for ML optimizer service
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID
from datetime import datetime




class MLOptimizationRequest(BaseModel):
    """Request for ML-based optimization"""
    backtest_id: UUID
    algorithm: str = Field(default="genetic", pattern="^(genetic|bayesian|ensemble)$")
    objectives: List[str] = Field(default=["net_profit", "max_drawdown"])
    parameters: List[Dict[str, Any]]
    population_size: Optional[int] = 100
    generations: Optional[int] = 50
    
    class Config:
        json_schema_extra = {
            "example": {
                "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
                "algorithm": "genetic",
                "objectives": ["net_profit", "max_drawdown"],
                "parameters": [
                    {"name": "stop_loss", "min": 20, "max": 80, "type": "int"},
                    {"name": "take_profit", "min": 40, "max": 200, "type": "int"}
                ],
                "population_size": 100,
                "generations": 50
            }
        }




class ParetoSolution(BaseModel):
    """Single solution on Pareto front"""
    rank: int
    parameters: Dict[str, float]
    objectives: Dict[str, float]
    dominated_count: int




class MLOptimizationResponse(BaseModel):
    """Response from ML optimization"""
    optimization_id: UUID
    algorithm: str
    status: str
    generations_completed: int
    pareto_front: List[ParetoSolution]
    best_solution: Dict[str, Any]
    
    class Config:
        json_schema_extra = {
            "example": {
                "optimization_id": "123e4567-e89b-12d3-a456-426614174000",
                "algorithm": "genetic",
                "status": "completed",
                "generations_completed": 50,
                "pareto_front": [
                    {
                        "rank": 1,
                        "parameters": {"stop_loss": 38, "take_profit": 95},
                        "objectives": {"net_profit": 847392, "max_drawdown": 13.2}
                    }
                ]
            }
        }




class FeatureImportanceResponse(BaseModel):
    """Feature importance analysis"""
    features: List[Dict[str, float]]
    top_features: List[str]
    model_score: float




class LSTMPredictionRequest(BaseModel):
    """Request for LSTM prediction"""
    backtest_id: UUID
    prediction_horizon: int = Field(default=30, ge=1, le=365)
    features: List[str] = ["close", "volume", "rsi", "ema"]




class LSTMPredictionResponse(BaseModel):
    """LSTM prediction response"""
    predictions: List[float]
    confidence_intervals: List[Dict[str, float]]
    model_accuracy: float
