"""
JSON parser for cTrader backtest results
"""
import json
import pandas as pd
from typing import Dict, List, Any
from pathlib import Path
import logging


logger = logging.getLogger(__name__)




class CTraderJSONParser:
    """Parser for cTrader JSON exports"""
    
    def __init__(self, file_path: str):
        self.file_path = Path(file_path)
        self.data = None
        
    def parse(self) -> Dict[str, Any]:
        """Parse JSON file and extract data"""
        logger.info(f"Parsing JSON file: {self.file_path}")
        
        try:
            with open(self.file_path, 'r', encoding='utf-8') as f:
                self.data = json.load(f)
            
            logger.info(f"Successfully loaded JSON file")
            
            # Extract components
            result = {
                'backtest_info': self._extract_backtest_info(),
                'trades': self._extract_trades(),
                'parameters': self._extract_parameters(),
                'summary': self._extract_summary()
            }
            
            logger.info(f"Extracted {len(result['trades'])} trades")
            return result
            
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON format: {e}")
            raise ValueError(f"Invalid JSON file: {e}")
        except Exception as e:
            logger.error(f"Error parsing JSON: {e}")
            raise
    
    def _extract_backtest_info(self) -> Dict[str, Any]:
        """Extract backtest metadata"""
        return {
            'start_date': self.data.get('StartDate'),
            'end_date': self.data.get('EndDate'),
            'initial_balance': self.data.get('InitialBalance', 10000.00),
            'symbol': self.data.get('Symbol'),
            'timeframe': self.data.get('Timeframe')
        }
    
    def _extract_trades(self) -> List[Dict[str, Any]]:
        """Extract trade records"""
        trades = []
        
        # Adjust based on actual cTrader JSON structure
        trade_list = self.data.get('Trades', [])
        
        for trade in trade_list:
            trades.append({
                'trade_id': trade.get('Id'),
                'open_time': trade.get('OpenTime'),
                'close_time': trade.get('CloseTime'),
                'symbol': trade.get('Symbol'),
                'direction': trade.get('Direction'),
                'entry_price': trade.get('EntryPrice'),
                'exit_price': trade.get('ExitPrice'),
                'volume': trade.get('Volume'),
                'profit': trade.get('Profit'),
                'pips': trade.get('Pips'),
                'commission': trade.get('Commission'),
                'swap': trade.get('Swap'),
                'balance_after': trade.get('BalanceAfter')
            })
        
        return trades
    
    def _extract_parameters(self) -> Dict[str, Any]:
        """Extract bot parameters"""
        return self.data.get('Parameters', {})
    
    def _extract_summary(self) -> Dict[str, Any]:
        """Extract summary statistics"""
        return {
            'total_trades': self.data.get('TotalTrades', 0),
            'winning_trades': self.data.get('WinningTrades', 0),
            'losing_trades': self.data.get('LosingTrades', 0),
            'net_profit': self.data.get('NetProfit'),
            'profit_factor': self.data.get('ProfitFactor'),
            'sharpe_ratio': self.data.get('SharpeRatio'),
            'max_drawdown': self.data.get('MaxDrawdown')
        }
