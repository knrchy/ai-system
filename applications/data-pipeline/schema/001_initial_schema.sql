-- ============================================
-- Trading AI System - Database Schema
-- Phase 2: Data Pipeline
-- ============================================


-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ============================================
-- Table: backtests
-- Stores backtest metadata and summary results
-- ============================================
CREATE TABLE IF NOT EXISTS backtests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Time range
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    
    -- Financial metrics
    initial_balance DECIMAL(18, 2) NOT NULL,
    final_balance DECIMAL(18, 2),
    net_profit DECIMAL(18, 2),
    gross_profit DECIMAL(18, 2),
    gross_loss DECIMAL(18, 2),
    
    -- Trade statistics
    total_trades INTEGER DEFAULT 0,
    winning_trades INTEGER DEFAULT 0,
    losing_trades INTEGER DEFAULT 0,
    win_rate DECIMAL(5, 2),
    
    -- Performance metrics
    profit_factor DECIMAL(10, 4),
    sharpe_ratio DECIMAL(10, 4),
    sortino_ratio DECIMAL(10, 4),
    max_drawdown DECIMAL(10, 4),
    max_drawdown_percent DECIMAL(10, 4),
    recovery_factor DECIMAL(10, 4),
    
    -- Trade metrics
    avg_trade_profit DECIMAL(18, 2),
    avg_winning_trade DECIMAL(18, 2),
    avg_losing_trade DECIMAL(18, 2),
    largest_winning_trade DECIMAL(18, 2),
    largest_losing_trade DECIMAL(18, 2),
    avg_trade_duration_seconds INTEGER,
    
    -- Risk metrics
    max_consecutive_wins INTEGER,
    max_consecutive_losses INTEGER,
    avg_risk_reward_ratio DECIMAL(10, 4),
    
    -- Metadata
    parameters JSONB,
    raw_file_path TEXT,
    status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed
    error_message TEXT,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP
);


-- Indexes for backtests
CREATE INDEX idx_backtests_created_at ON backtests(created_at DESC);
CREATE INDEX idx_backtests_status ON backtests(status);
CREATE INDEX idx_backtests_date_range ON backtests(start_date, end_date);
CREATE INDEX idx_backtests_name ON backtests(name);


-- ============================================
-- Table: trades
-- Stores individual trade records
-- ============================================
CREATE TABLE IF NOT EXISTS trades (
    id BIGSERIAL PRIMARY KEY,
    backtest_id UUID NOT NULL REFERENCES backtests(id) ON DELETE CASCADE,
    
    -- Trade identification
    trade_id VARCHAR(100),
    position_id VARCHAR(100),
    
    -- Timing
    open_time TIMESTAMP NOT NULL,
    close_time TIMESTAMP,
    duration_seconds INTEGER,
    
    -- Instrument
    symbol VARCHAR(20) NOT NULL,
    
    -- Trade details
    direction VARCHAR(10) NOT NULL, -- BUY, SELL
    entry_price DECIMAL(18, 8) NOT NULL,
    exit_price DECIMAL(18, 8),
    volume DECIMAL(18, 8) NOT NULL,
    
    -- Results
    profit DECIMAL(18, 8),
    profit_percent DECIMAL(10, 4),
    pips DECIMAL(10, 2),
    commission DECIMAL(18, 8),
    swap DECIMAL(18, 8),
    
    -- Stop loss & Take profit
    stop_loss DECIMAL(18, 8),
    take_profit DECIMAL(18, 8),
    
    -- Running metrics
    balance_after DECIMAL(18, 2),
    equity_after DECIMAL(18, 2),
    drawdown DECIMAL(18, 2),
    drawdown_percent DECIMAL(10, 4),
    
    -- Additional data
    extra_data JSONB,
    
    -- Timestamps
    created_at TIMESTAMP DEFAULT NOW()
);


-- Indexes for trades
CREATE INDEX idx_trades_backtest_id ON trades(backtest_id);
CREATE INDEX idx_trades_open_time ON trades(open_time);
CREATE INDEX idx_trades_close_time ON trades(close_time);
CREATE INDEX idx_trades_symbol ON trades(symbol);
CREATE INDEX idx_trades_direction ON trades(direction);
CREATE INDEX idx_trades_profit ON trades(profit);


-- Composite indexes for common queries
CREATE INDEX idx_trades_backtest_time ON trades(backtest_id, open_time);
CREATE INDEX idx_trades_backtest_symbol ON trades(backtest_id, symbol);


-- ============================================
-- Table: parameters
-- Stores bot parameters for each backtest
-- ============================================
CREATE TABLE IF NOT EXISTS parameters (
    id SERIAL PRIMARY KEY,
    backtest_id UUID NOT NULL REFERENCES backtests(id) ON DELETE CASCADE,
    
    parameter_name VARCHAR(100) NOT NULL,
    parameter_value TEXT,
    parameter_type VARCHAR(50), -- string, integer, float, boolean
    parameter_group VARCHAR(100), -- e.g., 'indicators', 'risk_management'
    
    created_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(backtest_id, parameter_name)
);


-- Indexes for parameters
CREATE INDEX idx_parameters_backtest_id ON parameters(backtest_id);
CREATE INDEX idx_parameters_name ON parameters(parameter_name);


