#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Trading AI System - Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


echo -e "${RED}⚠️  WARNING: This will delete all deployed resources!${NC}"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM


if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Cleanup cancelled.${NC}"
    exit 0
fi


echo ""
echo -e "${YELLOW}🗑️  Step 1: Deleting Ollama deployment${NC}"
kubectl delete -f kubernetes/services/ollama/ollama-deployment.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Ollama deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 2: Deleting ChromaDB deployment${NC}"
kubectl delete -f kubernetes/databases/chromadb/chromadb-deployment.yaml --ignore-not-found=true
echo -e "${GREEN}✓ ChromaDB deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 3: Deleting Redis deployment${NC}"
kubectl delete -f kubernetes/databases/redis/redis-deployment.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Redis deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 4: Deleting PostgreSQL deployment${NC}"
kubectl delete -f kubernetes/databases/postgres/postgres-deployment.yaml --ignore-not-found=true
echo -e "${GREEN}✓ PostgreSQL deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 5: Deleting Persistent Volumes${NC}"
kubectl delete -f kubernetes/storage/persistent-volumes.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Persistent volumes deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 6: Deleting Storage Class${NC}"
kubectl delete -f kubernetes/storage/storage-class.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Storage class deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 7: Deleting Namespaces${NC}"
kubectl delete -f kubernetes/namespaces/namespaces.yaml --ignore-not-found=true
echo -e "${GREEN}✓ Namespaces deleted${NC}"


echo ""
echo -e "${YELLOW}🗑️  Step 8: Running Terraform Destroy${NC}"
cd infrastructure/terraform
if [ -f "terraform.tfstate" ]; then
    terraform destroy -auto-approve
    echo -e "${GREEN}✓ Terraform resources destroyed${NC}"
else
    echo -e "${YELLOW}⚠️  No Terraform state found, skipping${NC}"
fi
cd ../..


echo ""
read -p "Do you want to delete data directories? (yes/no): " DELETE_DATA


if [ "$DELETE_DATA" = "yes" ]; then
    echo ""
    echo -e "${YELLOW}🗑️  Step 9: Deleting Data Directories${NC}"
    sudo rm -rf /mnt/trading-data/*
    sudo rm -rf /mnt/models/*
    sudo rm -rf /mnt/postgres-data/*
    sudo rm -rf /mnt/redis-data/*
    sudo rm -rf /mnt/chromadb-data/*
    echo -e "${GREEN}✓ Data directories cleaned${NC}"
else
    echo -e "${YELLOW}⚠️  Data directories preserved${NC}"
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Cleanup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}To redeploy, run:${NC}"
echo "./infrastructure/scripts/deploy-infrastructure.sh"
echo ""
✅ File complete!
