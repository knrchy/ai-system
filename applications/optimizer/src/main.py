"""
FastAPI application entry point for optimizer service
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging


from .config import settings
from .api.routes import router
from .models.database import init_db


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)


logger = logging.getLogger(__name__)


# Initialize database
init_db()


# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Distributed optimization service for trading strategies"
)


# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routes
app.include_router(router)




@app.on_event("startup")
async def startup_event():
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"Redis: {settings.REDIS_HOST}:{settings.REDIS_PORT}")
    logger.info(f"Worker concurrency: {settings.WORKER_CONCURRENCY}")




@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Shutting down optimizer service")




@app.get("/")
def root():
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }
