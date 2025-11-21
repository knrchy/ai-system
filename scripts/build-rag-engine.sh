#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔨 Building RAG Engine Docker Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'


cd applications/rag-engine


echo -e "${YELLOW}Building Docker image...${NC}"
echo "This may take several minutes (downloading embedding model)"
echo ""


docker build -t trading-ai/rag-engine:latest .


echo ""
echo -e "${GREEN}✓ Docker image built successfully${NC}"
echo ""
echo "Image: trading-ai/rag-engine:latest"
echo ""
