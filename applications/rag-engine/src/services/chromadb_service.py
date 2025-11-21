"""
ChromaDB service for vector storage and retrieval
"""
import chromadb
from chromadb.config import Settings as ChromaSettings
from typing import List, Dict, Any, Optional
from uuid import UUID
import logging


from ..config import settings


logger = logging.getLogger(__name__)




class ChromaDBService:
    """Service for managing ChromaDB collections"""
    
    def __init__(self):
        logger.info(f"Connecting to ChromaDB at {settings.CHROMADB_HOST}:{settings.CHROMADB_PORT}")
        
        self.client = chromadb.HttpClient(
            host=settings.CHROMADB_HOST,
            port=settings.CHROMADB_PORT,
            settings=ChromaSettings(
                anonymized_telemetry=False
            )
        )
        
        logger.info("ChromaDB client initialized")
    
    def get_or_create_collection(self, backtest_id: UUID) -> chromadb.Collection:
        """Get or create a collection for a backtest"""
        collection_name = f"backtest_{str(backtest_id).replace('-', '_')}"
        
        try:
            collection = self.client.get_collection(name=collection_name)
            logger.info(f"Retrieved existing collection: {collection_name}")
        except:
            collection = self.client.create_collection(
                name=collection_name,
                metadata={
                    "backtest_id": str(backtest_id),
                    "description": "Trading data embeddings"
                }
            )
            logger.info(f"Created new collection: {collection_name}")
        
        return collection
    
    def add_embeddings(
        self,
        backtest_id: UUID,
        embeddings: List[List[float]],
        documents: List[str],
        metadatas: List[Dict[str, Any]],
        ids: List[str]
    ) -> int:
        """Add embeddings to collection"""
        collection = self.get_or_create_collection(backtest_id)
        
        logger.info(f"Adding {len(embeddings)} embeddings to collection")
        
        # ChromaDB expects specific format
        collection.add(
            embeddings=embeddings,
            documents=documents,
            metadatas=metadatas,
            ids=ids
        )
        
        logger.info(f"Successfully added {len(embeddings)} embeddings")
        return len(embeddings)
    
    def query(
        self,
        backtest_id: UUID,
        query_embedding: List[float],
        top_k: int = 10,
        where: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Query collection for similar embeddings"""
        collection = self.get_or_create_collection(backtest_id)
        
        logger.info(f"Querying collection for top {top_k} results")
        
        results = collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k,
            where=where
        )
        
        return results
    
    def delete_collection(self, backtest_id: UUID) -> bool:
        """Delete a collection"""
        collection_name = f"backtest_{str(backtest_id).replace('-', '_')}"
        
        try:
            self.client.delete_collection(name=collection_name)
            logger.info(f"Deleted collection: {collection_name}")
            return True
        except Exception as e:
            logger.error(f"Error deleting collection: {e}")
            return False
    
    def collection_exists(self, backtest_id: UUID) -> bool:
        """Check if collection exists"""
        collection_name = f"backtest_{str(backtest_id).replace('-', '_')}"
        
        try:
            self.client.get_collection(name=collection_name)
            return True
        except:
            return False
    
    def get_collection_count(self, backtest_id: UUID) -> int:
        """Get number of items in collection"""
        try:
            collection = self.get_or_create_collection(backtest_id)
            return collection.count()
        except:
            return 0
