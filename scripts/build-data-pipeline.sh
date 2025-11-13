#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Building Data Pipeline Docker Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


cd applications/data-pipeline


echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t trading-ai/data-pipeline:latest .


echo ""
echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""
echo "Image: trading-ai/data-pipeline:latest"
echo ""
