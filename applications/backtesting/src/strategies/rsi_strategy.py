"""
RSI Strategy
"""
import backtrader as bt
from .base_strategy import BaseStrategy




class RSIStrategy(BaseStrategy):
    """
    RSI-based mean reversion strategy
    
    Buy when RSI < oversold threshold
    Sell when RSI > overbought threshold
    """
    
    params = (
        ('rsi_period', 14),
        ('oversold', 30),
        ('overbought', 70),
        ('stop_loss', 50),
        ('take_profit', 100),
    )
    
    def __init__(self):
        super().__init__()
        
        # Add RSI indicator
        self.rsi = bt.indicators.RSI(
            self.datas[0].close,
            period=self.params.rsi_period
        )
    
    def next(self):
        """Main strategy logic"""
        
        if self.order:
            return
        
        if not self.position:
            # Look for buy signal (oversold)
            if self.rsi < self.params.oversold:
                self.log(f'BUY CREATE (RSI: {self.rsi[0]:.2f}), {self.datas[0].close[0]:.5f}')
                self.order = self.buy()
        
        else:
            # Look for sell signal (overbought)
            if self.rsi > self.params.overbought:
                self.log(f'SELL CREATE (RSI: {self.rsi[0]:.2f}), {self.datas[0].close[0]:.5f}')
                self.order = self.sell()
