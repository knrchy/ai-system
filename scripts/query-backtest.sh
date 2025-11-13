#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Query Backtest Data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')


if [ -z "$1" ]; then
    echo -e "${YELLOW}Listing all backtests:${NC}"
    echo ""
    kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "
        SELECT 
            id,
            name,
            total_trades,
            win_rate,
            net_profit,
            created_at
        FROM backtests
        ORDER BY created_at DESC
        LIMIT 10;
    "
else
    BACKTEST_ID=$1
    echo -e "${YELLOW}Backtest Details: $BACKTEST_ID${NC}"
    echo ""
    
    echo -e "${BLUE}Summary:${NC}"
    kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "
        SELECT * FROM backtests WHERE id = '$BACKTEST_ID';
    "
    
    echo ""
    echo -e "${BLUE}Trade Statistics:${NC}"
    kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "
        SELECT 
            COUNT(*) as total_trades,
            SUM(CASE WHEN profit > 0 THEN 1 ELSE 0 END) as winning_trades,
            SUM(CASE WHEN profit < 0 THEN 1 ELSE 0 END) as losing_trades,
            SUM(profit) as total_profit,
            AVG(profit) as avg_profit,
            MAX(profit) as max_profit,
            MIN(profit) as min_profit
        FROM trades
        WHERE backtest_id = '$BACKTEST_ID';
    "
    
    echo ""
    echo -e "${BLUE}Top 10 Trades:${NC}"
    kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "
        SELECT 
            open_time,
            symbol,
            direction,
            profit,
            pips
        FROM trades
        WHERE backtest_id = '$BACKTEST_ID'
        ORDER BY profit DESC
        LIMIT 10;
    "
fi
