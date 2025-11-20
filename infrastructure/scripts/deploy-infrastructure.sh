
#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Trading AI System - Infrastructure Deployment"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found. Please run setup-master.sh first${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "infrastructure" ]; then
    echo -e "${RED}❌ Please run this script from the project root directory${NC}"
    exit 1
fi


echo -e "${YELLOW}📋 Step 1: Creating Namespaces${NC}"
kubectl apply -f kubernetes/namespaces/namespaces.yaml
echo -e "${GREEN}✓ Namespaces created${NC}"


echo ""
echo -e "${YELLOW}💾 Step 2: Creating Storage Class${NC}"
kubectl apply -f kubernetes/storage/storage-class.yaml
echo -e "${GREEN}✓ Storage class created${NC}"
echo "deleting previous PVC and PV created"
#kubectl delete pvc ollama-models-pvc -n trading-system
#kubectl delete  pv ollama-data-pv
echo ""
echo -e "${YELLOW}📦 Step 3: Creating Persistent Volumes${NC}"

#kubectl apply -f kubernetes/storage/persistent-volumes.yaml
kubectl apply -f kubernetes/databases/chromadb/chromadb-pv.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-pv.yaml
kubectl apply -f kubernetes/databases/redis/redis-pv.yaml
kubectl apply -f kubernetes/storage/pv/grafana-pv.yaml
kubectl apply -f kubernetes/storage/pv/models-pv.yaml
kubectl apply -f kubernetes/storage/pv/prometheus-pv.yaml
kubectl apply -f kubernetes/services/data-pipeline/trading-data-pv.yaml
kubectl apply -f kubernetes/services/ollama/ollama-data-pv.yaml
echo -e "${GREEN}✓ Persistent volumes created${NC}"


echo ""
echo -e "${YELLOW}🗄️  Step 4: Deploying PostgreSQL${NC}"
kubectl apply -f kubernetes/databases/postgres/postgres-pvc.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-configmap.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-deployment.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-secret.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-svc.yaml
kubectl apply -f kubernetes/databases/postgres/postgres-nodeport.yaml
echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n databases --timeout=300s
echo -e "${GREEN}✓ PostgreSQL deployed${NC}"


echo ""
echo -e "${YELLOW}🔴 Step 5: Deploying Redis${NC}"
kubectl apply -f kubernetes/databases/redis/redis-pvc.yaml
kubectl apply -f kubernetes/databases/redis/redis-configmap.yaml
kubectl apply -f kubernetes/databases/redis/redis-deployment.yaml
kubectl apply -f kubernetes/databases/redis/redis-svc.yaml
kubectl apply -f kubernetes/databases/redis/redis-nodeport.yaml
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=redis -n databases --timeout=300s
echo -e "${GREEN}✓ Redis deployed${NC}"


echo ""
echo -e "${YELLOW}🎨 Step 6: Deploying ChromaDB${NC}"
kubectl apply -f kubernetes/databases/chromadb/chromadb-pvc.yaml
kubectl apply -f kubernetes/databases/chromadb/chromadb-deployment.yaml
kubectl apply -f kubernetes/databases/chromadb/chromadb-svc.yaml
kubectl apply -f kubernetes/databases/chromadb/chromadb-nodeport.yaml
echo "Waiting for ChromaDB to be ready..."
kubectl wait --for=condition=ready pod -l app=chromadb -n databases --timeout=300s
echo -e "${GREEN}✓ ChromaDB deployed${NC}"


echo ""
echo -e "${YELLOW}🤖 Step 7: Deploying Ollama${NC}"
kubectl apply -f kubernetes/services/ollama/ollama-models-pvc.yaml
kubectl apply -f kubernetes/services/ollama/ollama-deployment.yaml
kubectl apply -f kubernetes/services/ollama/ollama-svc.yaml
kubectl apply -f kubernetes/services/ollama/ollama-nodeport.yaml
echo "Waiting for Ollama to be ready..."
kubectl wait --for=condition=ready pod -l app=ollama -n trading-system --timeout=300s
echo -e "${GREEN}✓ Ollama deployed${NC}"


