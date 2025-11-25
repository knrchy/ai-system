"""
Data loader service - Load historical data from database
"""
import pandas as pd
from sqlalchemy.orm import Session
from typing import Optional
from datetime import datetime, date
from uuid import UUID
import logging


from ..models.database import Trade


logger = logging.getLogger(__name__)




class DataLoader:
    """Load and prepare data for backtesting"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def load_trades(
        self,
        backtest_id: UUID,
        start_date: Optional[date] = None,
        end_date: Optional[date] = None
    ) -> pd.DataFrame:
        """
        Load trades from database and convert to OHLCV format
        
        Args:
            backtest_id: UUID of the backtest
            start_date: Optional start date filter
            end_date: Optional end date filter
            
        Returns:
            DataFrame with OHLCV data
        """
        logger.info(f"Loading trades for backtest {backtest_id}")
        
        # Query trades
        query = self.db.query(Trade).filter(Trade.backtest_id == backtest_id)
        
        if start_date:
            query = query.filter(Trade.open_time >= start_date)
        if end_date:
            query = query.filter(Trade.open_time <= end_date)
        
        trades = query.order_by(Trade.open_time).all()
        
        if not trades:
            raise ValueError(f"No trades found for backtest {backtest_id}")
        
        logger.info(f"Loaded {len(trades)} trades")
        
        # Convert to DataFrame
        data = []
        for trade in trades:
            data.append({
                'datetime': trade.open_time,
                'open': float(trade.entry_price) if trade.entry_price else 0,
                'high': float(trade.entry_price) if trade.entry_price else 0,
                'low': float(trade.entry_price) if trade.entry_price else 0,
                'close': float(trade.exit_price) if trade.exit_price else float(trade.entry_price),
                'volume': float(trade.volume) if trade.volume else 0
            })
        
        df = pd.DataFrame(data)
        df['datetime'] = pd.to_datetime(df['datetime'])
        df.set_index('datetime', inplace=True)
        
        # Resample to create proper OHLCV candles (1 hour)
        ohlcv = df.resample('1H').agg({
            'open': 'first',
            'high': 'max',
            'low': 'min',
            'close': 'last',
            'volume': 'sum'
        }).dropna()
        
        logger.info(f"Created {len(ohlcv)} OHLCV candles")
        
        return ohlcv
