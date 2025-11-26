#!/bin/bash

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying ML Optimizer Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Step 1: Building Docker image${NC}"
./scripts/build-ml-optimizer.sh

echo ""
echo -e "${YELLOW}Step 2: Deploying to Kubernetes${NC}"
kubectl apply -f kubernetes/services/ml-optimizer/deployment.yaml

echo ""
echo -e "${YELLOW}Step 3: Waiting for deployment...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/ml-optimizer -n trading-system

echo ""
echo -e "${GREEN}✓ ML Optimizer deployed successfully${NC}"
echo ""

echo -e "${BLUE}Service Information:${NC}"
echo "  Internal: http://ml-optimizer.trading-system.svc.cluster.local:8004"
echo "  External: http://localhost:30804"
echo ""
echo -e "${BLUE}API Documentation:${NC}"
echo "  Swagger UI: http://localhost:30804/docs"
echo ""

echo -e "${YELLOW}Testing endpoint...${NC}"
sleep 5
curl -s http://localhost:30804/health | jq '.'

echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
