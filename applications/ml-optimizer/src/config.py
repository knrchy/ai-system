"""
Configuration for ML optimizer service
"""
from pydantic_settings import BaseSettings




class Settings(BaseSettings):
    """Application settings"""
    
    # Application
    APP_NAME: str = "Trading AI ML Optimizer"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "postgresql://trading_user:TradingAI2025!@postgres.databases.svc.cluster.local:5432/trading_db"
    
    # Genetic Algorithm
    GA_POPULATION_SIZE: int = 100
    GA_GENERATIONS: int = 50
    GA_CROSSOVER_PROB: float = 0.7
    GA_MUTATION_PROB: float = 0.2
    
    # Bayesian Optimization
    BAYES_N_INITIAL_POINTS: int = 10
    BAYES_N_ITERATIONS: int = 50
    
    # LSTM
    LSTM_EPOCHS: int = 50
    LSTM_BATCH_SIZE: int = 32
    LSTM_SEQUENCE_LENGTH: int = 60
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8004
    
    class Config:
        env_file = ".env"
        case_sensitive = True




settings = Settings()
