#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Trading AI System - Complete Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color


# ASCII Art
cat << "EOF"
  ______               ___                   _____ 
 /_  __/________ _____/ (_)___  ____ _     /  _  |
  / / / ___/ __ `/ __  / / __ \/ __ `/    / / | |
 / / / /  / /_/ / /_/ / / / / / /_/ /    / /| | |
/_/ /_/   \__,_/\__,_/_/_/ /_/\__, /    /_/ |_| |
                             /____/              
EOF


echo ""
echo -e "${CYAN}Automated Infrastructure & Application Deployment${NC}"
echo ""


# Check prerequisites
echo -e "${YELLOW}🔍 Checking Prerequisites...${NC}"
echo ""


MISSING_DEPS=0


# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found${NC}"
    ((MISSING_DEPS++))
else
    echo -e "${GREEN}✓ kubectl found${NC}"
fi


# Check helm
if ! command -v helm &> /dev/null; then
    echo -e "${RED}✗ helm not found${NC}"
    ((MISSING_DEPS++))
else
    echo -e "${GREEN}✓ helm found${NC}"
fi


# Check terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ terraform not found${NC}"
    ((MISSING_DEPS++))
else
    echo -e "${GREEN}✓ terraform found${NC}"
fi


# Check docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ docker not found${NC}"
    ((MISSING_DEPS++))
else
    echo -e "${GREEN}✓ docker found${NC}"
fi


# Check k3s
if ! command -v k3s &> /dev/null; then
    echo -e "${RED}✗ k3s not found${NC}"
    ((MISSING_DEPS++))
else
    echo -e "${GREEN}✓ k3s found${NC}"
fi


if [ $MISSING_DEPS -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Missing dependencies. Please run setup-master.sh first.${NC}"
    exit 1
fi


echo ""
echo -e "${GREEN}✅ All prerequisites met!${NC}"
echo ""


# Deployment options
echo -e "${YELLOW}📋 Deployment Options:${NC}"
echo ""
echo "1. Full deployment (Infrastructure + Applications)"
echo "2. Infrastructure only"
echo "3. Applications only"
echo "4. Custom deployment"
echo ""
read -p "Select option [1-4]: " DEPLOY_OPTION


case $DEPLOY_OPTION in
    1)
        DEPLOY_INFRA=true
        DEPLOY_APPS=true
        ;;
    2)
        DEPLOY_INFRA=true
        DEPLOY_APPS=false
        ;;
    3)
        DEPLOY_INFRA=false
        DEPLOY_APPS=true
        ;;
    4)
        read -p "Deploy infrastructure? (yes/no): " INFRA_CHOICE
        read -p "Deploy applications? (yes/no): " APPS_CHOICE
        DEPLOY_INFRA=$( [ "$INFRA_CHOICE" = "yes" ] && echo true || echo false )
        DEPLOY_APPS=$( [ "$APPS_CHOICE" = "yes" ] && echo true || echo false )
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac


echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}Starting Deployment...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


# Deploy Infrastructure
if [ "$DEPLOY_INFRA" = true ]; then
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  PHASE 1: INFRASTRUCTURE DEPLOYMENT${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo ""
    
    ./infrastructure/scripts/deploy-infrastructure.sh
    
    echo ""
    echo -e "${GREEN}✅ Infrastructure deployment complete!${NC}"
    echo ""
    
    # Wait for all pods to be ready
    echo -e "${YELLOW}⏳ Waiting for all pods to be ready...${NC}"
    sleep 10
fi


# Deploy Applications
if [ "$DEPLOY_APPS" = true ]; then
    echo ""
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo -e "${MAGENTA}  PHASE 2: APPLICATION DEPLOYMENT${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════${NC}"
    echo ""
    
    echo -e "${YELLOW}📦 Deploying applications...${NC}"
    echo -e "${CYAN}(This will be implemented in Phase 2-7)${NC}"
    echo ""
    
    # Placeholder for future application deployments
    # ./scripts/deploy-data-pipeline.sh
    # ./scripts/deploy-rag-service.sh
    # ./scripts/deploy-backtesting.sh
    # ./scripts/deploy-api.sh
    
    echo -e "${GREEN}✓ Application deployment placeholder complete${NC}"
fi


# Run tests
echo ""
echo -e "${YELLOW}🧪 Running Infrastructure Tests...${NC}"
./infrastructure/scripts/test-infrastructure.sh


# Display summary
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


echo -e "${YELLOW}📊 Cluster Status:${NC}"
echo ""
kubectl get nodes
echo ""
kubectl get pods -A
echo ""


echo -e "${YELLOW}🔗 Service Endpoints:${NC}"
echo ""
echo -e "${BLUE}PostgreSQL:${NC}"
echo "  Internal: postgres.databases.svc.cluster.local:5432"
echo "  External: localhost:30432"
echo "  Username: trading_user"
echo "  Password: TradingAI2025!"
echo ""
echo -e "${BLUE}Redis:${NC}"
echo "  Internal: redis.databases.svc.cluster.local:6379"
echo "  External: localhost:30379"
echo ""
echo -e "${BLUE}ChromaDB:${NC}"
echo "  Internal: chromadb.databases.svc.cluster.local:8000"
echo "  External: http://localhost:30800"
echo ""
echo -e "${BLUE}Ollama:${NC}"
echo "  Internal: ollama.trading-system.svc.cluster.local:11434"
echo "  External: http://localhost:31434"
echo ""


echo -e "${YELLOW}📚 Useful Commands:${NC}"
echo ""
echo "View all pods:              kubectl get pods -A"
echo "View logs:                  kubectl logs -n <namespace> <pod-name>"
echo "Execute in pod:             kubectl exec -it -n <namespace> <pod-name> -- /bin/bash"
echo "Port forward:               kubectl port-forward -n <namespace> <pod-name> <local-port>:<pod-port>"
echo "Describe pod:               kubectl describe pod -n <namespace> <pod-name>"
echo ""
echo "Create backup:              ./infrastructure/scripts/backup.sh"
echo "Restore backup:             ./infrastructure/scripts/restore.sh <backup-name>"
echo "Cleanup all:                ./infrastructure/scripts/cleanup.sh"
echo ""


echo -e "${YELLOW}🎯 Next Steps:${NC}"
echo ""
echo "1. Test database connections"
echo "2. Upload your cTrader data"
echo "3. Proceed to Phase 2: Data Pipeline"
echo ""
echo -e "${CYAN}Happy Trading! 🚀📈${NC}"
echo ""
✅ File complete!
