#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Run Custom Backtest"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo -e "${RED}Error: No backtest ID specified${NC}"
    echo ""
    echo "Usage: $0 <backtest-id> [strategy] [fast] [slow]"
    echo ""
    echo "Example:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 ema_crossover 20 50"
    echo ""
    echo "Available strategies:"
    curl -s http://localhost:30803/api/v1/strategies | jq -r '.[] | "  - \(.name): \(.description)"'
    exit 1
fi


BACKTEST_ID=$1
STRATEGY=${2:-ema_crossover}
FAST_PERIOD=${3:-20}
SLOW_PERIOD=${4:-50}


echo -e "${BLUE}Backtest ID:${NC} $BACKTEST_ID"
echo -e "${BLUE}Strategy:${NC} $STRATEGY"
echo -e "${BLUE}Parameters:${NC} Fast=$FAST_PERIOD, Slow=$SLOW_PERIOD"
echo ""


echo -e "${YELLOW}Running backtest...${NC}"
echo "This may take 30-60 seconds"
echo ""


RESPONSE=$(curl -s -X POST http://localhost:30803/api/v1/backtest \
  -H "Content-Type: application/json" \
  -d "{
    \"backtest_id\": \"$BACKTEST_ID\",
    \"strategy_name\": \"$STRATEGY\",
    \"parameters\": {
      \"fast_period\": $FAST_PERIOD,
      \"slow_period\": $SLOW_PERIOD
    },
    \"initial_cash\": 10000.0
  }")


echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Backtest Results${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


# Check if response is valid
if echo $RESPONSE | jq -e . >/dev/null 2>&1; then
    echo $RESPONSE | jq '.'
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    TOTAL_TRADES=$(echo $RESPONSE | jq -r '.total_trades')
    WIN_RATE=$(echo $RESPONSE | jq -r '.win_rate')
    NET_PROFIT=$(echo $RESPONSE | jq -r '.net_profit')
    SHARPE=$(echo $RESPONSE | jq -r '.sharpe_ratio')
    MAX_DD=$(echo $RESPONSE | jq -r '.max_drawdown_percent')
    
    echo -e "${YELLOW}Total Trades:${NC} $TOTAL_TRADES"
    echo -e "${YELLOW}Win Rate:${NC} $WIN_RATE%"
    echo -e "${YELLOW}Net Profit:${NC} \$$NET_PROFIT"
    echo -e "${YELLOW}Sharpe Ratio:${NC} $SHARPE"
    echo -e "${YELLOW}Max Drawdown:${NC} $MAX_DD%"
    
else
    echo -e "${RED}❌ Error running backtest${NC}"
    echo $RESPONSE
    exit 1
fi
