"""
Result service for storing and retrieving optimization results
"""
from typing import List, Dict, Any
from uuid import UUID
import logging
from sqlalchemy.orm import Session


from ..models.database import SessionLocal, OptimizationResult


logger = logging.getLogger(__name__)




class ResultService:
    """Service for managing optimization results"""
    
    def __init__(self):
        self.db = SessionLocal()
    
    def save_optimization_results(
        self,
        optimization_id: str,
        results: List[Dict[str, Any]]
    ):
        """Save optimization results to database"""
        logger.info(f"Saving {len(results)} results for optimization {optimization_id}")
        
        result_objects = []
        for result in results:
            obj = OptimizationResult(
                optimization_id=UUID(optimization_id),
                parameters=result.get('parameters', {}),
                net_profit=result.get('net_profit'),
                win_rate=result.get('win_rate'),
                profit_factor=result.get('profit_factor'),
                sharpe_ratio=result.get('sharpe_ratio'),
                max_drawdown=result.get('max_drawdown'),
                rank=result.get('rank'),
                metrics=result
            )
            result_objects.append(obj)
        
        self.db.bulk_save_objects(result_objects)
        self.db.commit()
        
        logger.info(f"Results saved successfully")
    
    def get_optimization_results(
        self,
        optimization_id: UUID,
        limit: int = 100
    ) -> List[Dict[str, Any]]:
        """Get optimization results"""
        results = self.db.query(OptimizationResult).filter(
            OptimizationResult.optimization_id == optimization_id
        ).order_by(OptimizationResult.rank).limit(limit).all()
        
        return [
            {
                'rank': r.rank,
                'parameters': r.parameters,
                'net_profit': float(r.net_profit) if r.net_profit else None,
                'win_rate': float(r.win_rate) if r.win_rate else None,
                'profit_factor': float(r.profit_factor) if r.profit_factor else None,
                'sharpe_ratio': float(r.sharpe_ratio) if r.sharpe_ratio else None,
                'max_drawdown': float(r.max_drawdown) if r.max_drawdown else None
            }
            for r in results
        ]
