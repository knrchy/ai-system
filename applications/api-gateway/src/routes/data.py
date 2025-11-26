"""
Data pipeline routes - Proxy to data-pipeline service
"""
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
import httpx
import logging

from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/data", tags=["data"])


@router.post("/ingest")
async def ingest_data(
    json_file: UploadFile = File(...),
    name: str = Form(...),
    description: str = Form(None),
    initial_balance: float = Form(10000.0)
):
    """Upload backtest data"""
    logger.info(f"Proxying ingest request to data pipeline: {name}")
    
    try:
        async with httpx.AsyncClient(timeout=300.0) as client:
            files = {'json_file': (json_file.filename, await json_file.read(), json_file.content_type)}
            data = {
                'name': name,
                'description': description,
                'initial_balance': initial_balance
            }
            
            response = await client.post(
                f"{settings.DATA_PIPELINE_URL}/api/v1/ingest",
                files=files,
                data=data
            )
            
            return response.json()
            
    except Exception as e:
        logger.error(f"Error proxying request: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/backtests")
async def list_backtests(skip: int = 0, limit: int = 100):
    """List all backtests"""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.DATA_PIPELINE_URL}/api/v1/backtests",
            params={'skip': skip, 'limit': limit}
        )
        return response.json()


@router.get("/backtests/{backtest_id}")
async def get_backtest(backtest_id: str):
    """Get backtest details"""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.DATA_PIPELINE_URL}/api/v1/backtests/{backtest_id}"
        )
        return response.json()
