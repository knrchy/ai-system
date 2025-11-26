"""
RAG routes - Proxy to RAG engine service
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import httpx
import logging

from ..config import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag", tags=["rag"])


class QueryRequest(BaseModel):
    query: str
    backtest_id: str
    top_k: int = 10


@router.post("/query")
async def query_rag(request: QueryRequest):
    """Query with natural language"""
    logger.info(f"Proxying RAG query: {request.query}")
    
    try:
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                f"{settings.RAG_ENGINE_URL}/api/v1/query",
                json=request.dict()
            )
            return response.json()
            
    except Exception as e:
        logger.error(f"Error proxying RAG query: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/embeddings/generate")
async def generate_embeddings(backtest_id: str):
    """Generate embeddings for backtest"""
    async with httpx.AsyncClient(timeout=600.0) as client:
        response = await client.post(
            f"{settings.RAG_ENGINE_URL}/api/v1/embeddings/generate",
            json={'backtest_id': backtest_id, 'force_regenerate': False}
        )
        return response.json()


@router.get("/embeddings/{backtest_id}/status")
async def get_embedding_status(backtest_id: str):
    """Get embedding status"""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{settings.RAG_ENGINE_URL}/api/v1/embeddings/{backtest_id}/status"
        )
        return response.json()
