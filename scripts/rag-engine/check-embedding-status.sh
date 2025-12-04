#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Check Embedding Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo -e "${RED}Error: No backtest ID specified${NC}"
    echo ""
    echo "Usage: $0 <backtest-id>"
    exit 1
fi


BACKTEST_ID=$1


echo -e "${YELLOW}Checking embedding status for: $BACKTEST_ID${NC}"
echo ""


RESPONSE=$(curl -s http://localhost:30801/api/v1/embeddings/$BACKTEST_ID/status)


echo $RESPONSE | jq '.'


EXISTS=$(echo $RESPONSE | jq -r '.exists')
COUNT=$(echo $RESPONSE | jq -r '.count')


echo ""
if [ "$EXISTS" = "true" ]; then
    echo -e "${GREEN}✓ Embeddings exist${NC}"
    echo "Total chunks: $COUNT"
    echo ""
    echo "Ready to query!"
else
    echo -e "${YELLOW}⚠ Embeddings not found${NC}"
    echo ""
    echo "Generate embeddings first:"
    echo "  ./scripts/rag-engine/generate-embeddings.sh $BACKTEST_ID"
fi
