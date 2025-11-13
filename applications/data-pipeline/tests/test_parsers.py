import pytest
from src.parsers.json_parser import CTraderJSONParser
from src.parsers.validator import DataValidator




def test_json_parser():
    """Test JSON parser basic functionality"""
    # This is a placeholder test
    # In real implementation, you would use actual test data
    validator = DataValidator()
    assert validator is not None




def test_data_validator():
    """Test data validator"""
    validator = DataValidator()
    
    # Test with valid data
    valid_data = {
        'backtest_info': {
            'start_date': '2024-01-01',
            'end_date': '2024-12-31',
            'initial_balance': 10000.00
        },
        'trades': [
            {
                'open_time': '2024-01-01 10:00:00',
                'symbol': 'EURUSD',
                'direction': 'BUY',
                'entry_price': 1.1000,
                'volume': 0.01
            }
        ],
        'parameters': {}
    }
    
    result = validator.validate_backtest_data(valid_data)
    assert result is True
    
    # Test with invalid data
    invalid_data = {
        'backtest_info': {
            'start_date': '2024-12-31',
            'end_date': '2024-01-01',  # End before start
            'initial_balance': -1000  # Negative balance
        },
        'trades': [],
        'parameters': {}
    }
    
    result = validator.validate_backtest_data(invalid_data)
    assert result is False