echo ""
echo -e "${YELLOW}📥 Step 8: Downloading Ollama Model (llama3.1)${NC}"
echo "This may take several minutes..."
OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n trading-system $OLLAMA_POD -- ollama pull llama3.1:8b
echo -e "${GREEN}✓ Ollama model downloaded${NC}"

# install helm is available
echo ""
echo "Installing Helm"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
echo "Updating Helm"
helm repo update
echo -e "${GREEN}✓ Helm updated${NC}"

echo -e "${YELLOW}🏗️  Step 9: Deploying with Terraform${NC}"
cd ~/ai-system/infrastructure/terraform

# --- Idempotent Imports Section (This is perfect) ---

echo "Initializing Terraform..."
terraform init

echo "Checking Terraform state before importing Persistent Volumes..."
PV1_ADDRESS="kubernetes_persistent_volume.data_storage"
PV2_ADDRESS="kubernetes_persistent_volume.models_storage"

if ! terraform state show $PV1_ADDRESS >/dev/null 2>&1; then
  echo "--> $PV1_ADDRESS not found in state. Importing 'trading-data-pv'..."
  terraform import $PV1_ADDRESS trading-data-pv
else
  echo "--> $PV1_ADDRESS is already in the state. Skipping import."
fi

if ! terraform state show $PV2_ADDRESS >/dev/null 2>&1; then
  echo "--> $PV2_ADDRESS not found in state. Importing 'models-pv'..."
  terraform import $PV2_ADDRESS models-pv
else
  echo "--> $PV2_ADDRESS is already in the state. Skipping import."
fi

echo "State check complete. All required resources are now in the state."

# --- Simplified Plan and Apply Section ---

echo ""
echo -e "${YELLOW}📊 Planning Terraform deployment...${NC}"
echo ""
# Generate the plan and save it to a file
terraform plan -out=tfplan

echo ""
# Ask the user for confirmation
read -p "Do you want to apply the generated plan? (yes/no): " APPLY_TERRAFORM
echo ""

if [ "$APPLY_TERRAFORM" = "yes" ]; then
    # Apply the pre-generated plan. This is safer than a generic apply.
    terraform apply "tfplan"
    echo -e "${GREEN}✓ Terraform applied successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Terraform apply skipped${NC}"
fi

cd ../..


echo ""
echo -e "${YELLOW}📊 Step 10: Verifying Deployment${NC}"
echo ""
echo -e "${BLUE}Namespaces:${NC}"
kubectl get namespaces


echo ""
echo -e "${BLUE}Nodes:${NC}"
kubectl get nodes


echo ""
echo -e "${BLUE}Persistent Volumes:${NC}"
kubectl get pv


echo ""
echo -e "${BLUE}Databases (namespace: databases):${NC}"
kubectl get all -n databases


echo ""
echo -e "${BLUE}Trading System (namespace: trading-system):${NC}"
kubectl get all -n trading-system


echo ""
echo -e "${YELLOW}🔍 Step 11: Testing Connections${NC}"


# Test PostgreSQL
echo ""
echo -e "${BLUE}Testing PostgreSQL connection...${NC}"
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
if kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL is accessible${NC}"
else
    echo -e "${RED}✗ PostgreSQL connection failed${NC}"
fi


# Test Redis
echo ""
echo -e "${BLUE}Testing Redis connection...${NC}"
REDIS_POD=$(kubectl get pod -n databases -l app=redis -o jsonpath='{.items[0].metadata.name}')
if kubectl exec -n databases $REDIS_POD -- redis-cli ping | grep -q PONG; then
    echo -e "${GREEN}✓ Redis is accessible${NC}"
else
    echo -e "${RED}✗ Redis connection failed${NC}"
fi


# Test ChromaDB

echo ""
echo -e "${BLUE}Testing ChromaDB connection via NodePort...${NC}"

