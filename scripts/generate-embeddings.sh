#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 Generate Embeddings for Backtest"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo -e "${RED}Error: No backtest ID specified${NC}"
    echo ""
    echo "Usage: $0 <backtest-id> [force]"
    echo ""
    echo "Example:"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000"
    echo "  $0 123e4567-e89b-12d3-a456-426614174000 force"
    exit 1
fi


BACKTEST_ID=$1
FORCE_REGENERATE=${2:-false}


if [ "$FORCE_REGENERATE" = "force" ]; then
    FORCE_REGENERATE=true
else
    FORCE_REGENERATE=false
fi


echo -e "${YELLOW}Backtest ID: $BACKTEST_ID${NC}"
echo -e "${YELLOW}Force Regenerate: $FORCE_REGENERATE${NC}"
echo ""


echo -e "${YELLOW}Generating embeddings...${NC}"
echo "This may take several minutes depending on data size"
echo ""


RESPONSE=$(curl -s -X POST http://localhost:30801/api/v1/embeddings/generate \
  -H "Content-Type: application/json" \
  -d "{
    \"backtest_id\": \"$BACKTEST_ID\",
    \"force_regenerate\": $FORCE_REGENERATE
  }")


echo -e "${GREEN}Response:${NC}"
echo $RESPONSE | jq '.'


STATUS=$(echo $RESPONSE | jq -r '.status')


if [ "$STATUS" = "created" ] || [ "$STATUS" = "exists" ]; then
    echo ""
    echo -e "${GREEN}✅ Embeddings ready!${NC}"
    echo ""
    CHUNKS=$(echo $RESPONSE | jq -r '.chunks_created')
    echo "Total chunks: $CHUNKS"
    echo ""
    echo "You can now query this backtest:"
    echo "  ./scripts/query-rag.sh \"$BACKTEST_ID\" \"What days should I avoid trading?\""
else
    echo ""
    echo -e "${RED}❌ Failed to generate embeddings${NC}"
    exit 1
fi
