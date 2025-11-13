"""
SQLAlchemy database models
"""
from sqlalchemy import create_engine, Column, String, Integer, BigInteger, DECIMAL, TIMESTAMP, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import uuid


from ..config import settings


# Create engine
engine = create_engine(
    settings.DATABASE_URL,
    pool_size=settings.DATABASE_POOL_SIZE,
    max_overflow=settings.DATABASE_MAX_OVERFLOW,
    pool_pre_ping=True
)


# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class
Base = declarative_base()

class Backtest(Base):
    """Backtest model"""
    __tablename__ = "backtests"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    
    start_date = Column(TIMESTAMP, nullable=False)
    end_date = Column(TIMESTAMP, nullable=False)
    
    initial_balance = Column(DECIMAL(18, 2), nullable=False)
    final_balance = Column(DECIMAL(18, 2))
    net_profit = Column(DECIMAL(18, 2))
    
    total_trades = Column(Integer, default=0)
    winning_trades = Column(Integer, default=0)
    losing_trades = Column(Integer, default=0)
    win_rate = Column(DECIMAL(5, 2))
    
    profit_factor = Column(DECIMAL(10, 4))
    sharpe_ratio = Column(DECIMAL(10, 4))
    max_drawdown = Column(DECIMAL(10, 4))
    
    parameters = Column(JSONB)
    raw_file_path = Column(Text)
    status = Column(String(50), default='pending')
    error_message = Column(Text)
    
    created_at = Column(TIMESTAMP, default=datetime.utcnow)
    updated_at = Column(TIMESTAMP, default=datetime.utcnow, onupdate=datetime.utcnow)
    processed_at = Column(TIMESTAMP)

class Trade(Base):
    """Trade model"""
    __tablename__ = "trades"
    
    id = Column(BigInteger, primary_key=True)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    trade_id = Column(String(100))
    position_id = Column(String(100))
    
    open_time = Column(TIMESTAMP, nullable=False)
    close_time = Column(TIMESTAMP)
    duration_seconds = Column(Integer)
    
    symbol = Column(String(20), nullable=False)
    direction = Column(String(10), nullable=False)
    
    entry_price = Column(DECIMAL(18, 8), nullable=False)
    exit_price = Column(DECIMAL(18, 8))
    volume = Column(DECIMAL(18, 8), nullable=False)
    
    profit = Column(DECIMAL(18, 8))
    pips = Column(DECIMAL(10, 2))
    
    stop_loss = Column(DECIMAL(18, 8))
    take_profit = Column(DECIMAL(18, 8))
    
    balance_after = Column(DECIMAL(18, 2))
    drawdown = Column(DECIMAL(18, 2))
    
    metadata = Column(JSONB)
    created_at = Column(TIMESTAMP, default=datetime.utcnow)




class Parameter(Base):
    """Parameter model"""
    __tablename__ = "parameters"
    
    id = Column(Integer, primary_key=True)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    parameter_name = Column(String(100), nullable=False)
    parameter_value = Column(Text)
    parameter_type = Column(String(50))
    parameter_group = Column(String(100))
    
    created_at = Column(TIMESTAMP, default=datetime.utcnow)




class IngestionJob(Base):
    """Ingestion job model"""
    __tablename__ = "ingestion_jobs"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    backtest_id = Column(UUID(as_uuid=True))
    
    job_type = Column(String(50), nullable=False)
    status = Column(String(50), default='pending')
    
    file_name = Column(String(255))
    file_size_bytes = Column(BigInteger)
    file_path = Column(Text)
    
    records_total = Column(Integer)
    records_processed = Column(Integer)
    records_failed = Column(Integer)
    
    started_at = Column(TIMESTAMP)
    completed_at = Column(TIMESTAMP)
    duration_seconds = Column(Integer)
    
    error_message = Column(Text)
    error_details = Column(JSONB)
    
    created_at = Column(TIMESTAMP, default=datetime.utcnow)




# Database dependency
def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
