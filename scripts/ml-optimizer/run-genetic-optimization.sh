#!/bin/bash

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧬 Run Genetic Algorithm Optimization"
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
    echo "Usage: $0 <backtest-id> [population] [generations]"
    echo ""
    echo "Example:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 100 50"
    exit 1
fi

BACKTEST_ID=$1
POPULATION=${2:-100}
GENERATIONS=${3:-50}

echo -e "${BLUE}Backtest ID:${NC} $BACKTEST_ID"
echo -e "${BLUE}Population Size:${NC} $POPULATION"
echo -e "${BLUE}Generations:${NC} $GENERATIONS"
echo ""

echo -e "${YELLOW}Starting genetic optimization...${NC}"
echo "This will optimize for both profit AND low drawdown"
echo "Estimated time: 30-60 minutes"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:30804/api/v1/optimize/genetic \
  -H "Content-Type: application/json" \
  -d "{
    \"backtest_id\": \"$BACKTEST_ID\",
    \"algorithm\": \"genetic\",
    \"objectives\": [\"net_profit\", \"max_drawdown\"],
    \"parameters\": [
      {\"name\": \"stop_loss\", \"min\": 20, \"max\": 80, \"type\": \"int\"},
      {\"name\": \"take_profit\", \"min\": 40, \"max\": 200, \"type\": \"int\"}
    ],
    \"population_size\": $POPULATION,
    \"generations\": $GENERATIONS
  }")

echo -e "${GREEN}Response:${NC}"
echo $RESPONSE | jq '.'

OPTIMIZATION_ID=$(echo $RESPONSE | jq -r '.optimization_id')

if [ "$OPTIMIZATION_ID" != "null" ]; then
    echo ""
    echo -e "${GREEN}✅ Genetic optimization started!${NC}"
    echo ""
    echo "Optimization ID: $OPTIMIZATION_ID"
    echo ""
    echo -e "${BLUE}Pareto Front (Trade-off Solutions):${NC}"
    echo $RESPONSE | jq -r '.pareto_front[] | "Rank \(.rank): SL=\(.parameters.stop_loss), TP=\(.parameters.take_profit) → Profit: $\(.objectives.net_profit), DD: \(.objectives.max_drawdown)%"' | head -10
else
    echo ""
    echo -e "${RED}❌ Failed to start optimization${NC}"
    exit 1
fi
