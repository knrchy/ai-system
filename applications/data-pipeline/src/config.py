"""
Configuration management for data pipeline
"""
from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI Data Pipeline"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "postgresql://trading_user:TradingAI2025!@postgres.databases.svc.cluster.local:5432/trading_db"
    DATABASE_POOL_SIZE: int = 20
    DATABASE_MAX_OVERFLOW: int = 40
    
    # File storage
    RAW_DATA_PATH: str = "/mnt/trading-data/raw"
    PROCESSED_DATA_PATH: str = "/mnt/trading-data/processed"
    
    # Processing limits
    MAX_FILE_SIZE_MB: int = 500
    BATCH_SIZE: int = 10000
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    
    class Config:
        env_file = ".env"
        case_sensitive = True




settings = Settings()
