"""
Optimizer routes - Proxy to optimizer services
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any
import httpx
import logging

from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/optimize", tags=["optimization"])


class OptimizeRequest(BaseModel):
    backtest_id: str
    parameters: List[Dict[str, Any]]
    optimization_type: str = "grid_search"


@router.post("/start")
async def start_optimization(request: OptimizeRequest):
    """Start parameter optimization"""
    logger.info(f"Starting optimization: {request.optimization_type}")
    
    try:
        async with httpx.AsyncClient(timeout=300.0) as client:
            response = await client.post(
                f"{settings.OPTIMIZER_URL}/api/v1/optimize",
                json=request.dict()
            )
            return response.json()
            
    except Exception as e:
        logger.error(f"Error starting optimization: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status/{optimization_id}")
async def get_optimization_status(optimization_id: str):
    """Get optimization status"""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.OPTIMIZER_URL}/api/v1/optimize/{optimization_id}/status"
        )
        return response.json()


@router.get("/results/{optimization_id}")
async def get_optimization_results(optimization_id: str, limit: int = 100):
    """Get optimization results"""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.OPTIMIZER_URL}/api/v1/optimize/{optimization_id}/results",
            params={'limit': limit}
        )
        return response.json()


@router.post("/genetic")
async def run_genetic_optimization(request: dict):
    """Run genetic algorithm optimization"""
    async with httpx.AsyncClient(timeout=7200.0) as client:
        response = await client.post(
            f"{settings.ML_OPTIMIZER_URL}/api/v1/optimize/genetic",
            json=request
        )
        return response.json()
