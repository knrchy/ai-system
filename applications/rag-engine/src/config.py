"""
Configuration for RAG service
"""
from pydantic_settings import BaseSettings




class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI RAG Engine"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "postgresql://trading_user:TradingAI2025!@postgres.databases.svc.cluster.local:5432/trading_db"
    
    # ChromaDB
    CHROMADB_HOST: str = "chromadb.databases.svc.cluster.local"
    CHROMADB_PORT: int = 8000
    
    # Ollama
    OLLAMA_HOST: str = "ollama.trading-system.svc.cluster.local"
    OLLAMA_PORT: int = 11434
    OLLAMA_MODEL: str = "llama3.1:8b"
    
    # Embeddings
    EMBEDDING_MODEL: str = "sentence-transformers/all-MiniLM-L6-v2"
    EMBEDDING_DIMENSION: int = 384
    
    # RAG settings
    CHUNK_SIZE: int = 500
    CHUNK_OVERLAP: int = 50
    TOP_K_RESULTS: int = 10
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8001
    
    class Config:
        env_file = ".env"
        case_sensitive = True




settings = Settings()
