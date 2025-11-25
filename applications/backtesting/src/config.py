"""
Configuration for backtesting service
"""
from pydantic_settings import BaseSettings




class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI Backtesting"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "postgresql://trading_user:TradingAI2025!@postgres.databases.svc.cluster.local:5432/trading_db"
    
    # Backtesting defaults
    INITIAL_CASH: float = 10000.0
    COMMISSION: float = 0.001  # 0.1%
    SLIPPAGE: float = 0.0001   # 0.01%
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8003
    
    class Config:
        env_file = ".env"
        case_sensitive = True




settings = Settings()
