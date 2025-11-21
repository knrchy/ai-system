"""
Database models for RAG service
"""
from sqlalchemy import create_engine, Column, String, Integer, BigInteger, DECIMAL, TIMESTAMP, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime


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




class Trade(Base):
    """Trade model (read-only for RAG service)"""
    __tablename__ = "trades"
    
    id = Column(BigInteger, primary_key=True)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    open_time = Column(TIMESTAMP, nullable=False)
    close_time = Column(TIMESTAMP)
    
    symbol = Column(String(20), nullable=False)
    direction = Column(String(10), nullable=False)
    
    entry_price = Column(DECIMAL(18, 8))
    exit_price = Column(DECIMAL(18, 8))
    volume = Column(DECIMAL(18, 8))
    
    profit = Column(DECIMAL(18, 8))
    pips = Column(DECIMAL(10, 2))
    
    metadata = Column(JSONB)




class Backtest(Base):
    """Backtest model (read-only for RAG service)"""
    __tablename__ = "backtests"
    
    id = Column(UUID(as_uuid=True), primary_key=True)
    name = Column(String(255), nullable=False)
    description = Column(Text)
    
    total_trades = Column(Integer, default=0)
    winning_trades = Column(Integer, default=0)
    win_rate = Column(DECIMAL(5, 2))
    
    created_at = Column(TIMESTAMP, default=datetime.utcnow)




# Database dependency
def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
