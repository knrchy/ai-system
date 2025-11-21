"""
FastAPI application entry point for RAG service
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging


from .config import settings
from .api.routes import router


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)


logger = logging.getLogger(__name__)


# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="RAG service for natural language querying of trading data"
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
    logger.info(f"ChromaDB: {settings.CHROMADB_HOST}:{settings.CHROMADB_PORT}")
    logger.info(f"Ollama: {settings.OLLAMA_HOST}:{settings.OLLAMA_PORT}")
    logger.info(f"Embedding Model: {settings.EMBEDDING_MODEL}")




@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Shutting down RAG service")




@app.get("/")
def root():
    return {
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running"
    }
