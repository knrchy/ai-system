#!/bin/bash

# If not already installed, download Ubuntu 22.04 LTS Server
# Recommended: Fresh installation or dedicated partition
echo "============================================================================"
echo "Updating system..."
sudo apt update && sudo apt upgrade -y
echo "============================================================================"


echo "============================================================================"
echo "Installing essential tools..."
sudo apt install -y \
    curl \
    wget \
    git \
    nano \
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
echo "Tools installation complete."
echo "============================================================================"

echo "============================================================================"
echo "Setting hostname and /etc/hosts configuration..."
# Prompt the user for the IP address
read -p "Enter your IP address: " YOUR_IP

echo "Setting hostname..."
sudo hostnamectl set-hostname trading-ai-master

echo "Configuring /etc/hosts..."
sudo bash -c "echo '127.0.0.1 trading-ai-master' >> /etc/hosts"
sudo bash -c "echo '$YOUR_IP trading-ai-master' >> /etc/hosts"

echo "Hostname and network configuration done."
echo "============================================================================"


echo "============================================================================"
echo "Removing old Docker versions..."
sudo apt remove -y docker docker-engine docker.io containerd runc

echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

echo "Adding user to docker group..."
sudo usermod -aG docker $USER
newgrp docker

echo "Verifying Docker installation..."
docker --version
docker run hello-world

echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo "Docker installation complete."
echo "============================================================================"


echo "============================================================================"
echo "Installing K3s master..."
curl -sfL https://get.k3s.io | sh -s - server \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --node-name trading-ai-master

echo "Verifying K3s installation..."
sudo systemctl status k3s

echo "Setting up kubectl..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "Verifying cluster..."
kubectl get nodes
kubectl get pods -A

echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

echo "K3s installation complete."
echo "============================================================================"


echo "============================================================================"
echo "Creating .gitignore file..."
cat > .gitignore << 'EOF'
# Trading AI System - Git Ignore Rules


# ============================================
# Terraform
# ============================================
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
.terraform.lock.hcl
terraform.tfstate.d/
crash.log
crash.*.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc


# ============================================
# Python
# ============================================
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class


# C extensions
*.so


# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST


# PyInstaller
*.manifest
*.spec


# Installer logs
pip-log.txt
pip-delete-this-directory.txt


# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/


# Translations
*.mo
*.pot


# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal


# Flask stuff:
instance/
.webassets-cache


# Scrapy stuff:
.scrapy


# Sphinx documentation
docs/_build/


# PyBuilder
.pybuilder/
target/


# Jupyter Notebook
.ipynb_checkpoints


# IPython
profile_default/
ipython_config.py


# pyenv
.python-version


# pipenv
Pipfile.lock


# poetry
poetry.lock


# pdm
.pdm.toml


# PEP 582
__pypackages__/


# Celery stuff
celerybeat-schedule
celerybeat.pid


# SageMath parsed files
*.sage.py


# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/


# Spyder project settings
.spyderproject
.spyproject


# Rope project settings
.ropeproject


# mkdocs documentation
/site


# mypy
.mypy_cache/
.dmypy.json
dmypy.json


# Pyre type checker
.pyre/


# pytype static type analyzer
.pytype/


# Cython debug symbols
cython_debug/


# ============================================
# Kubernetes
# ============================================
*.kubeconfig
kubeconfig
.kube/config.backup
*-kubeconfig.yaml


# ============================================
# Data Files
# ============================================
# Raw trading data
data/raw/*
!data/raw/.gitkeep


# Processed data
data/processed/*
!data/processed/.gitkeep


# Embeddings
data/embeddings/*
!data/embeddings/.gitkeep


# ML Models
data/models/*
!data/models/.gitkeep


# Backups
/mnt/backups/*
*.tar.gz
*.zip
*.sql
*.dump
*.rdb


# Large files
*.csv
*.json
*.parquet
*.feather
*.hdf5
*.h5


# Exception: Keep sample/test files
!**/sample*.csv
!**/test*.json
!**/example*.csv


# ============================================
# Secrets & Credentials
# ============================================
*.key
*.pem
*.crt
*.cer
*.p12
*.pfx
secrets/
.secrets/
credentials/
.credentials/
*.env
.env.*
!.env.example


# SSH keys
id_rsa
id_rsa.pub
id_ed25519
id_ed25519.pub


# API keys
*api_key*
*apikey*
*API_KEY*


# Passwords
*password*
*PASSWORD*


# Tokens
*token*
*TOKEN*


