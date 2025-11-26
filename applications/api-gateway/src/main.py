"""
API Gateway - Unified entry point for all services
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import logging

from .config import settings
from .routes import data, rag, optimizer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Rate limiter
limiter = Limiter(key_func=get_remote_address)

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Unified API Gateway for Trading AI System"
)

# Add rate limiter
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routes
app.include_router(data.router, prefix="/api/v1")
app.include_router(rag.router, prefix="/api/v1")
app.include_router(optimizer.router, prefix="/api/v1")


@app.on_event("startup")
async def startup_event():
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"Data Pipeline: {settings.DATA_PIPELINE_URL}")
    logger.info(f"RAG Engine: {settings.RAG_ENGINE_URL}")
    logger.info(f"Optimizer: {settings.OPTIMIZER_URL}")


@app.get("/")
@limiter.limit(f"{settings.RATE_LIMIT_PER_MINUTE}/minute")
def root():
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running",
        "services": {
            "data_pipeline": settings.DATA_PIPELINE_URL,
            "rag_engine": settings.RAG_ENGINE_URL,
            "optimizer": settings.OPTIMIZER_URL,
            "backtesting": settings.BACKTESTING_URL,
            "ml_optimizer": settings.ML_OPTIMIZER_URL
        }
    }


@app.get("/health")
def health_check():
    return {"status": "healthy"}
