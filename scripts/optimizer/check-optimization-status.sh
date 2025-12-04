#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Check Optimization Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo -e "${RED}Error: No optimization ID specified${NC}"
    echo ""
    echo "Usage: $0 <optimization-id>"
    exit 1
fi


OPTIMIZATION_ID=$1


echo -e "${YELLOW}Checking status for: $OPTIMIZATION_ID${NC}"
echo ""


while true; do
    RESPONSE=$(curl -s http://localhost:30802/api/v1/optimize/$OPTIMIZATION_ID/status)
    
    STATUS=$(echo $RESPONSE | jq -r '.status')
    PROGRESS=$(echo $RESPONSE | jq -r '.progress_percent')
    COMPLETED=$(echo $RESPONSE | jq -r '.completed_tasks')
    TOTAL=$(echo $RESPONSE | jq -r '.total_tasks')
    
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Optimization Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BLUE}Optimization ID:${NC} $OPTIMIZATION_ID"
    echo -e "${BLUE}Status:${NC} $STATUS"
    echo -e "${BLUE}Progress:${NC} $PROGRESS%"
    echo -e "${BLUE}Completed:${NC} $COMPLETED / $TOTAL tasks"
    echo ""
    
    # Progress bar
    FILLED=$(echo "$PROGRESS / 2" | bc)
    printf "["
    for i in $(seq 1 50); do
        if [ $i -le $FILLED ]; then
            printf "="
        else
            printf " "
        fi
    done
    printf "] $PROGRESS%%\n"
    echo ""
    
    if [ "$STATUS" = "completed" ]; then
        echo -e "${GREEN}✅ Optimization completed!${NC}"
        echo ""
        echo "Get results:"
        echo "  ./scripts/optimizer/get-optimization-results.sh $OPTIMIZATION_ID"
        break
    elif [ "$STATUS" = "failed" ]; then
        echo -e "${RED}❌ Optimization failed${NC}"
        break
    fi
    
    echo "Refreshing in 5 seconds... (Ctrl+C to stop)"
    sleep 5
done
