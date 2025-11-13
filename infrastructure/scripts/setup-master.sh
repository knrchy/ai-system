#!/bin/bash


set -e


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Trading AI System - Master Node Setup"
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


echo -e "${YELLOW}📋 Step 1: System Update${NC}"
sudo apt update && sudo apt upgrade -y


echo ""
echo -e "${YELLOW}📦 Step 2: Installing Dependencies${NC}"
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    jq


echo ""
echo -e "${YELLOW}🐳 Step 3: Installing Docker${NC}"
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
echo -e "${YELLOW}🐳 Step 4: Installing Docker Compose${NC}"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
fi


echo ""
echo -e "${YELLOW}☸️  Step 5: Installing K3s${NC}"
if ! command -v k3s &> /dev/null; then
    curl -sfL https://get.k3s.io | sh -s - server \
        --write-kubeconfig-mode 644 \
        --disable traefik \
        --node-name trading-ai-master
    
    # Wait for K3s to be ready
    echo "Waiting for K3s to be ready..."
    sleep 10
    
    # Setup kubeconfig
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown $USER:$USER ~/.kube/config
    export KUBECONFIG=~/.kube/config
    
    # Add to bashrc
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
    
    echo -e "${GREEN}✓ K3s installed${NC}"
else
    echo -e "${GREEN}✓ K3s already installed${NC}"
fi


echo ""
echo -e "${YELLOW}⎈ Step 6: Installing kubectl${NC}"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo -e "${GREEN}✓ kubectl installed${NC}"
else
    echo -e "${GREEN}✓ kubectl already installed${NC}"
fi


echo ""
echo -e "${YELLOW}⚓ Step 7: Installing Helm${NC}"
if ! command -v helm &> /dev/null; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo -e "${GREEN}✓ Helm installed${NC}"
else
    echo -e "${GREEN}✓ Helm already installed${NC}"
fi


echo ""
echo -e "${YELLOW}🏗️  Step 8: Installing Terraform${NC}"
if ! command -v terraform &> /dev/null; then
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform -y
    echo -e "${GREEN}✓ Terraform installed${NC}"
else
    echo -e "${GREEN}✓ Terraform already installed${NC}"
fi


echo ""
echo -e "${YELLOW}📁 Step 9: Creating Storage Directories${NC}"
sudo mkdir -p /mnt/trading-data
sudo mkdir -p /mnt/models
sudo mkdir -p /mnt/postgres-data
sudo mkdir -p /mnt/redis-data
sudo mkdir -p /mnt/chromadb-data
sudo chown -R $USER:$USER /mnt/trading-data /mnt/models
sudo chmod -R 755 /mnt/trading-data /mnt/models
echo -e "${GREEN}✓ Storage directories created${NC}"


echo ""
echo -e "${YELLOW}🐍 Step 10: Installing Python and pip${NC}"
sudo apt install -y python3 python3-pip python3-venv
echo -e "${GREEN}✓ Python installed${NC}"


echo ""
echo -e "${YELLOW}📊 Step 11: Verifying Installation${NC}"
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker-compose --version
echo ""
echo "K3s version:"
k3s --version
echo ""
echo "kubectl version:"
kubectl version --client
echo ""
echo "Helm version:"
helm version
echo ""
echo "Terraform version:"
terraform --version
echo ""
echo "Python version:"
python3 --version


echo ""
echo -e "${YELLOW}⚙️  Step 12: Checking K3s Cluster${NC}"
kubectl get nodes
echo ""
kubectl get pods -A


echo ""
echo -e "${YELLOW}🔑 Step 13: Getting K3s Token for Worker Nodes${NC}"
K3S_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)
MASTER_IP=$(hostname -I | awk '{print $1}')


echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Save this information for adding worker nodes:${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Master IP:${NC} $MASTER_IP"
echo -e "${YELLOW}K3s Token:${NC} $K3S_TOKEN"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"


# Save to file
cat > ~/k3s-join-info.txt << EOF
Master IP: $MASTER_IP
K3s Token: $K3S_TOKEN


To join a worker node, run:
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$K3S_TOKEN sh -
EOF


echo ""
echo -e "${GREEN}✓ Join information saved to ~/k3s-join-info.txt${NC}"


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Master Node Setup Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Log out and log back in for Docker group to take effect"
echo "2. Run: source ~/.bashrc"
echo "3. Navigate to your project directory"
echo "4. Run: ./infrastructure/scripts/deploy-infrastructure.sh"
echo ""
echo -e "${BLUE}To add worker nodes, use the information in ~/k3s-join-info.txt${NC}"
echo ""
