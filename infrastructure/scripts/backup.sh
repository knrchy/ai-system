#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 Trading AI System - Backup"
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
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="trading-ai-backup-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"


echo -e "${YELLOW}📋 Backup Configuration:${NC}"
echo "Backup Directory: $BACKUP_DIR"
echo "Backup Name: $BACKUP_NAME"
echo "Timestamp: $TIMESTAMP"
echo ""


# Create backup directory
echo -e "${YELLOW}📁 Step 1: Creating Backup Directory${NC}"
sudo mkdir -p $BACKUP_PATH
echo -e "${GREEN}✓ Directory created: $BACKUP_PATH${NC}"


# Backup PostgreSQL
echo ""
echo -e "${YELLOW}🗄️  Step 2: Backing up PostgreSQL${NC}"
POSTGRES_POD=$(kubectl get pod -n databases -l app=postgres -o jsonpath='{.items[0].metadata.name}')


if [ -z "$POSTGRES_POD" ]; then
    echo -e "${RED}✗ PostgreSQL pod not found${NC}"
else
    kubectl exec -n databases $POSTGRES_POD -- pg_dump -U trading_user trading_db > $BACKUP_PATH/postgres_dump.sql
    echo -e "${GREEN}✓ PostgreSQL backup complete${NC}"
    echo "  File: $BACKUP_PATH/postgres_dump.sql"
    echo "  Size: $(du -h $BACKUP_PATH/postgres_dump.sql | cut -f1)"
fi


# Backup Redis
echo ""
echo -e "${YELLOW}🔴 Step 3: Backing up Redis${NC}"
REDIS_POD=$(kubectl get pod -n databases -l app=redis -o jsonpath='{.items[0].metadata.name}')


if [ -z "$REDIS_POD" ]; then
    echo -e "${RED}✗ Redis pod not found${NC}"
else
    # Trigger Redis save
    kubectl exec -n databases $REDIS_POD -- redis-cli SAVE
    # Copy dump file
    kubectl cp databases/$REDIS_POD:/data/dump.rdb $BACKUP_PATH/redis_dump.rdb
    echo -e "${GREEN}✓ Redis backup complete${NC}"
    echo "  File: $BACKUP_PATH/redis_dump.rdb"
    echo "  Size: $(du -h $BACKUP_PATH/redis_dump.rdb | cut -f1)"
fi


# Backup ChromaDB
echo ""
echo -e "${YELLOW}🎨 Step 4: Backing up ChromaDB${NC}"
CHROMADB_POD=$(kubectl get pod -n databases -l app=chromadb -o jsonpath='{.items[0].metadata.name}')


if [ -z "$CHROMADB_POD" ]; then
    echo -e "${RED}✗ ChromaDB pod not found${NC}"
else
    mkdir -p $BACKUP_PATH/chromadb
    kubectl cp databases/$CHROMADB_POD:/chroma/chroma $BACKUP_PATH/chromadb/
    echo -e "${GREEN}✓ ChromaDB backup complete${NC}"
    echo "  Directory: $BACKUP_PATH/chromadb/"
    echo "  Size: $(du -sh $BACKUP_PATH/chromadb/ | cut -f1)"
fi


# Backup Ollama models
echo ""
echo -e "${YELLOW}🤖 Step 5: Backing up Ollama Models${NC}"
OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')


if [ -z "$OLLAMA_POD" ]; then
    echo -e "${RED}✗ Ollama pod not found${NC}"
else
    mkdir -p $BACKUP_PATH/ollama
    kubectl cp trading-system/$OLLAMA_POD:/root/.ollama $BACKUP_PATH/ollama/
    echo -e "${GREEN}✓ Ollama models backup complete${NC}"
    echo "  Directory: $BACKUP_PATH/ollama/"
    echo "  Size: $(du -sh $BACKUP_PATH/ollama/ | cut -f1)"
fi


# Backup Kubernetes configurations
echo ""
echo -e "${YELLOW}☸️  Step 6: Backing up Kubernetes Configurations${NC}"
mkdir -p $BACKUP_PATH/k8s-configs


