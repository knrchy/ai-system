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


# Define the local registry address
LOCAL_REGISTRY="192.168.3.145:30500"
IMAGE_NAME="${LOCAL_REGISTRY}/trading-ai/data-pipeline:latest"

echo -e "${YELLOW}Building Docker image (forcing no cache)...${NC}"
# --- FIX: Added --no-cache to ensure code changes are included ---
docker build --no-cache -t $IMAGE_NAME .

echo -e "${YELLOW}Pushing image to local registry: $LOCAL_REGISTRY${NC}"
# NOTE: You may need to run 'docker login' or configure your docker daemon 
# to allow pushing to an insecure registry (192.168.x.x:port) if using HTTPS is not set up.
docker push $IMAGE_NAME

echo ""
echo -e "${GREEN}✓ Docker image built and pushed successfully${NC}"
echo "Image: $IMAGE_NAME"
echo ""
