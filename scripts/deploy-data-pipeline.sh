#!/bin/bash

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying Data Pipeline Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color codes (These are assumed to be defined at the start of your script)

# --- NEW STEP 1: WAIT FOR DEPENDENCIES ---
echo -e "${YELLOW}Step 1: Waiting for PostgreSQL Deployment to be available...${NC}"
# Wait for the postgres deployment to be ready and available
kubectl wait --for=condition=available --timeout=300s deployment/postgres -n databases

# Wait for the postgres service endpoint to be reachable (Optional, but safer)
# Since you have NodePort for Postgres, let's wait for the pod IP directly
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
echo -e "${YELLOW}Waiting for Postgres readiness probe (Pod: ${POSTGRES_POD})...${NC}"
kubectl wait --for=condition=ready --timeout=300s pod/$POSTGRES_POD -n databases

echo -e "${GREEN}✓ Postgres dependency ready${NC}"
echo ""

# --- OLD STEP 1 (now Step 2): Creating database schema ---
echo -e "${YELLOW}Step 2: Creating database schema${NC}"
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')

kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db < applications/data-pipeline/schema/001_initial_schema.sql

echo -e "${GREEN}✓ Database schema created${NC}"
echo ""


echo -e "${YELLOW}Step 2: Building Docker image${NC}"
kubectl apply -f kubernetes/services/data-pipeline/local-registry.yaml
sudo tee /etc/docker/daemon.json << EOF
{
  "insecure-registries": [
    "192.168.3.145:30500"
  ]
}
EOF
sudo systemctl restart docker

sudo tee /etc/rancher/k3s/registries.yaml  << EOF
# /etc/rancher/k3s/registries.yaml
mirrors:
  "192.168.3.145:30500":
    endpoint:
      - "http://10.128.0.16:30500"

# Alternatively, you can use the 'insecure-registries' top-level key:
# insecure-registries:
#   - "192.168.3.145:30500"
EOF
sudo systemctl restart k3s

./scripts/build-data-pipeline.sh
#k3s ctl images import /var/lib/docker/volumes/trading-ai/data-pipeline:latest


echo ""
echo -e "${YELLOW}Step 3: Deploying to Kubernetes${NC}"
#kubectl apply -f kubernetes/services/data-pipeline/trading-data-pv.yaml

kubectl apply -f kubernetes/services/data-pipeline/trading-data-pvc.yaml
kubectl apply -f kubernetes/services/data-pipeline/data-pipeline-configmap.yaml
kubectl apply -f kubernetes/services/data-pipeline/deployment.yaml
kubectl apply -f kubernetes/services/data-pipeline/data-pipeline-svc.yaml
kubectl apply -f kubernetes/services/data-pipeline/data-pipeline-nodeport.yaml


echo ""
echo -e "${YELLOW}Step 4: Waiting for deployment...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/data-pipeline -n trading-system


echo ""
echo -e "${GREEN}✓ Data Pipeline deployed successfully${NC}"
echo ""


echo -e "${BLUE}Service Information:${NC}"
echo "  Internal: http://data-pipeline.trading-system.svc.cluster.local:8000"
echo "  External: http://localhost:30800"
echo ""
echo -e "${BLUE}API Documentation:${NC}"
echo "  Swagger UI: http://localhost:30800/docs"
echo "  ReDoc: http://localhost:30800/redoc"
echo ""


echo -e "${YELLOW}Testing endpoint...${NC}"
sleep 5
curl -s http://localhost:30800/health | jq '.'


echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
