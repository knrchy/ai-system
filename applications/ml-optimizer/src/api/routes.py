"""
FastAPI routes for ML optimizer service
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
import logging


from ..models.database import get_db
from ..models.schemas import (
    MLOptimizationRequest,
    MLOptimizationResponse,
    FeatureImportanceResponse,
    LSTMPredictionRequest,
    LSTMPredictionResponse
)
from ..services.ml_optimization_service import MLOptimizationService


logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/v1", tags=["ml-optimizer"])




@router.post("/optimize/genetic", response_model=MLOptimizationResponse)
async def run_genetic_optimization(
    request: MLOptimizationRequest,
    db: Session = Depends(get_db)
):
    """
    Run genetic algorithm optimization (NSGA-II)
    
    Multi-objective optimization that finds Pareto-optimal solutions
    
    Example:
    ```json
    {
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
    ```
    """
    logger.info(f"Genetic optimization request: {request.backtest_id}")
    
    try:
        service = MLOptimizationService(db)
        
        # Define evaluation function (placeholder)
        def evaluate(params):
            # TODO: Implement actual backtest evaluation
            return {
                'net_profit': 10000,
                'max_drawdown': 15.0
            }
        
        result = service.run_genetic_optimization(
            backtest_id=request.backtest_id,
            parameters=request.parameters,
            objectives=request.objectives,
            evaluation_function=evaluate,
            population_size=request.population_size,
            generations=request.generations
        )
        
        return MLOptimizationResponse(**result)
        
    except Exception as e:
        logger.error(f"Error in genetic optimization: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.post("/optimize/bayesian")
async def run_bayesian_optimization(
    request: MLOptimizationRequest,
    db: Session = Depends(get_db)
):
    """
    Run Bayesian optimization
    
    Efficient single-objective optimization using Gaussian Process
    """
    logger.info(f"Bayesian optimization request: {request.backtest_id}")
    
    try:
        service = MLOptimizationService(db)
        
        # Define evaluation function
        def evaluate(params):
            return {'net_profit': 10000}
        
        result = service.run_bayesian_optimization(
            backtest_id=request.backtest_id,
            parameters=request.parameters,
            objective=request.objectives[0],  # Single objective
            evaluation_function=evaluate
        )
        
        return result
        
    except Exception as e:
        logger.error(f"Error in Bayesian optimization: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/features/{backtest_id}", response_model=FeatureImportanceResponse)
async def analyze_features(
    backtest_id: UUID,
    db: Session = Depends(get_db)
):
    """
    Analyze feature importance for trading data
    
    Returns most important features for predicting profitability
 """
try:
        service = MLOptimizationService(db)
        result = service.analyze_feature_importance(backtest_id)
        
        return FeatureImportanceResponse(**result)
        
    except Exception as e:
        logger.error(f"Error analyzing features: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/predict/lstm", response_model=LSTMPredictionResponse)
async def predict_with_lstm(
    request: LSTMPredictionRequest,
    db: Session = Depends(get_db)
):
    """
    Make predictions using LSTM model
    
    Predicts future price movements based on historical patterns
    """
    logger.info(f"LSTM prediction request: {request.backtest_id}")
    
    try:
        # TODO: Implement LSTM prediction
        return LSTMPredictionResponse(
            predictions=[],
            confidence_intervals=[],
            model_accuracy=0.0
        )
        
    except Exception as e:
        logger.error(f"Error in LSTM prediction: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ml-optimizer"
    }
