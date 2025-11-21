#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔧 Trading AI System - Worker Node Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""


# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}❌ Please do not run as root${NC}"
    exit 1
fi


# Get master IP and token
read -p "Enter Master Node IP: " MASTER_IP
read -p "Enter K3s Token: " K3S_TOKEN
read -p "Enter Worker Node Name (e.g., k8sworker3): " WORKER_NAME


if [ -z "$MASTER_IP" ] || [ -z "$K3S_TOKEN" ] || [ -z "$WORKER_NAME" ]; then
    echo -e "${RED}❌ All fields are required${NC}"
    exit 1
fi


echo ""
echo -e "${YELLOW}📋 Step 1: System Update${NC}"
sudo apt update && sudo apt upgrade -y


echo ""
echo -e "${YELLOW}📦 Step 2: Installing Dependencies${NC}"
sudo apt install -y \
    curl \
    wget \
    htop \
    net-tools


echo ""
echo -e "${YELLOW}📁 Step 3: Creating Storage Directories (Worker Node Only)${NC}"
# CRITICAL: We only create directories needed by pods scheduled to this worker (k8sworker3),
# such as data-pipeline (/mnt/trading-data) and Ollama (/mnt/models).
sudo mkdir -p /mnt/trading-data
sudo mkdir -p /mnt/models
# Set ownership for the user running the K3s agent (usually 'root' or 'k3s', but this is safer)
sudo chown -R $USER:$USER /mnt/trading-data /mnt/models
sudo chmod -R 755 /mnt/trading-data /mnt/models
echo -e "${GREEN}✓ Worker storage directories created and permissions set${NC}"

echo ""
echo -e "${YELLOW}🐳 Step 4: Installing Docker (Required for Image Pulls/Registry)${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi

echo ""
echo -e "${YELLOW}🐳 Step 4.5: acepting insecure conecction from local registry service${NC}"
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

echo -e "${GREEN}✓ added unsecure local registry service running on master node${NC}"

echo ""
echo -e "${YELLOW}☸️  Step 5: Joining K3s Cluster${NC}"
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$K3S_TOKEN sh -s - agent --node-name $WORKER_NAME


echo ""
echo -e "${YELLOW}⏳ Waiting for node to be ready...${NC}"
sleep 10


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Worker Node Setup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Worker Name:${NC} $WORKER_NAME"
echo -e "${YELLOW}Master IP:${NC} $MASTER_IP"
echo ""
echo -e "${BLUE}On the master node, run:${NC}"
echo "kubectl get nodes"
echo ""
echo -e "${BLUE}You should see this worker node listed.${NC}"
echo ""
