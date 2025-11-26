"""
Configuration for API Gateway
"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI API Gateway"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Services
    DATA_PIPELINE_URL: str = "http://data-pipeline.trading-system.svc.cluster.local:8000"
    RAG_ENGINE_URL: str = "http://rag-engine.trading-system.svc.cluster.local:8001"
    OPTIMIZER_URL: str = "http://optimizer-api.trading-system.svc.cluster.local:8002"
    BACKTESTING_URL: str = "http://backtesting.trading-system.svc.cluster.local:8003"
    ML_OPTIMIZER_URL: str = "http://ml-optimizer.trading-system.svc.cluster.local:8004"
    
    # Authentication
    SECRET_KEY: str = "your-secret-key-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Rate limiting
    RATE_LIMIT_PER_MINUTE: int = 60
    
    # CORS
    CORS_ORIGINS: list = ["http://localhost:3000", "http://localhost:30900"]
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8080
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
