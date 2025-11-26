#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🤖 Query Trading Data with AI"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo ""
    echo "Usage: $0 <backtest-id> <query>"
    echo ""
    echo "Example:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 \"What days should I avoid trading?\""
    echo ""
    echo "Sample queries:"
    echo "  - What days should I avoid trading?"
    echo "  - Show me the best performing symbols"
    echo "  - When did I have the biggest drawdowns?"
    echo "  - What time of day is most profitable?"
    echo "  - Analyze my Friday trading performance"
    exit 1
fi


BACKTEST_ID=$1
QUERY=$2


echo -e "${BLUE}Backtest ID:${NC} $BACKTEST_ID"
echo -e "${BLUE}Query:${NC} $QUERY"
echo ""


echo -e "${YELLOW}Processing query...${NC}"
echo "This may take 10-30 seconds"
echo ""


RESPONSE=$(curl -s -X POST http://localhost:30801/api/v1/query \
  -H "Content-Type: application/json" \
  -d "{
    \"query\": \"$QUERY\",
    \"backtest_id\": \"$BACKTEST_ID\",
    \"top_k\": 10
  }")


# Check if response is valid
if echo $RESPONSE | jq -e . >/dev/null 2>&1; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}AI Answer:${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo $RESPONSE | jq -r '.answer'
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Retrieved Contexts: $(echo $RESPONSE | jq '.contexts | length')${NC}"
    echo -e "${BLUE}Model Used: $(echo $RESPONSE | jq -r '.model_used')${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
else
    echo -e "${RED}❌ Error processing query${NC}"
    echo $RESPONSE
    exit 1
fi

