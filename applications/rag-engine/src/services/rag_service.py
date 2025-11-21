"""
RAG (Retrieval Augmented Generation) service
"""
from typing import List, Dict, Any, Optional
from uuid import UUID
import logging
import httpx
from sqlalchemy.orm import Session


from ..config import settings
from .embedding_service import EmbeddingService
from .chromadb_service import ChromaDBService


logger = logging.getLogger(__name__)




class RAGService:
    """Service for RAG query processing"""
    
    def __init__(self, db: Session):
        self.db = db
        self.embedding_service = EmbeddingService()
        self.chromadb_service = ChromaDBService()
    
    async def generate_embeddings_for_backtest(
        self,
        backtest_id: UUID,
        force_regenerate: bool = False
    ) -> Dict[str, Any]:
        """Generate and store embeddings for a backtest"""
        
        # Check if embeddings already exist
        if not force_regenerate and self.chromadb_service.collection_exists(backtest_id):
            count = self.chromadb_service.get_collection_count(backtest_id)
            logger.info(f"Embeddings already exist for backtest {backtest_id}: {count} chunks")
            return {
                'status': 'exists',
                'chunks_created': count,
                'message': 'Embeddings already exist'
            }
        
        # Fetch trades from database
        logger.info(f"Fetching trades for backtest {backtest_id}")
        from ..models.database import Trade
        
        trades = self.db.query(Trade).filter(
            Trade.backtest_id == backtest_id
        ).all()
        
        if not trades:
            raise ValueError(f"No trades found for backtest {backtest_id}")
        
        logger.info(f"Found {len(trades)} trades")
        
        # Convert to dictionaries
        trade_dicts = [
            {
                'open_time': t.open_time,
                'close_time': t.close_time,
                'symbol': t.symbol,
                'direction': t.direction,
                'profit': float(t.profit) if t.profit else 0,
                'pips': float(t.pips) if t.pips else 0,
                'entry_price': float(t.entry_price) if t.entry_price else 0,
                'exit_price': float(t.exit_price) if t.exit_price else 0,
            }
            for t in trades
        ]
        
        # Create chunks
        chunks = self.embedding_service.create_trade_chunks(trade_dicts)
        
        # Generate embeddings
        texts = [chunk['text'] for chunk in chunks]
        embeddings = self.embedding_service.generate_embeddings_batch(texts)
        
        # Prepare data for ChromaDB
        ids = [f"{backtest_id}_{i}" for i in range(len(chunks))]
        metadatas = [
            {**chunk['metadata'], 'backtest_id': str(backtest_id)}
            for chunk in chunks
        ]
        
        # Store in ChromaDB
        count = self.chromadb_service.add_embeddings(
            backtest_id=backtest_id,
            embeddings=embeddings,
            documents=texts,
            metadatas=metadatas,
            ids=ids
        )
        
        return {
            'status': 'created',
            'chunks_created': count,
            'message': f'Successfully created {count} embeddings'
        }
    
    async def query(
        self,
        query: str,
        backtest_id: Optional[UUID] = None,
        top_k: int = 10
    ) -> Dict[str, Any]:
        """Process RAG query"""
        
        logger.info(f"Processing query: {query}")
        
        # Generate query embedding
        query_embedding = self.embedding_service.generate_embedding(query)
        
        # Search ChromaDB
        if backtest_id:
            results = self.chromadb_service.query(
                backtest_id=backtest_id,
                query_embedding=query_embedding,
                top_k=top_k
            )
        else:
            # If no backtest_id, need to search all collections
            # For now, raise error - implement multi-collection search later
            raise ValueError("backtest_id is required")
        
        # Extract contexts
        contexts = []
        if results['documents'] and len(results['documents']) > 0:
            for i, doc in enumerate(results['documents'][0]):
                contexts.append({
                    'content': doc,
                    'metadata': results['metadatas'][0][i] if results['metadatas'] else {},
                    'distance': results['distances'][0][i] if results['distances'] else 0
                })
        
        # Generate answer using LLM
        answer = await self._generate_answer(query, contexts)
        
        return {
            'query': query,
            'answer': answer,
            'contexts': contexts,
            'model_used': settings.OLLAMA_MODEL
        }
    
    async def _generate_answer(
        self,
        query: str,
        contexts: List[Dict[str, Any]]
    ) -> str:
        """Generate answer using Ollama LLM"""
        
        # Build prompt with context
        context_text = "\n\n".join([
            f"Context {i+1}:\n{ctx['content']}"
            for i, ctx in enumerate(contexts[:5])  # Use top 5 contexts
        ])
        
        prompt = f"""You are a trading analysis assistant. Answer the following question based on the provided trading data contexts.


Question: {query}


Trading Data Contexts:
{context_text}


Please provide a detailed, data-driven answer based on the contexts above. Include specific numbers and dates when available.


Answer:"""
        
        # Call Ollama API
        ollama_url = f"http://{settings.OLLAMA_HOST}:{settings.OLLAMA_PORT}/api/generate"
        
        logger.info(f"Calling Ollama at {ollama_url}")
        
        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                ollama_url,
                json={
                    "model": settings.OLLAMA_MODEL,
                    "prompt": prompt,
                    "stream": False
                }
            )
            
            if response.status_code != 200:
                logger.error(f"Ollama API error: {response.status_code}")
                return "Error generating answer from LLM"
            
            result = response.json()
            answer = result.get('response', 'No answer generated')
        
        logger.info("Answer generated successfully")
        return answer
