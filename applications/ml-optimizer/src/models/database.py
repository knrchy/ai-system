"""
Database models for ML optimizer service
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from ..config import settings

# Create engine
engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)

# Create session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Database dependency
def get_db():
    """Get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
