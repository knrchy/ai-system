#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Trading AI System - Infrastructure Testing"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


PASSED=0
FAILED=0


# Function to run test
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    if eval $test_command > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED++))
    fi
    echo ""
}


echo -e "${YELLOW}🔍 Running Infrastructure Tests...${NC}"
echo ""


# Test 1: Cluster connectivity
run_test "Kubernetes cluster connectivity" "kubectl cluster-info"


# Test 2: All nodes ready
run_test "All nodes are ready" "kubectl get nodes | grep -v NotReady"


# Test 3: Namespaces exist
run_test "Required namespaces exist" "kubectl get namespace trading-system databases monitoring"


# Test 4: PostgreSQL pod running
run_test "PostgreSQL pod is running" "kubectl get pod -n databases -l app=postgres | grep Running"


# Test 5: Redis pod running
run_test "Redis pod is running" "kubectl get pod -n databases -l app=redis | grep Running"


# Test 6: ChromaDB pod running
run_test "ChromaDB pod is running" "kubectl get pod -n databases -l app=chromadb | grep Running"


# Test 7: Ollama pod running
run_test "Ollama pod is running" "kubectl get pod -n trading-system -l app=ollama | grep Running"


# Test 8: PostgreSQL connection
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
run_test "PostgreSQL database connection" "kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c 'SELECT 1;'"


# Test 9: Redis connection
REDIS_POD=$(kubectl get pod -n databases -l app=redis -o jsonpath='{.items[0].metadata.name}')
run_test "Redis connection" "kubectl exec -n databases $REDIS_POD -- redis-cli ping"


# Test 10: ChromaDB API
CHROMADB_POD=$(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}')
run_test "ChromaDB API heartbeat" "kubectl exec -n databases $CHROMADB_POD -- curl -s http://localhost:8000/api/v1/heartbeat"


# Test 11: Ollama service
OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')
run_test "Ollama service" "kubectl exec -n trading-system $OLLAMA_POD -- curl -s http://localhost:11434/"


# Test 12: Ollama model exists
run_test "Ollama model (llama3.1:8b)" "kubectl exec -n trading-system $OLLAMA_POD -- ollama list | grep llama3.1"


# Test 13: Persistent volumes
run_test "Persistent volumes created" "kubectl get pv | grep trading-data-pv"


# Test 14: Storage class
run_test "Storage class exists" "kubectl get storageclass local-storage"


# Test 15: Services accessible
run_test "PostgreSQL service exists" "kubectl get svc -n databases postgres"
run_test "Redis service exists" "kubectl get svc -n databases redis"
run_test "ChromaDB service exists" "kubectl get svc -n databases chromadb"
run_test "Ollama service exists" "kubectl get svc -n trading-system ollama"


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}📊 Test Results Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""


if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Infrastructure is ready.${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Proceed to Phase 2: Data Pipeline"
    echo "2. Create database schema"
    echo "3. Set up data ingestion scripts"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please review the errors above.${NC}"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "1. Check pod logs: kubectl logs -n <namespace> <pod-name>"
    echo "2. Describe pod: kubectl describe pod -n <namespace> <pod-name>"
    echo "3. Check events: kubectl get events -n <namespace>"
    exit 1
fi
