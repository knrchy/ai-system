"""
Data validation utilities
"""
from typing import Dict, List, Any
import pandas as pd
import logging


logger = logging.getLogger(__name__)




class DataValidator:
    """Validates trading data before database insertion"""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
    
    def validate_backtest_data(self, data: Dict[str, Any]) -> bool:
        """Validate complete backtest data"""
        logger.info("Validating backtest data")
        
        self.errors = []
        self.warnings = []
        
        # Validate backtest info
        self._validate_backtest_info(data.get('backtest_info', {}))
        
        # Validate trades
        if 'trades' in data:
            self._validate_trades(data['trades'])
        
        # Validate parameters
        if 'parameters' in data:
            self._validate_parameters(data['parameters'])
        
        if self.errors:
            logger.error(f"Validation failed with {len(self.errors)} errors")
            return False
        
        if self.warnings:
            logger.warning(f"Validation completed with {len(self.warnings)} warnings")
        
        logger.info("Validation successful")
        return True
    
    def _validate_backtest_info(self, info: Dict[str, Any]):
        """Validate backtest metadata"""
        required_fields = ['start_date', 'end_date', 'initial_balance']
        
        for field in required_fields:
            if field not in info or info[field] is None:
                self.errors.append(f"Missing required field: {field}")
        
        # Validate date range
        if 'start_date' in info and 'end_date' in info:
            if info['start_date'] >= info['end_date']:
                self.errors.append("Start date must be before end date")
        
        # Validate initial balance
        if 'initial_balance' in info:
            if info['initial_balance'] <= 0:
                self.errors.append("Initial balance must be positive")
    
    def _validate_trades(self, trades: List[Dict[str, Any]]):
        """Validate trade records"""
        if not trades:
            self.warnings.append("No trades found")
            return
        
        for idx, trade in enumerate(trades):
            # Check required fields
            required_fields = ['open_time', 'symbol', 'direction', 'entry_price', 'volume']
            
            for field in required_fields:
                if field not in trade or trade[field] is None:
                    self.errors.append(f"Trade {idx}: Missing {field}")
            
            # Validate direction
            if 'direction' in trade:
                if trade['direction'] not in ['BUY', 'SELL']:
                    self.errors.append(f"Trade {idx}: Invalid direction '{trade['direction']}'")
            
            # Validate prices
            if 'entry_price' in trade and trade['entry_price'] is not None:
                if trade['entry_price'] <= 0:
                    self.errors.append(f"Trade {idx}: Entry price must be positive")
            
            # Validate volume
            if 'volume' in trade and trade['volume'] is not None:
                if trade['volume'] <= 0:
                    self.errors.append(f"Trade {idx}: Volume must be positive")
            
            # Validate close time if present
            if 'close_time' in trade and trade['close_time'] is not None:
                if 'open_time' in trade and trade['open_time'] is not None:
                    if trade['close_time'] < trade['open_time']:
                        self.errors.append(f"Trade {idx}: Close time before open time")
    
    def _validate_parameters(self, parameters: Dict[str, Any]):
        """Validate bot parameters"""
        if not parameters:
            self.warnings.append("No parameters found")
            return
        
        # Check for common parameter issues
        for key, value in parameters.items():
            if value is None:
                self.warnings.append(f"Parameter '{key}' has null value")
    
    def get_validation_report(self) -> Dict[str, Any]:
        """Get validation report"""
        return {
            'is_valid': len(self.errors) == 0,
            'error_count': len(self.errors),
            'warning_count': len(self.warnings),
            'errors': self.errors,
            'warnings': self.warnings
        }
