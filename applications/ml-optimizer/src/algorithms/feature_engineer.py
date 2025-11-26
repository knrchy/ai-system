"""
Feature engineering for trading data
"""
import pandas as pd
import numpy as np
from typing import List, Dict, Any
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import logging


logger = logging.getLogger(__name__)




class FeatureEngineer:
    """
    Feature engineering and selection for trading data
    """
    
    def __init__(self):
        self.scaler = StandardScaler()
        self.feature_importance = {}
    
    def create_features(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Create technical features from OHLCV data
        
        Args:
            df: DataFrame with OHLCV data
            
        Returns:
            DataFrame with additional features
        """
        logger.info("Creating technical features")
        
        df = df.copy()
        
        # Price-based features
        df['returns'] = df['close'].pct_change()
        df['log_returns'] = np.log(df['close'] / df['close'].shift(1))
        
        # Moving averages
        for period in [5, 10, 20, 50, 200]:
            df[f'sma_{period}'] = df['close'].rolling(window=period).mean()
            df[f'ema_{period}'] = df['close'].ewm(span=period).mean()
        
        # Volatility
        df['volatility_20'] = df['returns'].rolling(window=20).std()
        df['atr_14'] = self._calculate_atr(df, period=14)
        
        # Momentum indicators
        df['rsi_14'] = self._calculate_rsi(df['close'], period=14)
        df['macd'], df['macd_signal'] = self._calculate_macd(df['close'])
        
        # Volume features
        df['volume_sma_20'] = df['volume'].rolling(window=20).mean()
        df['volume_ratio'] = df['volume'] / df['volume_sma_20']
        
        # Price patterns
        df['high_low_ratio'] = df['high'] / df['low']
        df['close_open_ratio'] = df['close'] / df['open']
        
        # Trend features
        df['trend_5'] = (df['close'] > df['sma_5']).astype(int)
        df['trend_20'] = (df['close'] > df['sma_20']).astype(int)
        
        # Bollinger Bands
        df['bb_upper'], df['bb_lower'] = self._calculate_bollinger_bands(df['close'])
        df['bb_width'] = df['bb_upper'] - df['bb_lower']
        
        logger.info(f"Created {len(df.columns)} features")
        
        return df.dropna()
    
    def _calculate_rsi(self, prices: pd.Series, period: int = 14) -> pd.Series:
        """Calculate RSI indicator"""
        delta = prices.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
        rs = gain / loss
        rsi = 100 - (100 / (1 + rs))
        return rsi
    
    def _calculate_macd(self, prices: pd.Series, fast: int = 12, slow: int = 26, signal: int = 9):
        """Calculate MACD indicator"""
        ema_fast = prices.ewm(span=fast).mean()
        ema_slow = prices.ewm(span=slow).mean()
        macd = ema_fast - ema_slow
        macd_signal = macd.ewm(span=signal).mean()
        return macd, macd_signal
    
    def _calculate_atr(self, df: pd.DataFrame, period: int = 14) -> pd.Series:
        """Calculate Average True Range"""
        high_low = df['high'] - df['low']
        high_close = np.abs(df['high'] - df['close'].shift())
        low_close = np.abs(df['low'] - df['close'].shift())
        
        ranges = pd.concat([high_low, high_close, low_close], axis=1)
        true_range = ranges.max(axis=1)
        atr = true_range.rolling(window=period).mean()
        
        return atr
    
    def _calculate_bollinger_bands(self, prices: pd.Series, period: int = 20, std_dev: int = 2):
        """Calculate Bollinger Bands"""
        sma = prices.rolling(window=period).mean()
        std = prices.rolling(window=period).std()
        
        upper_band = sma + (std * std_dev)
        lower_band = sma - (std * std_dev)
        
        return upper_band, lower_band
    
    def select_features(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        top_n: int = 20
    ) -> List[str]:
        """
        Select most important features using Random Forest
        
        Args:
            X: Feature matrix
            y: Target variable
            top_n: Number of top features to select
            
        Returns:
            List of selected feature names
        """
        logger.info(f"Selecting top {top_n} features from {len(X.columns)}")
        
        # Train Random Forest
        rf = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
        rf.fit(X, y)
        
        # Get feature importance
        importance = pd.DataFrame({
            'feature': X.columns,
            'importance': rf.feature_importances_
        }).sort_values('importance', ascending=False)
        
        self.feature_importance = importance.set_index('feature')['importance'].to_dict()
        
        top_features = importance.head(top_n)['feature'].tolist()
        
        logger.info(f"Top 5 features: {top_features[:5]}")
        
        return top_features
