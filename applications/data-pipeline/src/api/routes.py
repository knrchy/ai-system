"""
FastAPI routes for data pipeline
"""
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from uuid import UUID
import tempfile
import logging


from ..models.database import get_db, Backtest, IngestionJob
from ..models.schemas import (
    BacktestResponse,
    IngestionRequest,
    IngestionResponse,
    JobStatus
)
from ..services.ingestion_service import IngestionService


logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/v1", tags=["data-pipeline"])




@router.post("/ingest", response_model=IngestionResponse)
async def ingest_data(
    json_file: UploadFile = File(..., description="cTrader JSON results file"),
    csv_file: Optional[UploadFile] = File(None, description="Transaction CSV file"),
    name: str = Form(..., description="Backtest name"),
    description: Optional[str] = Form(None, description="Backtest description"),
    initial_balance: float = Form(10000.00, description="Initial balance"),
    db: Session = Depends(get_db)
):
    """
    Ingest backtest data from cTrader exports
    
    Upload JSON and optionally CSV files to process backtest data
    """
    logger.info(f"Received ingestion request: {name}")
    
    # Validate file types
    if not json_file.filename.endswith('.json'):
        raise HTTPException(status_code=400, detail="JSON file must have .json extension")
    
    if csv_file and not csv_file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="CSV file must have .csv extension")
    
    try:
        # Save uploaded files to temporary location
        with tempfile.NamedTemporaryFile(delete=False, suffix='.json') as tmp_json:
            content = await json_file.read()
            tmp_json.write(content)
            tmp_json_path = tmp_json.name
        
        tmp_csv_path = None
        if csv_file:
            with tempfile.NamedTemporaryFile(delete=False, suffix='.csv') as tmp_csv:
                content = await csv_file.read()
                tmp_csv.write(content)
                tmp_csv_path = tmp_csv.name
        
        # Process ingestion
        service = IngestionService(db)
        result = service.ingest_backtest(
            name=name,
            json_file_path=tmp_json_path,
            csv_file_path=tmp_csv_path,
            description=description,
            initial_balance=initial_balance
        )
        
        return IngestionResponse(
            job_id=result['job_id'],
            backtest_id=result['backtest_id'],
            status='completed',
            message=f"Successfully ingested {result['trades_inserted']} trades"
        )
        
    except Exception as e:
        logger.error(f"Ingestion error: {e}")
        raise HTTPException(status_code=500, detail=str(e))




@router.get("/jobs/{job_id}", response_model=JobStatus)
def get_job_status(
    job_id: UUID,
    db: Session = Depends(get_db)
):
    """Get status of an ingestion job"""
    service = IngestionService(db)
    job = service.get_job_status(job_id)
    
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    
    return job




@router.get("/backtests", response_model=List[BacktestResponse])
def list_backtests(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    """List all backtests"""
    backtests = db.query(Backtest)\
        .order_by(Backtest.created_at.desc())\
        .offset(skip)\
        .limit(limit)\
        .all()
    
    return backtests




@router.get("/backtests/{backtest_id}", response_model=BacktestResponse)
def get_backtest(
    backtest_id: UUID,
    db: Session = Depends(get_db)
):
    """Get backtest details"""
    backtest = db.query(Backtest).filter(Backtest.id == backtest_id).first()
    
    if not backtest:
        raise HTTPException(status_code=404, detail="Backtest not found")
    
    return backtest




@router.delete("/backtests/{backtest_id}")
def delete_backtest(
    backtest_id: UUID,
    db: Session = Depends(get_db)
):
    """Delete a backtest and all related data"""
    backtest = db.query(Backtest).filter(Backtest.id == backtest_id).first()
    
    if not backtest:
        raise HTTPException(status_code=404, detail="Backtest not found")
    
    db.delete(backtest)
    db.commit()
    
    return {"message": "Backtest deleted successfully"}




@router.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "data-pipeline"}
