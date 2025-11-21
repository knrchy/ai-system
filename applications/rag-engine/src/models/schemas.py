"""
Pydantic schemas for RAG service
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from uuid import UUID




class QueryRequest(BaseModel):
    """RAG query request"""
    query: str = Field(..., min_length=1, description="Natural language query")
    backtest_id: Optional[UUID] = Field(None, description="Filter by backtest ID")
    top_k: int = Field(10, ge=1, le=50, description="Number of results to retrieve")
    
    class Config:
        json_schema_extra = {
            "example": {
                "query": "What days should I avoid trading?",
                "backtest_id": "123e4567-e89b-12d3-a456-426614174000",
                "top_k": 10
            }
        }




class ContextResult(BaseModel):
    """Retrieved context result"""
    content: str
    metadata: Dict[str, Any]
    distance: float




class QueryResponse(BaseModel):
    """RAG query response"""
    query: str
    answer: str
    contexts: List[ContextResult]
    model_used: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "query": "What days should I avoid trading?",
                "answer": "Based on the analysis...",
                "contexts": [],
                "model_used": "llama3.1:8b"
            }
        }




class EmbeddingRequest(BaseModel):
    """Request to generate embeddings"""
    backtest_id: UUID
    force_regenerate: bool = False




class EmbeddingResponse(BaseModel):
    """Embedding generation response"""
    backtest_id: UUID
    chunks_created: int
    status: str
    message: str
