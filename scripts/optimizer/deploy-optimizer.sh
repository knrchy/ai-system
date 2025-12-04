#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying Optimizer Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


echo -e "${YELLOW}Step 1: Creating database tables${NC}"
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')


kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db << 'EOF'
CREATE TABLE IF NOT EXISTS optimization_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    backtest_id UUID NOT NULL,
    optimization_type VARCHAR(50) NOT NULL,
    parameter_ranges JSONB,
    total_tasks INTEGER,
    completed_tasks INTEGER DEFAULT 0,
    failed_tasks INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'pending',
    celery_task_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);


CREATE TABLE IF NOT EXISTS optimization_results (
    id SERIAL PRIMARY KEY,
    optimization_id UUID NOT NULL,
    parameters JSONB NOT NULL,
    net_profit DECIMAL(18, 2),
    win_rate DECIMAL(5, 2),
    profit_factor DECIMAL(10, 4),
    sharpe_ratio DECIMAL(10, 4),
    max_drawdown DECIMAL(18, 2),
    metrics JSONB,
    rank INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX IF NOT EXISTS idx_optimization_jobs_backtest ON optimization_jobs(backtest_id);
CREATE INDEX IF NOT EXISTS idx_optimization_results_optimization ON optimization_results(optimization_id);
CREATE INDEX IF NOT EXISTS idx_optimization_results_rank ON optimization_results(rank);
EOF


echo -e "${GREEN}✓ Database tables created${NC}"
echo ""


echo -e "${YELLOW}Step 2: Building Docker image${NC}"
./scripts/optimizer/build-optimizer.sh


echo ""
echo -e "${YELLOW}Step 3: Deploying to Kubernetes${NC}"
kubectl apply -f kubernetes/services/optimizer/deployment.yaml


echo ""
echo -e "${YELLOW}Step 4: Waiting for deployments...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/optimizer-api -n trading-system
kubectl wait --for=condition=available --timeout=300s deployment/celery-worker -n trading-system
kubectl wait --for=condition=available --timeout=300s deployment/flower -n trading-system


echo ""
echo -e "${GREEN}✓ Optimizer deployed successfully${NC}"
echo ""


echo -e "${BLUE}Service Information:${NC}"
echo "  Optimizer API: http://localhost:30802"
echo "  Flower (Monitoring): http://localhost:30555"
echo ""
echo -e "${BLUE}API Documentation:${NC}"
echo "  Swagger UI: http://localhost:30802/docs"
echo ""


echo -e "${YELLOW}Testing endpoint...${NC}"
sleep 5
curl -s http://localhost:30802/health | jq '.'


echo ""
echo -e "${YELLOW}Checking workers...${NC}"
curl -s http://localhost:30802/api/v1/workers/status | jq '.'


echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
echo -e "${BLUE}Access Flower monitoring at: http://localhost:30555${NC}"
echo ""