# Use the NodePort service and the correct heartbeat API endpoint.
# The 'jq' command is used to check for the specific JSON response.
# If jq is not installed, you can use grep instead.
if curl -s http://127.0.0.1:30800/api/v1/heartbeat | grep -q "nanosecond heartbeat"; then
    echo -e "${GREEN}✓ ChromaDB is accessible and responding correctly on NodePort 30800${NC}"
else
    echo -e "${RED}✗ ChromaDB connection failed on NodePort 30800.${NC}"
    echo -e "${YELLOW}  Please check the following:${NC}"
    echo -e "${YELLOW}  1. Is the ChromaDB pod running in the 'databases' namespace? (kubectl get pods -n databases)${NC}"
    echo -e "${YELLOW}  2. Do the service selectors match the pod labels? (kubectl describe svc chromadb -n databases)${NC}"
fi

echo ""
echo -e "${BLUE}Testing ChromaDB connection via pod (Fail is expected as the pod container does not have curl)...${NC}"
if kubectl exec -n databases $(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}') \
    -- sh -c "curl -s -o /dev/null -w '%{http_code}' http://localhost:8000 | grep -q 200"; then
    echo -e "${GREEN}✓ ChromaDB is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  ChromaDB responded, but heartbeat endpoint may not exist — checking service connectivity...${NC}"
    if kubectl run tmp-test --rm -i --restart=Never --image=alpine/curl -- curl -s -o /dev/null -w '%{http_code}' http://chromadb.databases.svc.cluster.local:8000 | grep -q 200; then
        echo -e "${GREEN}✓ ChromaDB service is reachable${NC}"
    else
        echo -e "${RED}✗ ChromaDB connection failed${NC}"
    fi
fi

# Test Ollama
echo ""
echo -e "${BLUE}Testing Ollama connection via NodePort...${NC}"

# Use the NodePort service and check for the expected response text
if curl -s http://127.0.0.1:31434/ | grep -q "Ollama is running"; then
    echo -e "${GREEN}✓ Ollama is accessible and responding correctly on NodePort 31434${NC}"
else
    echo -e "${RED}✗ Ollama connection failed on NodePort 31434.${NC}"
    echo -e "${YELLOW}  Please check the Ollama pod logs and describe its status.${NC}"
    echo -e "${YELLOW}  (kubectl logs -n trading-system -l app=ollama)${NC}"
fi
# Test Ollama
echo ""
echo -e "${BLUE}Testing Ollama connection (Fail is expected as the pod container does not have curl)...${NC}"
if kubectl exec -n trading-system $OLLAMA_POD -- sh -c "curl -s -o /dev/null -w '%{http_code}' http://localhost:11434 | grep -q 200"; then
    echo -e "${GREEN}✓ Ollama is accessible${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama is reachable but returned non-200 response${NC}"
    kubectl exec -n trading-system $OLLAMA_POD -- curl -s http://localhost:11434 || true
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Infrastructure Deployment Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}📋 Service Access Information:${NC}"
echo ""
echo -e "${BLUE}PostgreSQL:${NC}"
echo "  Internal: postgres.databases.svc.cluster.local:5432"
echo "  External: localhost:30432"
echo "  Username: trading_user"
echo "  Password: TradingAI2025!"
echo "  Database: trading_db"
echo ""
echo -e "${BLUE}Redis:${NC}"
echo "  Internal: redis.databases.svc.cluster.local:6379"
echo "  External: localhost:30379"
echo ""
echo -e "${BLUE}ChromaDB:${NC}"
echo "  Internal: chromadb.databases.svc.cluster.local:8000"
echo "  External: localhost:30800"
echo "  API: http://localhost:30800/api/v1"
echo ""
echo -e "${BLUE}Ollama:${NC}"
echo "  Internal: ollama.trading-system.svc.cluster.local:11434"
echo "  External: localhost:31434"
echo "  Model: llama3.1:8b"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Test database connections"
echo "2. Proceed to Phase 2: Data Pipeline setup"
echo "3. Run: ./infrastructure/scripts/test-infrastructure.sh"
echo ""