# ============================================
# IDE & Editors
# ============================================
# VSCode
.vscode/
*.code-workspace


# PyCharm
.idea/
*.iml
*.iws
*.ipr


# Sublime Text
*.sublime-project
*.sublime-workspace


# Vim
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
[._]s[a-rt-v][a-z]
[._]ss[a-gi-z]
[._]sw[a-p]
Session.vim
Sessionx.vim
.netrwhist
*~
tags
[._]*.un~


# Emacs
*~
\#*\#
/.emacs.desktop
/.emacs.desktop.lock
*.elc
auto-save-list
tramp
.\#*


# Atom
.atom/


# ============================================
# Operating System
# ============================================
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk


# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msix
*.msm
*.msp
*.lnk


# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*


# ============================================
# Logs
# ============================================
*.log
logs/
*.log.*
log/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*
.pnpm-debug.log*


# ============================================
# Temporary Files
# ============================================
tmp/
temp/
*.tmp
*.temp
*.swp
*.swo
*.bak
*.backup
*.old
*~


# ============================================
# Docker
# ============================================
.dockerignore
docker-compose.override.yml
.docker/


# ============================================
# Node.js (if used for frontend)
# ============================================
node_modules/
npm-debug.log
yarn-error.log
.npm
.eslintcache
.node_repl_history
*.tgz
.yarn-integrity


# ============================================
# Application Specific
# ============================================
# cTrader exports (keep in data/raw/)
*.cbot
*.algo


# Backtest results (large files)
backtest-results/
optimization-results/


# Cache directories
.cache/
cache/
__cache__/


# Build artifacts
build/
dist/
out/


# Database files (local development)
*.db
*.sqlite
*.sqlite3


# Redis dumps
dump.rdb
appendonly.aof


# PostgreSQL
*.sql.gz


# ============================================
# Project Specific
# ============================================
# K3s join info (contains sensitive token)
k3s-join-info.txt


# Local configuration overrides
config.local.yaml
config.local.yml
config.local.json


# Test outputs
test-output/
test-results/


# Coverage reports
coverage/
.coverage


# Benchmark results
benchmark-results/


# Generated documentation
docs/generated/


# ============================================
# Keep These Files
# ============================================
!.gitkeep
!README.md
!LICENSE
!CONTRIBUTING.md
!.env.example
!docker-compose.yml
!Dockerfile
!Makefile
EOF
echo "✅ .gitignore complete!"

echo "Initializing Git repository..."
echo "Creating .gitkeep files for empty directories..."
find data -type d -exec touch {}/.gitkeep \;

echo "Performing initial commit..."
git add .
git commit -m "Initial project structure"

echo "Git repository setup complete."
echo "============================================================================"

echo "============================================================================"
# Install Terraform
echo "Installing Terraform..."

# Add HashiCorp GPG key
sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add the HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install Terraform
##please note that if Ubuntu version is to updated, script may fail as no terraform available for ubuntu version.
sudo apt update && sudo apt install -y terraform

# Verify the installation
echo "Verifying Terraform installation..."
terraform --version

# Create the directory for Terraform files
# Navigate to the Terraform directory
cd ~/ai-system/infrastructure/terraform

# Init terraform
terraform init

echo "Deleting previous namespaces and storage class created before with other resources"

kubectl delete ns trading-system databases monitoring
kubectl delete sc local-storage 
kubectl delete pv trading-data-pv models-pv

# plan terraform
terraform plan

echo "importing previous namespaces and storage class created before with other resources"
terraform import kubernetes_namespace.trading_system trading-system
terraform import kubernetes_namespace.monitoring monitoring
terraform import kubernetes_namespace.databases databases
terraform import kubernetes_storage_class.local_storage local-storage
terraform import kubernetes_persistent_volume.data_storage trading-data-pv
terraform import kubernetes_persistent_volume.models_storage models-pv

echo "Terraform configuration files created successfully."
echo "============================================================================"


echo "============================================================================"
echo "KUBECONFIG configuration files created successfully."
# kubeconfig path variable
KUBECONFIG=~/.kube/config
echo "Kubernetes manifest files created successfully."
echo "============================================================================"


echo "============================================================================"
echo "Making scripts executable..."
cd ~/ai-system/
find . -name "*.sh" -exec chmod +x {} \;
echo "Scripts are now executable."
echo "============================================================================"


echo "============================================================================"
echo "KUBECONFIG configuration files created successfully."
./infrastructure/scripts/setup-master.sh
echo "Kubernetes manifest files created successfully."
echo "============================================================================"
