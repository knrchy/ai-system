#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "♻️  Trading AI System - Restore"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Configuration
BACKUP_DIR="/mnt/backups"


# Check if backup name provided
if [ -z "$1" ]; then
    echo -e "${YELLOW}Available backups:${NC}"
    echo ""
    ls -lh $BACKUP_DIR/*.tar.gz 2>/dev/null || echo "No backups found"
    echo ""
    echo -e "${RED}Usage: $0 <backup-name>${NC}"
    echo "Example: $0 trading-ai-backup-20251031_120000"
    exit 1
fi


BACKUP_NAME=$1
BACKUP_FILE="$BACKUP_DIR/${BACKUP_NAME}.tar.gz"
RESTORE_PATH="$BACKUP_DIR/$BACKUP_NAME"


# Check if backup exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi


echo -e "${YELLOW}📋 Restore Configuration:${NC}"
echo "Backup File: $BACKUP_FILE"
echo "Backup Size: $(du -h $BACKUP_FILE | cut -f1)"
echo ""


echo -e "${RED}⚠️  WARNING: This will overwrite existing data!${NC}"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " CONFIRM


if [ "$CONFIRM" != "yes" ]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
    exit 0
fi


# Extract backup
echo ""
echo -e "${YELLOW}📦 Step 1: Extracting Backup${NC}"
cd $BACKUP_DIR
tar -xzf ${BACKUP_NAME}.tar.gz
echo -e "${GREEN}✓ Backup extracted to: $RESTORE_PATH${NC}"


# Display manifest
echo ""
echo -e "${YELLOW}📝 Backup Manifest:${NC}"
cat $RESTORE_PATH/MANIFEST.txt
echo ""


read -p "Continue with restore? (yes/no): " CONTINUE
if [ "$CONTINUE" != "yes" ]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
    sudo rm -rf $RESTORE_PATH
    exit 0
fi


# Restore PostgreSQL
echo ""
echo -e "${YELLOW}🗄️  Step 2: Restoring PostgreSQL${NC}"
if [ -f "$RESTORE_PATH/postgres_dump.sql" ]; then
    POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$POSTGRES_POD" ]; then
        echo -e "${RED}✗ PostgreSQL pod not found. Please deploy infrastructure first.${NC}"
    else
        # Drop and recreate database
        kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d postgres -c "DROP DATABASE IF EXISTS trading_db;"
        kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d postgres -c "CREATE DATABASE trading_db;"
        
        # Restore dump
        cat $RESTORE_PATH/postgres_dump.sql | kubectl exec -i -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db
        
        echo -e "${GREEN}✓ PostgreSQL restored${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No PostgreSQL backup found${NC}"
fi


# Restore Redis
echo ""
echo -e "${YELLOW}🔴 Step 3: Restoring Redis${NC}"
if [ -f "$RESTORE_PATH/redis_dump.rdb" ]; then
    REDIS_POD=$(kubectl get pod -n databases -l app=redis -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$REDIS_POD" ]; then
        echo -e "${RED}✗ Redis pod not found. Please deploy infrastructure first.${NC}"
    else
        # Stop Redis
        kubectl exec -n databases $REDIS_POD -- redis-cli SHUTDOWN NOSAVE || true
        sleep 5
        
        # Copy dump file
        kubectl cp $RESTORE_PATH/redis_dump.rdb databases/$REDIS_POD:/data/dump.rdb
        
        # Restart Redis pod
        kubectl delete pod -n databases $REDIS_POD
        echo "Waiting for Redis to restart..."
        sleep 10
        kubectl wait --for=condition=ready pod -l app=redis -n databases --timeout=120s
        
        echo -e "${GREEN}✓ Redis restored${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No Redis backup found${NC}"
fi


# Restore ChromaDB
echo ""
echo -e "${YELLOW}🎨 Step 4: Restoring ChromaDB${NC}"
if [ -d "$RESTORE_PATH/chromadb" ]; then
    CHROMADB_POD=$(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$CHROMADB_POD" ]; then
        echo -e "${RED}✗ ChromaDB pod not found. Please deploy infrastructure first.${NC}"
    else
        # Delete pod to stop ChromaDB
        kubectl delete pod -n databases $CHROMADB_POD
        sleep 5
        
        # Copy data
        kubectl wait --for=condition=ready pod -l app=chromadb -n databases --timeout=120s
        CHROMADB_POD=$(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}')
        kubectl cp $RESTORE_PATH/chromadb databases/$CHROMADB_POD:/chroma/
        
        # Restart pod
        kubectl delete pod -n databases $CHROMADB_POD
        echo "Waiting for ChromaDB to restart..."
        kubectl wait --for=condition=ready pod -l app=chromadb -n databases --timeout=120s
        
        echo -e "${GREEN}✓ ChromaDB restored${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No ChromaDB backup found${NC}"
fi


# Restore Ollama models
echo ""
echo -e "${YELLOW}🤖 Step 5: Restoring Ollama Models${NC}"
if [ -d "$RESTORE_PATH/ollama" ]; then
    OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')
    
    if [ -z "$OLLAMA_POD" ]; then
        echo -e "${RED}✗ Ollama pod not found. Please deploy infrastructure first.${NC}"
    else
        kubectl cp $RESTORE_PATH/ollama trading-system/$OLLAMA_POD:/root/.ollama
        
        # Restart pod
        kubectl delete pod -n trading-system $OLLAMA_POD
        echo "Waiting for Ollama to restart..."
        kubectl wait --for=condition=ready pod -l app=ollama -n trading-system --timeout=120s
        
        echo -e "${GREEN}✓ Ollama models restored${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No Ollama backup found${NC}"
fi


# Restore application data
echo ""
echo -e "${YELLOW}📊 Step 6: Restoring Application Data${NC}"
if [ -d "$RESTORE_PATH/trading-data" ]; then
    sudo rsync -av --progress $RESTORE_PATH/trading-data/ /mnt/trading-data/
    echo -e "${GREEN}✓ Trading data restored${NC}"
else
    echo -e "${YELLOW}⚠️  No trading data backup found${NC}"
fi


# Restore Terraform state
echo ""
echo -e "${YELLOW}🏗️  Step 7: Restoring Terraform State${NC}"
if [ -f "$RESTORE_PATH/terraform.tfstate" ]; then
    cp $RESTORE_PATH/terraform.tfstate infrastructure/terraform/terraform.tfstate
    [ -f "$RESTORE_PATH/terraform.tfstate.backup" ] && cp $RESTORE_PATH/terraform.tfstate.backup infrastructure/terraform/terraform.tfstate.backup
    echo -e "${GREEN}✓ Terraform state restored${NC}"
else
    echo -e "${YELLOW}⚠️  No Terraform state backup found${NC}"
fi


# Verify restoration
echo ""
echo -e "${YELLOW}🔍 Step 8: Verifying Restoration${NC}"


# Test PostgreSQL
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$POSTGRES_POD" ]; then
    if kubectl exec -n databases $POSTGRES_POD -- psql -U trading_user -d trading_db -c "SELECT COUNT(*) FROM information_schema.tables;" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PostgreSQL is accessible${NC}"
    else
        echo -e "${RED}✗ PostgreSQL verification failed${NC}"
    fi
fi


# Test Redis
REDIS_POD=$(kubectl get pod -n databases -l app=redis -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$REDIS_POD" ]; then
    if kubectl exec -n databases $REDIS_POD -- redis-cli ping | grep -q PONG; then
        echo -e "${GREEN}✓ Redis is accessible${NC}"
    else
        echo -e "${RED}✗ Redis verification failed${NC}"
    fi
fi


# Test ChromaDB
CHROMADB_POD=$(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$CHROMADB_POD" ]; then
    if kubectl exec -n databases $CHROMADB_POD -- curl -s http://localhost:8000/api/v1/heartbeat > /dev/null 2>&1; then
        echo -e "${GREEN}✓ ChromaDB is accessible${NC}"
    else
        echo -e "${RED}✗ ChromaDB verification failed${NC}"
    fi
fi


# Cleanup extracted backup
echo ""
read -p "Delete extracted backup files? (yes/no): " DELETE_EXTRACTED
if [ "$DELETE_EXTRACTED" = "yes" ]; then
    sudo rm -rf $RESTORE_PATH
    echo -e "${GREEN}✓ Extracted backup deleted${NC}"
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Restore Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Verify all services are running: kubectl get pods -A"
echo "2. Test database connections"
echo "3. Run infrastructure tests: ./infrastructure/scripts/test-infrastructure.sh"
echo ""
✅ File complete!