-- ============================================
-- Table: daily_summary
-- Aggregated daily performance
-- ============================================
CREATE TABLE IF NOT EXISTS daily_summary (
    id SERIAL PRIMARY KEY,
    backtest_id UUID NOT NULL REFERENCES backtests(id) ON DELETE CASCADE,
    
    trade_date DATE NOT NULL,
    
    -- Daily statistics
    total_trades INTEGER DEFAULT 0,
    winning_trades INTEGER DEFAULT 0,
    losing_trades INTEGER DEFAULT 0,
    
    -- Daily P&L
    gross_profit DECIMAL(18, 2),
    gross_loss DECIMAL(18, 2),
    net_profit DECIMAL(18, 2),
    
    -- Daily metrics
    win_rate DECIMAL(5, 2),
    avg_profit DECIMAL(18, 2),
    max_profit DECIMAL(18, 2),
    max_loss DECIMAL(18, 2),
    
    -- Balance tracking
    starting_balance DECIMAL(18, 2),
    ending_balance DECIMAL(18, 2),
    
    created_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(backtest_id, trade_date)
);


-- Indexes for daily_summary
CREATE INDEX idx_daily_summary_backtest_id ON daily_summary(backtest_id);
CREATE INDEX idx_daily_summary_date ON daily_summary(trade_date);


-- ============================================
-- Table: ingestion_jobs
-- Tracks data ingestion jobs
-- ============================================
CREATE TABLE IF NOT EXISTS ingestion_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    backtest_id UUID REFERENCES backtests(id),
    
    job_type VARCHAR(50) NOT NULL, -- 'json_parse', 'csv_parse', 'validation'
    status VARCHAR(50) DEFAULT 'pending', -- pending, running, completed, failed
    
    -- File information
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    file_path TEXT,
    
    -- Processing metrics
    records_total INTEGER,
    records_processed INTEGER,
    records_failed INTEGER,
    
    -- Timing
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_seconds INTEGER,
    
    -- Error handling
    error_message TEXT,
    error_details JSONB,
    
    created_at TIMESTAMP DEFAULT NOW()
);


-- Indexes for ingestion_jobs
CREATE INDEX idx_ingestion_jobs_status ON ingestion_jobs(status);
CREATE INDEX idx_ingestion_jobs_backtest_id ON ingestion_jobs(backtest_id);
CREATE INDEX idx_ingestion_jobs_created_at ON ingestion_jobs(created_at DESC);


-- ============================================
-- Functions and Triggers
-- ============================================


-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger for backtests table
CREATE TRIGGER update_backtests_updated_at
    BEFORE UPDATE ON backtests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- Function to calculate backtest summary
CREATE OR REPLACE FUNCTION calculate_backtest_summary(p_backtest_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE backtests SET
        total_trades = (SELECT COUNT(*) FROM trades WHERE backtest_id = p_backtest_id),
        winning_trades = (SELECT COUNT(*) FROM trades WHERE backtest_id = p_backtest_id AND profit > 0),
        losing_trades = (SELECT COUNT(*) FROM trades WHERE backtest_id = p_backtest_id AND profit < 0),
        net_profit = (SELECT SUM(profit) FROM trades WHERE backtest_id = p_backtest_id),
        gross_profit = (SELECT SUM(profit) FROM trades WHERE backtest_id = p_backtest_id AND profit > 0),
        gross_loss = (SELECT ABS(SUM(profit)) FROM trades WHERE backtest_id = p_backtest_id AND profit < 0),
        avg_trade_profit = (SELECT AVG(profit) FROM trades WHERE backtest_id = p_backtest_id),
        avg_winning_trade = (SELECT AVG(profit) FROM trades WHERE backtest_id = p_backtest_id AND profit > 0),
        avg_losing_trade = (SELECT AVG(profit) FROM trades WHERE backtest_id = p_backtest_id AND profit < 0),
        largest_winning_trade = (SELECT MAX(profit) FROM trades WHERE backtest_id = p_backtest_id),
        largest_losing_trade = (SELECT MIN(profit) FROM trades WHERE backtest_id = p_backtest_id),
        avg_trade_duration_seconds = (SELECT AVG(duration_seconds) FROM trades WHERE backtest_id = p_backtest_id)
    WHERE id = p_backtest_id;
    
    -- Calculate win rate
    UPDATE backtests SET
        win_rate = CASE 
            WHEN total_trades > 0 THEN (winning_trades::DECIMAL / total_trades * 100)
            ELSE 0
        END,
        profit_factor = CASE
            WHEN gross_loss > 0 THEN (gross_profit / gross_loss)
            ELSE NULL
        END
    WHERE id = p_backtest_id;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- Sample Queries (for reference)
-- ============================================


-- Get backtest summary
-- SELECT * FROM backtests WHERE id = 'your-uuid';


-- Get all trades for a backtest
-- SELECT * FROM trades WHERE backtest_id = 'your-uuid' ORDER BY open_time;


-- Get daily performance
-- SELECT * FROM daily_summary WHERE backtest_id = 'your-uuid' ORDER BY trade_date;


-- Get winning trades only
-- SELECT * FROM trades WHERE backtest_id = 'your-uuid' AND profit > 0;


-- Get trades by symbol
-- SELECT symbol, COUNT(*), SUM(profit) as total_profit
-- FROM trades WHERE backtest_id = 'your-uuid'
-- GROUP BY symbol ORDER BY total_

-- Get trades by symbol
-- SELECT symbol, COUNT(*), SUM(profit) as total_profit
-- FROM trades WHERE backtest_id = 'your-uuid'
-- GROUP BY symbol ORDER BY total_profit DESC;


-- Get parameters for a backtest
-- SELECT * FROM parameters WHERE backtest_id = 'your-uuid';


-- ============================================
-- Grants (adjust username as needed)
-- ============================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO trading_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO trading_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO trading_user;
