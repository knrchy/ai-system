"""
CSV parser for cTrader transaction logs
"""
import pandas as pd
import polars as pl
from typing import Dict, List, Any
from pathlib import Path
import logging


logger = logging.getLogger(__name__)




class CTraderCSVParser:
    """Parser for cTrader CSV transaction logs"""
    
    def __init__(self, file_path: str, use_polars: bool = True):
        self.file_path = Path(file_path)
        self.use_polars = use_polars  # Use Polars for large files
        self.data = None
        
    def parse(self) -> pd.DataFrame:
        """Parse CSV file and return DataFrame"""
        logger.info(f"Parsing CSV file: {self.file_path}")
        
        try:
            file_size_mb = self.file_path.stat().st_size / (1024 * 1024)
            logger.info(f"File size: {file_size_mb:.2f} MB")
            
            # Use Polars for large files (>100MB)
            if self.use_polars and file_size_mb > 100:
                logger.info("Using Polars for large file processing")
                df = self._parse_with_polars()
            else:
                logger.info("Using Pandas for file processing")
                df = self._parse_with_pandas()
            
            logger.info(f"Parsed {len(df)} records")
            return df
            
        except Exception as e:
            logger.error(f"Error parsing CSV: {e}")
            raise
    
    def _parse_with_pandas(self) -> pd.DataFrame:
        """Parse using Pandas"""
        df = pd.read_csv(
            self.file_path,
            parse_dates=['OpenTime', 'CloseTime'],
            dtype={
                'TradeId': str,
                'Symbol': str,
                'Direction': str,
                'EntryPrice': float,
                'ExitPrice': float,
                'Volume': float,
                'Profit': float,
                'Pips': float
            }
        )
        
        return self._clean_dataframe(df)
    
    def _parse_with_polars(self) -> pd.DataFrame:
        """Parse using Polars (faster for large files)"""
        df_polars = pl.read_csv(
            self.file_path,
            try_parse_dates=True
        )
        
        # Convert to Pandas for compatibility
        df = df_polars.to_pandas()
        
        return self._clean_dataframe(df)
    
    def _clean_dataframe(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean and standardize DataFrame"""
        # Rename columns to match database schema
        column_mapping = {
            'TradeId': 'trade_id',
            'PositionId': 'position_id',
            'OpenTime': 'open_time',
            'CloseTime': 'close_time',
            'Symbol': 'symbol',
            'Direction': 'direction',
            'EntryPrice': 'entry_price',
            'ExitPrice': 'exit_price',
            'Volume': 'volume',
            'Profit': 'profit',
            'Pips': 'pips',
            'Commission': 'commission',
            'Swap': 'swap',
            'StopLoss': 'stop_loss',
            'TakeProfit': 'take_profit',
            'BalanceAfter': 'balance_after'
        }
        
        # Rename columns that exist
        existing_columns = {k: v for k, v in column_mapping.items() if k in df.columns}
        df = df.rename(columns=existing_columns)
        
        # Calculate duration if both times are present
        if 'open_time' in df.columns and 'close_time' in df.columns:
            df['duration_seconds'] = (
                pd.to_datetime(df['close_time']) - pd.to_datetime(df['open_time'])
            ).dt.total_seconds()
        
        # Remove rows with missing critical data
        if 'open_time' in df.columns:
            df = df.dropna(subset=['open_time'])
        
        # Standardize direction values
        if 'direction' in df.columns:
            df['direction'] = df['direction'].str.upper()
        
        return df
    
    def validate(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Validate parsed data"""
        validation_results = {
            'total_records': len(df),
            'missing_values': df.isnull().sum().to_dict(),
            'invalid_directions': 0,
            'negative_volumes': 0,
            'date_range': None
        }
        
        # Check for invalid directions
        if 'direction' in df.columns:
            valid_directions = ['BUY', 'SELL']
            validation_results['invalid_directions'] = (
                ~df['direction'].isin(valid_directions)
            ).sum()
        
        # Check for negative volumes
        if 'volume' in df.columns:
            validation_results['negative_volumes'] = (df['volume'] < 0).sum()
        
        # Get date range
        if 'open_time' in df.columns:
            validation_results['date_range'] = {
                'start': df['open_time'].min(),
                'end': df['open_time'].max()
            }
        
        return validation_results
