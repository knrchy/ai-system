#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Building Backtesting Docker Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'


cd applications/backtesting


echo -e "${YELLOW}Building Docker image...${NC}"
echo "This may take several minutes (installing TA-Lib)"
echo ""


docker build -t trading-ai/backtesting:latest .


echo ""
echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""
echo "Image: trading-ai/backtesting:latest"
echo ""
