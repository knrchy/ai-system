"""
Celery task for running backtests
"""
from celery import Task
from typing import Dict, Any
import logging
from uuid import UUID


from ..celery_app import celery_app
from ..models.database import SessionLocal, Trade


logger = logging.getLogger(__name__)




class BacktestTask(Task):
    """Base task for backtesting"""
    
    def on_failure(self, exc, task_id, args, kwargs, einfo):
        logger.error(f"Task {task_id} failed: {exc}")
        super().on_failure(exc, task_id, args, kwargs, einfo)
    
    def on_success(self, retval, task_id, args, kwargs):
        logger.info(f"Task {task_id} completed successfully")
        super().on_success(retval, task_id, args, kwargs)




@celery_app.task(base=BacktestTask, bind=True, name='tasks.run_backtest')
def run_backtest(
    self,
    backtest_id: str,
    parameters: Dict[str, float]
) -> Dict[str, Any]:
    """
    Run a backtest with given parameters
    
    Args:
        backtest_id: UUID of the backtest
        parameters: Dictionary of parameters to test
        
    Returns:
        Dictionary with backtest results
    """
    logger.info(f"Running backtest {backtest_id} with parameters: {parameters}")
    
    try:
        # Update task state
        self.update_state(state='PROGRESS', meta={'progress': 0})
        
        # Fetch trades from database
        db = SessionLocal()
        trades = db.query(Trade).filter(
            Trade.backtest_id == UUID(backtest_id)
        ).all()
        
        logger.info(f"Loaded {len(trades)} trades")
        
        # Simulate backtest with new parameters
        # In real implementation, this would run actual backtest logic
        result = _simulate_backtest(trades, parameters)
        
        self.update_state(state='PROGRESS', meta={'progress': 100})
        
        db.close()
        
        logger.info(f"Backtest completed: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Error in backtest: {e}")
        raise




def _simulate_backtest(trades: list, parameters: Dict[str, float]) -> Dict[str, Any]:
    """
    Simulate backtest with modified parameters
    
    This is a simplified version. In production, you would:
    1. Replay trades with new stop_loss/take_profit
    2. Recalculate all metrics
    3. Return comprehensive results
    """
    import random
    
    # For demonstration, return simulated results
    # In production, implement actual backtest logic
    
    total_trades = len(trades)
    
    # Simulate impact of parameter changes
    stop_loss = parameters.get('stop_loss', 50)
    
    # Simplified logic: tighter stop loss = fewer wins but smaller losses
    win_rate_adjustment = (50 - stop_loss) * 0.002  # -0.2% per pip tighter
    base_win_rate = 0.65
    win_rate = max(0.4, min(0.8, base_win_rate + win_rate_adjustment))
    
    winning_trades = int(total_trades * win_rate)
    losing_trades = total_trades - winning_trades
    
    # Calculate profits
    avg_win = 100 + random.uniform(-20, 20)
    avg_loss = -80 + random.uniform(-10, 10)
    
    gross_profit = winning_trades * avg_win
    gross_loss = abs(losing_trades * avg_loss)
    net_profit = gross_profit - gross_loss
    
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else 0
    
    # Calculate Sharpe ratio (simplified)
    sharpe_ratio = (net_profit / total_trades) / 50 if total_trades > 0 else 0
    
    # Calculate max drawdown (simplified)
    max_drawdown = abs(gross_loss) * 0.3
    
    return {
        'parameters': parameters,
        'total_trades': total_trades,
        'winning_trades': winning_trades,
        'losing_trades': losing_trades,
        'win_rate': round(win_rate * 100, 2),
        'gross_profit': round(gross_profit, 2),
        'gross_loss': round(gross_loss, 2),
        'net_profit': round(net_profit, 2),
        'profit_factor': round(profit_factor, 2),
        'sharpe_ratio': round(sharpe_ratio, 4),
        'max_drawdown': round(max_drawdown, 2)
    }