# Export all resources
kubectl get all --all-namespaces -o yaml > $BACKUP_PATH/k8s-configs/all-resources.yaml
kubectl get pv -o yaml > $BACKUP_PATH/k8s-configs/persistent-volumes.yaml
kubectl get pvc --all-namespaces -o yaml > $BACKUP_PATH/k8s-configs/persistent-volume-claims.yaml
kubectl get configmap --all-namespaces -o yaml > $BACKUP_PATH/k8s-configs/configmaps.yaml
kubectl get secret --all-namespaces -o yaml > $BACKUP_PATH/k8s-configs/secrets.yaml


echo -e "${GREEN}✓ Kubernetes configurations backup complete${NC}"


# Backup application data
echo ""
echo -e "${YELLOW}📊 Step 7: Backing up Application Data${NC}"
if [ -d "/mnt/trading-data" ]; then
    sudo rsync -av --progress /mnt/trading-data/ $BACKUP_PATH/trading-data/
    echo -e "${GREEN}✓ Trading data backup complete${NC}"
    echo "  Size: $(du -sh $BACKUP_PATH/trading-data/ | cut -f1)"
else
    echo -e "${YELLOW}⚠️  No trading data found${NC}"
fi


# Backup Terraform state
echo ""
echo -e "${YELLOW}🏗️  Step 8: Backing up Terraform State${NC}"
if [ -f "infrastructure/terraform/terraform.tfstate" ]; then
    cp infrastructure/terraform/terraform.tfstate $BACKUP_PATH/terraform.tfstate
    cp infrastructure/terraform/terraform.tfstate.backup $BACKUP_PATH/terraform.tfstate.backup 2>/dev/null || true
    echo -e "${GREEN}✓ Terraform state backup complete${NC}"
else
    echo -e "${YELLOW}⚠️  No Terraform state found${NC}"
fi


# Create backup manifest
echo ""
echo -e "${YELLOW}📝 Step 9: Creating Backup Manifest${NC}"
cat > $BACKUP_PATH/MANIFEST.txt << EOF
Trading AI System Backup
========================


Backup Date: $(date)
Backup Name: $BACKUP_NAME
Hostname: $(hostname)
Kubernetes Version: $(kubectl version --short 2>/dev/null | grep Server || echo "N/A")


Contents:
---------
$(ls -lh $BACKUP_PATH)


Total Backup Size: $(du -sh $BACKUP_PATH | cut -f1)


Restore Instructions:
--------------------
To restore this backup, run:
./infrastructure/scripts/restore.sh $BACKUP_NAME


EOF


echo -e "${GREEN}✓ Manifest created${NC}"


# Compress backup
echo ""
echo -e "${YELLOW}🗜️  Step 10: Compressing Backup${NC}"
cd $BACKUP_DIR
tar -czf ${BACKUP_NAME}.tar.gz $BACKUP_NAME
COMPRESSED_SIZE=$(du -h ${BACKUP_NAME}.tar.gz | cut -f1)
echo -e "${GREEN}✓ Backup compressed${NC}"
echo "  File: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "  Size: $COMPRESSED_SIZE"


# Cleanup uncompressed backup
read -p "Delete uncompressed backup? (yes/no): " DELETE_UNCOMPRESSED
if [ "$DELETE_UNCOMPRESSED" = "yes" ]; then
    sudo rm -rf $BACKUP_PATH
    echo -e "${GREEN}✓ Uncompressed backup deleted${NC}"
fi


# Calculate total size
TOTAL_SIZE=$(du -sh $BACKUP_DIR | cut -f1)


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Backup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Backup Details:${NC}"
echo "  Name: $BACKUP_NAME"
echo "  Location: $BACKUP_DIR/${BACKUP_NAME}.tar.gz"
echo "  Compressed Size: $COMPRESSED_SIZE"
echo "  Total Backups Size: $TOTAL_SIZE"
echo ""
echo -e "${YELLOW}To restore this backup:${NC}"
echo "  ./infrastructure/scripts/restore.sh $BACKUP_NAME"
echo ""
echo -e "${YELLOW}To list all backups:${NC}"
echo "  ls -lh $BACKUP_DIR/*.tar.gz"
echo ""
✅ File complete!
