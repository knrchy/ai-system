#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Testing Backtesting Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'


API_URL="http://localhost:30803"
PASSED=0
FAILED=0


test_endpoint() {
    local test_name=$1
    local endpoint=$2
    local expected_status=$3
    
    echo -e "${YELLOW}Testing: $test_name${NC}"
    
    status_code=$(curl -s -o /dev/null -w "%{http_code}" $API_URL$endpoint)
    
    if [ "$status_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ PASSED (Status: $status_code)${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED (Expected: $expected_status, Got: $status_code)${NC}"
        ((FAILED++))
    fi
    echo ""
}


# Run tests
test_endpoint "Health check" "/health" 200
test_endpoint "Root endpoint" "/" 200
test_endpoint "API docs" "/docs" 200
test_endpoint "List strategies" "/api/v1/strategies" 200


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}Test Results Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""


if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    
    echo ""
    echo -e "${YELLOW}Available Strategies:${NC}"
    curl -s http://localhost:30803/api/v1/strategies | jq '.'
    
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
