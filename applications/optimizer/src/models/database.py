"""
Database models for optimizer service
"""
from sqlalchemy import create_engine, Column, String, Integer, DECIMAL, TIMESTAMP, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import uuid


from ..config import settings


# Create engine
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True
)


# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Base class
Base = declarative_base()




class OptimizationJob(Base):
    """Optimization job tracking"""
    __tablename__ = "optimization_jobs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    optimization_type = Column(String(50), nullable=False)  # grid_search, random_search, genetic
    parameter_ranges = Column(JSONB)
    
    total_tasks = Column(Integer)
    completed_tasks = Column(Integer, default=0)
    failed_tasks = Column(Integer, default=0)
    
    status = Column(String(50), default='pending')  # pending, running, completed, failed
    celery_task_id = Column(String(255))
    
    created_at = Column(TIMESTAMP, default=datetime.utcnow)
    started_at = Column(TIMESTAMP)
    completed_at = Column(TIMESTAMP)




class OptimizationResult(Base):
    """Individual optimization result"""
    __tablename__ = "optimization_results"
    
    id = Column(Integer, primary_key=True)
    optimization_id = Column(UUID(as_uuid=True), nullable=False)
    
    parameters = Column(JSONB, nullable=False)
    
    # Key metrics
    net_profit = Column(DECIMAL(18, 2))
    win_rate = Column(DECIMAL(5, 2))
    profit_factor = Column(DECIMAL(10, 4))
    sharpe_ratio = Column(DECIMAL(10, 4))
    max_drawdown = Column(DECIMAL(18, 2))
    
    # Full metrics
    metrics = Column(JSONB)
    
    rank = Column(Integer)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)




class Trade(Base):
    """Trade model (read-only)"""
    __tablename__ = "trades"
    
    id = Column(Integer, primary_key=True)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    open_time = Column(TIMESTAMP)
    close_time = Column(TIMESTAMP)
    symbol = Column(String(20))
    direction = Column(String(10))
    profit = Column(DECIMAL(18, 8))




# Database dependency
def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()




# Create tables
def init_db():
    """Initialize database tables"""
    Base.metadata.create_all(bind=engine)
