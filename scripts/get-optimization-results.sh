#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏆 Get Optimization Results"
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
    echo "Usage: $0 <optimization-id> [limit]"
    exit 1
fi


OPTIMIZATION_ID=$1
LIMIT=${2:-10}


echo -e "${YELLOW}Fetching results for: $OPTIMIZATION_ID${NC}"
echo ""


RESPONSE=$(curl -s "http://localhost:30802/api/v1/optimize/$OPTIMIZATION_ID/results?limit=$LIMIT")


echo $RESPONSE | jq '.'


echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Top Results Summary${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


echo $RESPONSE | jq -r '.results[] | 
  "Rank \(.rank): \(.parameters | to_entries | map("\(.key)=\(.value)") | join(", "))
  → Profit: $\(.net_profit) | Win Rate: \(.win_rate)% | Sharpe: \(.sharpe_ratio)"' | head -n $LIMIT


echo ""
echo -e "${BLUE}Best Parameters:${NC}"
echo $RESPONSE | jq '.results[0].parameters'


echo ""
echo -e "${YELLOW}Full results saved to: optimization_${OPTIMIZATION_ID}_results.json${NC}"
echo $RESPONSE > "optimization_${OPTIMIZATION_ID}_results.json"
