"""
LSTM model for time series prediction
"""
import numpy as np
import pandas as pd
from typing import Tuple, List
import logging
from tensorflow import keras
from tensorflow.keras import layers
from sklearn.preprocessing import MinMaxScaler


logger = logging.getLogger(__name__)




class LSTMPredictor:
    """
    LSTM neural network for time series prediction
    """
    
    def __init__(
        self,
        sequence_length: int = 60,
        features: List[str] = None
    ):
        self.sequence_length = sequence_length
        self.features = features or ['close', 'volume', 'rsi', 'ema_20']
        self.model = None
        self.scaler = MinMaxScaler()
    
    def prepare_data(
        self,
        df: pd.DataFrame,
        target_column: str = 'close'
    ) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        """
        Prepare data for LSTM training
        
        Args:
            df: DataFrame with features
            target_column: Column to predict
            
        Returns:
            X_train, y_train, X_test, y_test
        """
        logger.info(f"Preparing data with sequence length {self.sequence_length}")
        
        # Select features
        data = df[self.features].values
        
        # Scale data
        scaled_data = self.scaler.fit_transform(data)
        
        # Create sequences
        X, y = [], []
        for i in range(self.sequence_length, len(scaled_data)):
            X.append(scaled_data[i-self.sequence_length:i])
            y.append(scaled_data[i, self.features.index(target_column)])
        
        X, y = np.array(X), np.array(y)
        
        # Split train/test (80/20)
        split = int(0.8 * len(X))
        X_train, X_test = X[:split], X[split:]
        y_train, y_test = y[:split], y[split:]
        
        logger.info(f"Train: {len(X_train)}, Test: {len(X_test)}")
        
        return X_train, y_train, X_test, y_test
    
    def build_model(self, input_shape: Tuple[int, int]):
        """
        Build LSTM model
        
        Args:
            input_shape: Shape of input data (sequence_length, n_features)
        """
        logger.info(f"Building LSTM model with input shape {input_shape}")
        
        self.model = keras.Sequential([
            layers.LSTM(50, return_sequences=True, input_shape=input_shape),
            layers.Dropout(0.2),
            layers.LSTM(50, return_sequences=True),
            layers.Dropout(0.2),
            layers.LSTM(50),
            layers.Dropout(0.2),
            layers.Dense(1)
        ])
        
        self.model.compile(
            optimizer='adam',
            loss='mean_squared_error',
            metrics=['mae']
        )
        
        logger.info(f"Model built with {self.model.count_params()} parameters")
    
    def train(
        self,
        X_train: np.ndarray,
        y_train: np.ndarray,
        X_val: np.ndarray,
        y_val: np.ndarray,
        epochs: int = 50,
        batch_size: int = 32
    ):
        """
        Train LSTM model
        
        Args:
            X_train: Training features
            y_train: Training targets
            X_val: Validation features
            y_val: Validation targets
            epochs: Number of epochs
            batch_size: Batch size
        """
        logger.info(f"Training LSTM for {epochs} epochs")
        
        # Early stopping
        early_stop = keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True
        )
        
        # Train model
        history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=[early_stop],
            verbose=1
        )
        
        logger.info("Training complete")
        
        return history
    
    def predict(
        self,
        X: np.ndarray,
        n_steps: int = 30
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Make predictions
        
        Args:
            X: Input sequences
            n_steps: Number of steps to predict ahead
            
        Returns:
            Predictions and confidence intervals
        """
        logger.info(f"Making predictions for {n_steps} steps")
        
        predictions = []
        current_sequence = X[-1].copy()
        
        for _ in range(n_steps):
            # Predict next step
            pred = self.model.predict(current_sequence.reshape(1, *current_sequence.shape), verbose=0)
            predictions.append(pred[0, 0])
            
            # Update sequence (shift and add prediction)
            current_sequence = np.roll(current_sequence, -1, axis=0)
            current_sequence[-1, 0] = pred[0, 0]  # Assuming first feature is target
        
        predictions = np.array(predictions)
        
        # Calculate confidence intervals (simple approach)
        std = np.std(predictions)
        lower_bound = predictions - 1.96 * std
        upper_bound = predictions + 1.96 * std
        
        confidence_intervals = np.column_stack([lower_bound, upper_bound])
        
        return predictions, confidence_intervals
    
    def evaluate(self, X_test: np.ndarray, y_test: np.ndarray) -> Dict[str, float]:
        """
        Evaluate model performance
        
        Args:
            X_test: Test features
            y_test: Test targets
            
        Returns:
            Dictionary with metrics
        """
        predictions = self.model.predict(X_test, verbose=0)
        
        mse = np.mean((predictions.flatten() - y_test) ** 2)
        mae = np.mean(np.abs(predictions.flatten() - y_test))
        rmse = np.sqrt(mse)
        
        # R-squared
        ss_res = np.sum((y_test - predictions.flatten()) ** 2)
        ss_tot = np.sum((y_test - np.mean(y_test)) ** 2)
        r2 = 1 - (ss_res / ss_tot)
        
        return {
            'mse': float(mse),
            'mae': float(mae),
            'rmse': float(rmse),
            'r2': float(r2)
        }
