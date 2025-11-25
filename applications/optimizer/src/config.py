"""
Configuration for optimizer service
"""
from pydantic_settings import BaseSettings




class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI Optimizer"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "postgresql://trading_user:TradingAI2025!@postgres.databases.svc.cluster.local:5432/trading_db"
    
    # Redis
    REDIS_HOST: str = "redis.databases.svc.cluster.local"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    
    # Celery
    CELERY_BROKER_URL: str = "redis://redis.databases.svc.cluster.local:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://redis.databases.svc.cluster.local:6379/0"
    CELERY_TASK_SERIALIZER: str = "json"
    CELERY_RESULT_SERIALIZER: str = "json"
    CELERY_ACCEPT_CONTENT: list = ["json"]
    CELERY_TIMEZONE: str = "UTC"
    CELERY_ENABLE_UTC: bool = True
    
    # Worker settings
    WORKER_CONCURRENCY: int = 4
    WORKER_PREFETCH_MULTIPLIER: int = 1
    
    # Optimization
    MAX_PARALLEL_TASKS: int = 100
    TASK_TIMEOUT: int = 3600  # 1 hour
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8002
    
    class Config:
        env_file = ".env"
        case_sensitive = True




settings = Settings()
