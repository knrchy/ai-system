"""
Backtesting service - Main backtesting logic
"""
import backtrader as bt
from typing import Dict, Any, Optional
from uuid import UUID
from datetime import date
import logging
from sqlalchemy.orm import Session


from .data_loader import DataLoader
from .metrics_calculator import MetricsCalculator
from ..strategies.ema_crossover import EMACrossover
from ..strategies.rsi_strategy import RSIStrategy
from ..config import settings


logger = logging.getLogger(__name__)




class BacktestService:
    """Service for running backtests"""
    
    # Strategy registry
    STRATEGIES = {
        'ema_crossover': EMACrossover,
        'rsi_strategy': RSIStrategy,
    }
    
    def __init__(self, db: Session):
        self.db = db
        self.data_loader = DataLoader(db)
        self.metrics_calculator = MetricsCalculator()
    
    def run_backtest(
        self,
        backtest_id: UUID,
        strategy_name: str,
        parameters: Dict[str, Any],
        start_date: Optional[date] = None,
        end_date: Optional[date] = None,
        initial_cash: float = None,
        commission: float = None
    ) -> Dict[str, Any]:
        """
        Run a backtest
        
        Args:
            backtest_id: UUID of the backtest
            strategy_name: Name of strategy to use
            parameters: Strategy parameters
            start_date: Optional start date
            end_date: Optional end date
            initial_cash: Initial cash amount
            commission: Commission rate
            
        Returns:
            Dictionary with backtest results
        """
        logger.info(f"Running backtest: {strategy_name} with params: {parameters}")
        
        # Get strategy class
        strategy_class = self.STRATEGIES.get(strategy_name)
        if not strategy_class:
            raise ValueError(f"Unknown strategy: {strategy_name}")
        
        # Load data
        df = self.data_loader.load_trades(backtest_id, start_date, end_date)
        
        # Create Backtrader cerebro engine
        cerebro = bt.Cerebro()
        
        # Add strategy with parameters
        cerebro.addstrategy(strategy_class, **parameters)
        
        # Convert DataFrame to Backtrader data feed
        data = bt.feeds.PandasData(dataname=df)
        cerebro.adddata(data)
        
        # Set initial cash
        cash = initial_cash or settings.INITIAL_CASH
        cerebro.broker.setcash(cash)
        
        # Set commission
        comm = commission or settings.COMMISSION
        cerebro.broker.setcommission(commission=comm)
        
        # Add analyzers
        cerebro.addanalyzer(bt.analyzers.TradeAnalyzer, _name='trades')
        cerebro.addanalyzer(bt.analyzers.SharpeRatio, _name='sharpe')
        cerebro.addanalyzer(bt.analyzers.DrawDown, _name='drawdown')
        cerebro.addanalyzer(bt.analyzers.Returns, _name='returns')
        
        # Run backtest
        logger.info(f"Starting backtest with initial cash: ${cash}")
        initial_value = cerebro.broker.getvalue()
        
        results = cerebro.run()
        strategy_instance = results[0]
        
        final_value = cerebro.broker.getvalue()
        
        logger.info(f"Backtest completed. Final value: ${final_value:.2f}")
        
        # Extract results
        trade_analyzer = strategy_instance.analyzers.trades.get_analysis()
        sharpe_analyzer = strategy_instance.analyzers.sharpe.get_analysis()
        drawdown_analyzer = strategy_instance.analyzers.drawdown.get_analysis()
        
        # Calculate metrics
        metrics = self.metrics_calculator.calculate_metrics(
            trade_analyzer=trade_analyzer,
            sharpe_analyzer=sharpe_analyzer,
            drawdown_analyzer=drawdown_analyzer,
            initial_value=initial_value,
            final_value=final_value
        )
        
        return {
            'backtest_id': str(backtest_id),
            'strategy_name': strategy_name,
            'parameters': parameters,
            'initial_value': initial_value,
            'final_value': final_value,
            **metrics
        }
    
    def list_strategies(self) -> list:
        """List available strategies"""
        return [
            {
                'name': name,
                'description': cls.__doc__.strip() if cls.__doc__ else '',
                'parameters': [
                    {'name': k, 'default': v}
                    for k, v in cls.params._gettuple()
                ]
            }
            for name, cls in self.STRATEGIES.items()
        ]
