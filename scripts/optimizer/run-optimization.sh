#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ Run Parameter Optimization"
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
    echo "Usage: $0 <backtest-id> [param_name] [min] [max] [step]"
    echo ""
    echo "Example:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 stop_loss 20 80 2"
    exit 1
fi


BACKTEST_ID=$1
PARAM_NAME=${2:-stop_loss}
MIN_VALUE=${3:-20}
MAX_VALUE=${4:-80}
STEP=${5:-2}


echo -e "${BLUE}Backtest ID:${NC} $BACKTEST_ID"
echo -e "${BLUE}Parameter:${NC} $PARAM_NAME"
echo -e "${BLUE}Range:${NC} $MIN_VALUE to $MAX_VALUE (step: $STEP)"
echo ""


# Calculate total combinations
TOTAL=$(echo "($MAX_VALUE - $MIN_VALUE) / $STEP + 1" | bc)
echo -e "${YELLOW}Total combinations to test: $TOTAL${NC}"
echo ""


read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled"
    exit 0
fi


echo ""
echo -e "${YELLOW}Starting optimization...${NC}"

RESPONSE=$(curl -s -X POST http://localhost:30802/api/v1/optimize \
  -H "Content-Type: application/json" \
  -d "{
    \"backtest_id\": \"$BACKTEST_ID\",
    \"parameters\": [
      {
        \"name\": \"$PARAM_NAME\",
        \"min_value\": $MIN_VALUE,
        \"max_value\": $MAX_VALUE,
        \"step\": $STEP
      }
    ],
    \"optimization_type\": \"grid_search\"
  }")


echo -e "${GREEN}Response:${NC}"
echo $RESPONSE | jq '.'


OPTIMIZATION_ID=$(echo $RESPONSE | jq -r '.optimization_id')


if [ "$OPTIMIZATION_ID" != "null" ]; then
    echo ""
    echo -e "${GREEN}✅ Optimization started!${NC}"
    echo ""
    echo "Optimization ID: $OPTIMIZATION_ID"
    echo ""
    echo "Monitor progress:"
    echo "  ./scripts/optimizer/check-optimization-status.sh $OPTIMIZATION_ID"
    echo ""
    echo "View in Flower:"
    echo "  http://localhost:30555"
else
    echo ""
    echo -e "${RED}❌ Failed to start optimization${NC}"
    exit 1
fi

