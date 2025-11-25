"""
Strategy converter - Convert cBot parameters to Python strategy
"""
from typing import Dict, Any
import logging


logger = logging.getLogger(__name__)




class StrategyConverter:
    """Convert cBot strategies to Backtrader strategies"""
    
    @staticmethod
    def detect_strategy_type(parameters: Dict[str, Any]) -> str:
        """
        Detect strategy type from parameters
        
        Args:
            parameters: Dictionary of cBot parameters
            
        Returns:
            Strategy type name
        """
        param_keys = set(parameters.keys())
        
        # Check for EMA crossover
        if 'FastEMA' in param_keys or 'SlowEMA' in param_keys:
            return 'ema_crossover'
        
        # Check for RSI
        if 'RSIPeriod' in param_keys or 'RSI_Period' in param_keys:
            return 'rsi_strategy'
        
        # Check for Bollinger Bands
        if 'BB_Period' in param_keys or 'BollingerPeriod' in param_keys:
            return 'bollinger_bands'
        
        # Default
        logger.warning(f"Could not detect strategy type from parameters: {param_keys}")
        return 'unknown'
    
    @staticmethod
    def convert_parameters(cbot_params: Dict[str, Any], strategy_type: str) -> Dict[str, Any]:
        """
        Convert cBot parameters to Backtrader parameters
        
        Args:
            cbot_params: cBot parameters
            strategy_type: Detected strategy type
            
        Returns:
            Converted parameters for Backtrader
        """
        converted = {}
        
        if strategy_type == 'ema_crossover':
            converted['fast_period'] = cbot_params.get('FastEMA', 20)
            converted['slow_period'] = cbot_params.get('SlowEMA', 50)
            converted['stop_loss'] = cbot_params.get('StopLoss', 50)
            converted['take_profit'] = cbot_params.get('TakeProfit', 100)
        
        elif strategy_type == 'rsi_strategy':
            converted['rsi_period'] = cbot_params.get('RSIPeriod', 14)
            converted['oversold'] = cbot_params.get('Oversold', 30)
            converted['overbought'] = cbot_params.get('Overbought', 70)
            converted['stop_loss'] = cbot_params.get('StopLoss', 50)
            converted['take_profit'] = cbot_params.get('TakeProfit', 100)
        
        logger.info(f"Converted parameters: {converted}")
        return converted
