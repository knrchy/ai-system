"""
Data ingestion service
"""
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional
from uuid import UUID, uuid4
from datetime import datetime
from pathlib import Path
import logging
import shutil


from ..models.database import Backtest, Trade, Parameter, IngestionJob
from ..parsers.json_parser import CTraderJSONParser
from ..parsers.csv_parser import CTraderCSVParser
from ..parsers.validator import DataValidator
from ..config import settings


logger = logging.getLogger(__name__)




class IngestionService:
    """Service for ingesting trading data"""
    
    def __init__(self, db: Session):
        self.db = db
        self.validator = DataValidator()
    
    def ingest_backtest(
        self,
        name: str,
        json_file_path: str,
        csv_file_path: Optional[str] = None,
        parameters_file_path: Optional[str] = None,
        description: Optional[str] = None,
        initial_balance: float = 10000.00
    ) -> Dict[str, Any]:
        """
        Ingest complete backtest data
        
        Args:
            name: Backtest name
            json_file_path: Path to JSON results file
            csv_file_path: Optional path to CSV transactions file
            parameters_file_path: Optional path to parameters JSON
            description: Optional description
            initial_balance: Initial account balance
            
        Returns:
            Dict with backtest_id and job_id
        """
        logger.info(f"Starting ingestion for backtest: {name}")
        
        # Create ingestion job
        job = IngestionJob(
            job_type='full_ingestion',
            status='running',
            file_name=Path(json_file_path).name,
            started_at=datetime.utcnow()
        )
        self.db.add(job)
        self.db.commit()
        
        try:
            # Parse JSON file
            logger.info("Parsing JSON file")
            json_parser = CTraderJSONParser(json_file_path)
            data = json_parser.parse()
            
            # Validate data
            logger.info("Validating data")
            if not self.validator.validate_backtest_data(data):
                report = self.validator.get_validation_report()
                raise ValueError(f"Validation failed: {report['errors']}")
            
            # Create backtest record
            backtest = self._create_backtest(
                name=name,
                description=description,
                initial_balance=initial_balance,
                data=data
            )
            
            job.backtest_id = backtest.id
            
            # Store raw file
            raw_file_path = self._store_raw_file(json_file_path, backtest.id)
            backtest.raw_file_path = str(raw_file_path)
            
            # Insert trades
            logger.info("Inserting trades")
            trade_count = self._insert_trades(backtest.id, data['trades'])
            
            # Insert parameters
            logger.info("Inserting parameters")
            param_count = self._insert_parameters(backtest.id, data['parameters'])
            
            # Update backtest summary
            self._update_backtest_summary(backtest.id)
            
            # Mark backtest as completed
            backtest.status = 'completed'
            backtest.processed_at = datetime.utcnow()
            
            # Update job
            job.status = 'completed'
            job.completed_at = datetime.utcnow()
            job.duration_seconds = int(
                (job.completed_at - job.started_at).total_seconds()
            )
            job.records_total = trade_count
            job.records_processed = trade_count
            
            self.db.commit()
            
            logger.info(f"Ingestion completed: {trade_count} trades, {param_count} parameters")
            
            return {
                'backtest_id': str(backtest.id),
                'job_id': str(job.id),
                'trades_inserted': trade_count,
                'parameters_inserted': param_count
            }
            
        except Exception as e:
            logger.error(f"Ingestion failed: {e}")
            
            # Update job status
            job.status = 'failed'
            job.error_message = str(e)
            job.completed_at = datetime.utcnow()
            
            self.db.commit()
            
            raise
    
    def _create_backtest(
        self,
        name: str,
        initial_balance: float,
        data: Dict[str, Any],
        description: Optional[str] = None
    ) -> Backtest:
        """Create backtest record"""
        info = data['backtest_info']
        summary = data.get('summary', {})
        
        backtest = Backtest(
            name=name,
            description=description,
            start_date=info.get('start_date'),
            end_date=info.get('end_date'),
            initial_balance=initial_balance,
            status='processing'
        )
        
        self.db.add(backtest)
        self.db.commit()
        self.db.refresh(backtest)
        
        return backtest
    
    def _insert_trades(self, backtest_id: UUID, trades: list) -> int:
        """Insert trades in batches"""
        batch_size = settings.BATCH_SIZE
        total_inserted = 0
        
        for i in range(0, len(trades), batch_size):
            batch = trades[i:i + batch_size]
            
            trade_objects = [
                Trade(
                    backtest_id=backtest_id,
                    **trade
                )
                for trade in batch
            ]
            
            self.db.bulk_save_objects(trade_objects)
            self.db.commit()
            total_inserted += len(batch)
            logger.info(f"Inserted batch: {total_inserted}/{len(trades)} trades")
        
        return total_inserted
    
    def _insert_parameters(self, backtest_id: UUID, parameters: Dict[str, Any]) -> int:
        """Insert parameters"""
        if not parameters:
            return 0
        
        param_objects = []
        for key, value in parameters.items():
            param_objects.append(
                Parameter(
                    backtest_id=backtest_id,
                    parameter_name=key,
                    parameter_value=str(value),
                    parameter_type=type(value).__name__
                )
            )
        
        self.db.bulk_save_objects(param_objects)
        self.db.commit()
        
        return len(param_objects)
    
    def _update_backtest_summary(self, backtest_id: UUID):
        """Update backtest summary statistics"""
        # Call stored procedure
        self.db.execute(
            "SELECT calculate_backtest_summary(:backtest_id)",
            {'backtest_id': str(backtest_id)}
        )
        self.db.commit()
    
    def _store_raw_file(self, file_path: str, backtest_id: UUID) -> Path:
        """Store raw file in persistent storage"""
        source = Path(file_path)
        destination_dir = Path(settings.RAW_DATA_PATH) / str(backtest_id)
        destination_dir.mkdir(parents=True, exist_ok=True)
        
        destination = destination_dir / source.name
        shutil.copy2(source, destination)
        
        logger.info(f"Stored raw file: {destination}")
        return destination
    
    def get_job_status(self, job_id: UUID) -> Optional[IngestionJob]:
        """Get ingestion job status"""
        return self.db.query(IngestionJob).filter(
            IngestionJob.id == job_id
        ).first()
