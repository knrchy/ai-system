# Data Pipeline Service


FastAPI service for ingesting and processing cTrader backtest data.


## Features


- Parse cTrader JSON exports
- Parse transaction CSV files
- Data validation
- Batch processing for large datasets
- RESTful API
- PostgreSQL storage


## Local Development


### Setup


```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate


# Install dependencies
pip install -r requirements.txt


# Copy environment file
cp .env.example .env


# Edit .env with your settings
Run Locally
-----------------------------------0-----------------------------------------
# Start the service
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000


# Access API docs
# http://localhost:8000/docs
Run Tests
-----------------------------------0-----------------------------------------
pytest
Docker
Build
-----------------------------------0-----------------------------------------
docker build -t trading-ai/data-pipeline:latest .
Run
-----------------------------------0-----------------------------------------
docker run -p 8000:8000 \
  -e DATABASE_URL="postgresql://user:pass@host/db" \
  trading-ai/data-pipeline:latest
API Endpoints
Upload Data
-----------------------------------...-----------------------------------------
POST /api/v1/ingest
List Backtests
-----------------------------------...-----------------------------------------
GET /api/v1/backtests
Get Backtest
-----------------------------------...-----------------------------------------
GET /api/v1/backtests/{id}
Get Job Status
-----------------------------------...-----------------------------------------
GET /api/v1/jobs/{id}
Delete Backtest
-----------------------------------...-----------------------------------------
DELETE /api/v1/backtests/{id}
Database Schema
See schema/001_initial_schema.sql for complete schema.


Tables
backtests - Backtest metadata and summary
trades - Individual trade records
parameters - Bot parameters
daily_summary - Daily performance aggregation
ingestion_jobs - Job tracking
Configuration
Environment variables:


-----------------------------------0-----------------------------------------
DATABASE_URL=postgresql://user:pass@host:5432/db
RAW_DATA_PATH=/mnt/trading-data/raw
PROCESSED_DATA_PATH=/mnt/trading-data/processed
BATCH_SIZE=10000
MAX_FILE_SIZE_MB=500
Architecture
-----------------------------------...-----------------------------------------
Client → FastAPI → Parser → Validator → Database
                  ↓
              File Storage
-----------------------------------...-----------------------------------------


---


### **File: `applications/data-pipeline/tests/test_parsers.py`**


```python
"""
Tests for data parsers
"""
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
