"""
Metrics calculator - Calculate backtest performance metrics
"""
from typing import Dict, Any
import logging


logger = logging.getLogger(__name__)




class MetricsCalculator:
    """Calculate performance metrics from backtest results"""
    
    def calculate_metrics(
        self,
        trade_analyzer: Dict[str, Any],
        sharpe_analyzer: Dict[str, Any],
        drawdown_analyzer: Dict[str, Any],
        initial_value: float,
        final_value: float
    ) -> Dict[str, Any]:
        """
        Calculate comprehensive metrics
        
        Args:
            trade_analyzer: Trade analyzer results
            sharpe_analyzer: Sharpe ratio analyzer results
            drawdown_analyzer: Drawdown analyzer results
            initial_value: Initial portfolio value
            final_value: Final portfolio value
            
        Returns:
            Dictionary of calculated metrics
        """
        # Extract trade statistics
        total_trades = trade_analyzer.get('total', {}).get('total', 0)
        won_trades = trade_analyzer.get('won', {}).get('total', 0)
        lost_trades = trade_analyzer.get('lost', {}).get('total', 0)
        
        # Calculate win rate
        win_rate = (won_trades / total_trades * 100) if total_trades > 0 else 0
        
        # Extract P&L
        gross_profit = trade_analyzer.get('won', {}).get('pnl', {}).get('total', 0)
        gross_loss = abs(trade_analyzer.get('lost', {}).get('pnl', {}).get('total', 0))
        net_profit = final_value - initial_value
        
        # Calculate profit factor
        profit_factor = (gross_profit / gross_loss) if gross_loss > 0 else None
        
        # Extract Sharpe ratio
        sharpe_ratio = sharpe_analyzer.get('sharperatio', None)
        
        # Extract drawdown
        max_drawdown = drawdown_analyzer.get('max', {}).get('drawdown', 0)
        max_drawdown_pct = drawdown_analyzer.get('max', {}).get('moneydown', 0)
        
        metrics = {
            'status': 'completed',
            'total_trades': total_trades,
            'winning_trades': won_trades,
            'losing_trades': lost_trades,
            'win_rate': round(win_rate, 2),
            'gross_profit': round(gross_profit, 2),
            'gross_loss': round(gross_loss, 2),
            'net_profit': round(net_profit, 2),
            'profit_factor': round(profit_factor, 2) if profit_factor else None,
            'sharpe_ratio': round(sharpe_ratio, 4) if sharpe_ratio else None,
            'max_drawdown': round(max_drawdown, 2),
            'max_drawdown_percent': round(max_drawdown_pct, 2)
        }
        
        logger.info(f"Calculated metrics: {metrics}")
        
        return metrics
