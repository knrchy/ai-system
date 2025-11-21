"""
FastAPI routes for RAG service
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from uuid import UUID
import logging


from ..models.database import get_db
from ..models.schemas import (
    QueryRequest,
    QueryResponse,
    EmbeddingRequest,
    EmbeddingResponse
)
from ..services.rag_service import RAGService


logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/v1", tags=["rag"])




@router.post("/embeddings/generate", response_model=EmbeddingResponse)
async def generate_embeddings(
    request: EmbeddingRequest,
    db: Session = Depends(get_db)
):
    """
    Generate embeddings for a backtest
    
    This creates vector embeddings from trade data and stores them in ChromaDB
    """
    logger.info(f"Generating embeddings for backtest: {request.backtest_id}")
    
    try:
        service = RAGService(db)
        result = await service.generate_embeddings_for_backtest(
            backtest_id=request.backtest_id,
            force_regenerate=request.force_regenerate
        )
        
        return EmbeddingResponse(
            backtest_id=request.backtest_id,
            **result
        )
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error generating embeddings: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.post("/query", response_model=QueryResponse)
async def query_rag(
    request: QueryRequest,
    db: Session = Depends(get_db)
):
    """
    Query trading data using natural language
    
    Example queries:
    - "What days should I avoid trading?"
    - "Show me the best performing symbols"
    - "When did I have the biggest drawdowns?"
    """
    logger.info(f"Processing RAG query: {request.query}")
    
    if not request.backtest_id:
        raise HTTPException(
            status_code=400,
            detail="backtest_id is required"
        )
    
    try:
        service = RAGService(db)
        result = await service.query(
            query=request.query,
            backtest_id=request.backtest_id,
            top_k=request.top_k
        )
        
        return QueryResponse(**result)
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        logger.error(f"Error processing query: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/embeddings/{backtest_id}/status")
async def get_embedding_status(
    backtest_id: UUID,
    db: Session = Depends(get_db)
):
    """Get embedding status for a backtest"""
    service = RAGService(db)
    
    exists = service.chromadb_service.collection_exists(backtest_id)
    
    if not exists:
        return {
            'backtest_id': str(backtest_id),
            'exists': False,
            'count': 0,
            'status': 'not_created'
        }
    
    count = service.chromadb_service.get_collection_count(backtest_id)
    
    return {
        'backtest_id': str(backtest_id),
        'exists': True,
        'count': count,
        'status': 'ready'
    }




@router.delete("/embeddings/{backtest_id}")
async def delete_embeddings(
    backtest_id: UUID,
    db: Session = Depends(get_db)
):
    """Delete embeddings for a backtest"""
    service = RAGService(db)
    
    success = service.chromadb_service.delete_collection(backtest_id)
    
    if not success:
        raise HTTPException(
            status_code=404,
            detail="Collection not found or could not be deleted"
        )
    
    return {
        'backtest_id': str(backtest_id),
        'status': 'deleted',
        'message': 'Embeddings deleted successfully'
    }




@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "rag-engine"
    }

