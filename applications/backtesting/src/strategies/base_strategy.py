"""
Base strategy class for Backtrader
"""
import backtrader as bt




class BaseStrategy(bt.Strategy):
    """Base strategy with common functionality"""
    
    params = (
        ('stop_loss', 50),      # Stop loss in pips
        ('take_profit', 100),   # Take profit in pips
        ('position_size', 0.02), # 2% risk per trade
    )
    
    def __init__(self):
        self.order = None
        self.trades = []
        
    def log(self, txt, dt=None):
        """Logging function"""
        dt = dt or self.datas[0].datetime.date(0)
        print(f'{dt.isoformat()} {txt}')
    
    def notify_order(self, order):
        """Notification of order status"""
        if order.status in [order.Submitted, order.Accepted]:
            return
        
        if order.status in [order.Completed]:
            if order.isbuy():
                self.log(f'BUY EXECUTED, Price: {order.executed.price:.5f}')
            elif order.issell():
                self.log(f'SELL EXECUTED, Price: {order.executed.price:.5f}')
            
            self.bar_executed = len(self)
        
        elif order.status in [order.Canceled, order.Margin, order.Rejected]:
            self.log('Order Canceled/Margin/Rejected')
        
        self.order = None
    
    def notify_trade(self, trade):
        """Notification of trade close"""
        if not trade.isclosed:
            return
        
        self.log(f'TRADE PROFIT, GROSS: {trade.pnl:.2f}, NET: {trade.pnlcomm:.2f}')
        
        self.trades.append({
            'profit': trade.pnlcomm,
            'size': trade.size,
            'price': trade.price
        })
