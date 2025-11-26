#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚖️  Compare Backtest Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo "Usage: $0 <backtest-id>"
    echo ""
    echo "This will compare:"
    echo "  - Original cTrader results"
    echo "  - Python Backtrader results"
    exit 1
fi


BACKTEST_ID=$1


echo -e "${YELLOW}Fetching original cTrader results...${NC}"
ORIGINAL=$(curl -s http://localhost:30800/api/v1/backtests/$BACKTEST_ID)


echo -e "${YELLOW}Running Python backtest...${NC}"
PYTHON=$(curl -s -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d "{
    \"backtest_id\": \"$BACKTEST_ID\",
    \"strategy_name\": \"ema_crossover\",
    \"parameters\": {
      \"fast_period\": 20,
      \"slow_period\": 50
    },
    \"initial_cash\": 10000.0
  }")


echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Comparison Results${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


# Extract values
ORIG_TRADES=$(echo $ORIGINAL | jq -r '.total_trades')
ORIG_WIN_RATE=$(echo $ORIGINAL | jq -r '.win_rate')
ORIG_PROFIT=$(echo $ORIGINAL | jq -r '.net_profit')


PY_TRADES=$(echo $PYTHON | jq -r '.total_trades')
PY_WIN_RATE=$(echo $PYTHON | jq -r '.win_rate')
PY_PROFIT=$(echo $PYTHON | jq -r '.net_profit')


printf "%-20s %-15s %-15s\n" "Metric" "cTrader" "Python"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-20s %-15s %-15s\n" "Total Trades" "$ORIG_TRADES" "$PY_TRADES"
printf "%-20s %-15s %-15s\n" "Win Rate (%)" "$ORIG_WIN_RATE" "$PY_WIN_RATE"
printf "%-20s %-15s %-15s\n" "Net Profit (\$)" "$ORIG_PROFIT" "$PY_PROFIT"


echo ""
echo -e "${YELLOW}Note: Differences are expected due to:${NC}"
echo "  - Different execution models"
echo "  - Slippage/commission differences"
echo "  - Data resampling methods"
