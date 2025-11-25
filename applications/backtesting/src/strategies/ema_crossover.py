"""
EMA Crossover Strategy
"""
import backtrader as bt
from .base_strategy import BaseStrategy




class EMACrossover(BaseStrategy):
    """
    Simple EMA crossover strategy
    
    Buy when fast EMA crosses above slow EMA
    Sell when fast EMA crosses below slow EMA
    """
    
    params = (
        ('fast_period', 20),
        ('slow_period', 50),
        ('stop_loss', 50),
        ('take_profit', 100),
    )
    
    def __init__(self):
        super().__init__()
        
        # Add indicators
        self.fast_ema = bt.indicators.ExponentialMovingAverage(
            self.datas[0].close,
            period=self.params.fast_period
        )
        
        self.slow_ema = bt.indicators.ExponentialMovingAverage(
            self.datas[0].close,
            period=self.params.slow_period
        )
        
        # Crossover signal
        self.crossover = bt.indicators.CrossOver(self.fast_ema, self.slow_ema)
    
    def next(self):
        """Main strategy logic"""
        
        # Check if we have an order pending
        if self.order:
            return
        
        # Check if we are in the market
        if not self.position:
            # Not in market, look for buy signal
            if self.crossover > 0:  # Fast EMA crossed above slow EMA
                self.log(f'BUY CREATE, {self.datas[0].close[0]:.5f}')
                self.order = self.buy()
        
        else:
            # In market, look for sell signal
            if self.crossover < 0:  # Fast EMA crossed below slow EMA
                self.log(f'SELL CREATE, {self.datas[0].close[0]:.5f}')
                self.order = self.sell()

