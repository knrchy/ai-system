"""
Database models for backtesting service
"""
from sqlalchemy import create_engine, Column, Integer, BigInteger, DECIMAL, TIMESTAMP, String
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker


from ..config import settings


# Create engine
engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True

# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Base class
Base = declarative_base()




class Trade(Base):
    """Trade model (read-only)"""
    __tablename__ = "trades"
    
    id = Column(BigInteger, primary_key=True)
    backtest_id = Column(UUID(as_uuid=True), nullable=False)
    
    open_time = Column(TIMESTAMP)
    close_time = Column(TIMESTAMP)
    
    symbol = Column(String(20))
    direction = Column(String(10))
    
    entry_price = Column(DECIMAL(18, 8))
    exit_price = Column(DECIMAL(18, 8))
    volume = Column(DECIMAL(18, 8))
    
    profit = Column(DECIMAL(18, 8))




# Database dependency
def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
