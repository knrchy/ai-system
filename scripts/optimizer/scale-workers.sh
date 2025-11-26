#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Scale Celery Workers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


if [ -z "$1" ]; then
    echo -e "${YELLOW}Current worker count:${NC}"
    kubectl get deployment celery-worker -n trading-system -o jsonpath='{.spec.replicas}'
    echo ""
    echo ""
    echo "Usage: $0 <number-of-workers>"
    echo ""
    echo "Example:"
    echo "  $0 5    # Scale to 5 workers"
    echo "  $0 10   # Scale to 10 workers"
    exit 0
fi


REPLICAS=$1


echo -e "${YELLOW}Scaling to $REPLICAS workers...${NC}"
kubectl scale deployment celery-worker --replicas=$REPLICAS -n trading-system


echo ""
echo -e "${YELLOW}Waiting for workers to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s deployment/celery-worker -n trading-system


echo ""
echo -e "${GREEN}✓ Workers scaled successfully${NC}"
echo ""


echo -e "${BLUE}Current worker status:${NC}"
kubectl get pods -n trading-system -l app=celery-worker


echo ""
echo -e "${BLUE}Total CPU/Memory usage:${NC}"
kubectl top pods -n trading-system -l app=celery-worker
