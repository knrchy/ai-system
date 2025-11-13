# Phase 1: Infrastructure Foundation


> Complete guide for setting up the Trading AI System infrastructure


**Duration**: 2-3 days  
**Difficulty**: Intermediate  
**Prerequisites**: Ubuntu 22.04 LTS, sudo access


---


## 📋 Table of Contents


1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Step-by-Step Guide](#step-by-step-guide)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)
6. [Next Steps](#next-steps)


---


## 🎯 Overview


Phase 1 establishes the foundational infrastructure for the Trading AI System:


**What You'll Build**:
- ✅ K3s Kubernetes cluster
- ✅ PostgreSQL database
- ✅ Redis cache & message broker
- ✅ ChromaDB vector database
- ✅ Ollama LLM service
- ✅ Prometheus + Grafana monitoring
- ✅ Persistent storage
- ✅ Automated backup system


**What You'll Learn**:
- Kubernetes basics
- Infrastructure as Code with Terraform
- Container orchestration
- Database management
- Monitoring setup


---


## 📦 Prerequisites


### Hardware Requirements


**Master Node (Minimum)**:
- CPU: 4 cores
- RAM: 16GB (24GB recommended)
- Storage: 500GB SSD
- Network: 1 Gbps


**Your Setup**:
- CPU: Intel i7 5th gen ✅
- RAM: 24GB ✅
- Storage: 2TB ✅


### Software Requirements


- **OS**: Ubuntu 22.04 LTS Server
- **User**: Non-root user with sudo privileges
- **Network**: Static IP address (recommended)
- **Internet**: Required for initial setup


---


## 🚀 Step-by-Step Guide


### Step 1: Prepare the System


**1.1 Update System**


```bash
sudo apt update && sudo apt upgrade -y
sudo reboot
1.2 Set Hostname


-----------------------------------0-----------------------------------------
sudo hostnamectl set-hostname trading-ai-master


# Verify
hostnamectl
1.3 Configure Firewall (Optional)


-----------------------------------0-----------------------------------------
# Install UFW
sudo apt install ufw -y


# Allow SSH
sudo ufw allow 22/tcp


# Allow K3s
sudo ufw allow 6443/tcp
sudo ufw allow 10250/tcp


# Enable firewall
sudo ufw enable
Step 2: Clone Repository
-----------------------------------0-----------------------------------------
# Install git if not present
sudo apt install git -y


# Clone repository
cd ~
git clone https://github.com/yourusername/trading-ai-system.git
cd trading-ai-system


# Make scripts executable
chmod +x infrastructure/scripts/*.sh
chmod +x scripts/*.sh
Step 3: Run Master Node Setup
-----------------------------------0-----------------------------------------
./infrastructure/scripts/setup-master.sh
This script will:


Install Docker & Docker Compose
Install K3s (Kubernetes)
Install kubectl & Helm
Install Terraform
Create storage directories
Install Python 3
Expected Duration: 10-15 minutes


Output Example:


-----------------------------------...-----------------------------------------
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Trading AI System - Master Node Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


✓ Docker installed
✓ K3s installed
✓ kubectl installed
✓ Helm installed
✓ Terraform installed
✓ Storage directories created


✅ Master Node Setup Complete!
Step 4: Log Out and Back In
Important: This is required for Docker group membership to take effect.


-----------------------------------0-----------------------------------------
# Log out
exit


# SSH back in
ssh user@your-server


# Verify Docker works without sudo
docker ps
Step 5: Deploy Infrastructure
-----------------------------------0-----------------------------------------
cd ~/trading-ai-system


./infrastructure/scripts/deploy-infrastructure.sh
This script will:


Create Kubernetes namespaces
Deploy PostgreSQL
Deploy Redis
Deploy ChromaDB
Deploy Ollama
Download Llama 3.1 model (~4.7GB)
Apply Terraform configuration
Run health checks
Expected Duration: 20-30 minutes


Progress Indicators:


-----------------------------------...-----------------------------------------
📋 Step 1: Creating Namespaces
✓ Namespaces created


🗄️  Step 2: Deploying PostgreSQL
Waiting for PostgreSQL to be ready...
✓ PostgreSQL deployed


🔴 Step 3: Deploying Redis
✓ Redis deployed


🎨 Step 4: Deploying ChromaDB
✓ ChromaDB deployed


🤖 Step 5: Deploying Ollama
✓ Ollama deployed


📥 Step 6: Downloading Ollama Model
This may take several minutes...
✓ Ollama model downloaded
Step 6: Verify Installation
-----------------------------------0-----------------------------------------
./infrastructure/scripts/test-infrastructure.sh
Expected Output:


-----------------------------------...-----------------------------------------
🧪 Running Infrastructure Tests...


Testing: Kubernetes cluster connectivity
✓ PASSED


Testing: All nodes are ready
✓ PASSED


Testing: PostgreSQL pod is running
✓ PASSED


Testing: Redis pod is running
✓ PASSED


Testing: ChromaDB pod is running
✓ PASSED


Testing: Ollama pod is running
✓ PASSED


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Test Results Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Passed: 18
Failed: 0


✅ All tests passed! Infrastructure is ready.
✅ Verification
Check Cluster Status
-----------------------------------0-----------------------------------------
# View nodes
kubectl get nodes


# Expected output:
# NAME                STATUS   ROLES                  AGE   VERSION
# trading-ai-master   Ready    control-plane,master   10m   v1.28.x
Check All Pods
-----------------------------------0-----------------------------------------
# View all pods
kubectl get pods -A


# Expected output: All pods should be "Running"
Check Services
-----------------------------------0-----------------------------------------
# View services
kubectl get svc -A


# You should see:
# - postgres (ClusterIP + NodePort)
# - redis (ClusterIP + NodePort)
# - chromadb (ClusterIP + NodePort)
# - ollama (ClusterIP + NodePort)
Test Database Connections
PostgreSQL:


-----------------------------------0-----------------------------------------
# From host machine
psql -h localhost -p 30432 -U trading_user -d trading_db


# Password: TradingAI2025!


# Run test query
SELECT version();


# Exit
\q
Redis:


-----------------------------------0-----------------------------------------
# From host machine
redis-cli -h localhost -p 30379


# Test
PING
# Should return: PONG


# Exit
exit
ChromaDB:


-----------------------------------0-----------------------------------------
# Test API
curl http://localhost:30800/api/v1/heartbeat


# Should return heartbeat timestamp
Ollama:


-----------------------------------0-----------------------------------------
# Test LLM
curl http://localhost:31434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Say hello",
  "stream": false
}'


# Should return generated text
🐛 Troubleshooting
Issue 1: Pods Not Starting
Symptoms:


-----------------------------------0-----------------------------------------
kubectl get pods -A
# Shows pods in "Pending" or "CrashLoopBackOff"
Solution:


-----------------------------------0-----------------------------------------
# Check pod details
kubectl describe pod <pod-name> -n <namespace>


# Check logs
kubectl logs <pod-name> -n <namespace>


# Common fixes:
# 1. Insufficient resources
kubectl top nodes


# 2. Storage issues
kubectl get pv
kubectl get pvc -A


# 3. Restart pod
kubectl delete pod <pod-name> -n <namespace>
Issue 2: K3s Not Starting
Symptoms:


-----------------------------------0-----------------------------------------
sudo systemctl status k3s
# Shows "failed" or "inactive"
Solution:


-----------------------------------0-----------------------------------------
# Check logs
sudo journalctl -u k3s -f


# Restart K3s
sudo systemctl restart k3s


# If still failing, reinstall
curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode 644
Issue 3: Cannot Connect to Databases
Symptoms:


-----------------------------------0-----------------------------------------
psql -h localhost -p 30432 -U trading_user -d trading_db
# Connection refused
Solution:


-----------------------------------0-----------------------------------------
# 1. Check if pod is running
kubectl get pods -n databases


# 2. Check service
kubectl get svc -n databases postgres-nodeport


# 3. Check if port is listening
sudo netstat -tulpn | grep 30432


# 4. Port forward as alternative
kubectl port-forward -n databases svc/postgres 5432:5432
# Then connect to localhost:5432
Issue 4: Ollama Model Download Fails
Symptoms:


-----------------------------------...-----------------------------------------
Error downloading model
Solution:


-----------------------------------0-----------------------------------------
# Manual download
OLLAMA_POD=$(kubectl get pod -n trading-system -l app=ollama -o jsonpath='{.items[0].metadata.name}')


kubectl exec -n trading-system $OLLAMA_POD -- ollama pull llama3.1:8b


# Check available models
kubectl exec -n trading-system $OLLAMA_POD -- ollama list
Issue 5: Insufficient Storage
Symptoms:


-----------------------------------...-----------------------------------------
Error: no space left on device
Solution:


-----------------------------------0-----------------------------------------
# Check disk usage
df -h


# Clean Docker images
docker system prune -a


# Clean old K3s images
sudo k3s crictl rmi --prune


# Check PV usage
kubectl get pv
📊 Resource Usage
Expected Resource Consumption (after full deployment):


Component	CPU	Memory	Storage
K3s System	500m	1GB	-
PostgreSQL	1000m	2-4GB	100GB
Redis	500m	1-2GB	20GB
ChromaDB	1000m	2-4GB	50GB
Ollama	2000m	4-8GB	50GB
Monitoring	1000m	2GB	50GB
Total	6-7 cores	12-21GB	270GB
Your System: i7 5th gen (4 cores), 24GB RAM, 2TB storage
Status: ✅ Sufficient (will use ~70% RAM under load)


🎯 Next Steps
Immediate Actions
Change Default Passwords:
-----------------------------------0-----------------------------------------
# PostgreSQL
kubectl exec -it -n databases <postgres-pod> -- psql -U trading_user -d postgres
ALTER USER trading_user WITH PASSWORD 'YourSecurePassword';


# Update in secrets
kubectl edit secret postgres-secret -n databases
Access Grafana Dashboard:
-----------------------------------...-----------------------------------------
URL: http://localhost:30300
Username: admin
Password: admin (change on first login)
Create First Backup:
-----------------------------------0-----------------------------------------
./infrastructure/scripts/backup.sh
Proceed to Phase 2
Once all tests pass, you're ready for Phase 2: Data Pipeline


-----------------------------------0-----------------------------------------
# Phase 2 will cover:
# - Parsing cTrader JSON exports
# - Loading data into PostgreSQL
# - Data validation and cleaning
# - Basic SQL queries
See: PHASE-2-data-pipeline.md


📚 Additional Resources
Useful Commands
-----------------------------------0-----------------------------------------
# View all resources
kubectl get all -A


# View logs
kubectl logs -f -n <namespace> <pod-name>


# Execute commands in pod
kubectl exec -it -n <namespace> <pod-name> -- /bin/bash


# Port forward
kubectl port-forward -n <namespace> <pod-name> <local-port>:<pod-port>


# Describe resource
kubectl describe <resource-type> <resource-name> -n <namespace>


# Delete resource
kubectl delete <resource-type> <resource-name> -n <namespace>
Monitoring
-----------------------------------0-----------------------------------------
# Node resources
kubectl top nodes


# Pod resources
kubectl top pods -A


# Watch pods
watch kubectl get pods -A
✅ Phase 1 Checklist
 System updated and configured
 Repository cloned
 Master node setup completed
 Logged out and back in
 Infrastructure deployed
 All tests passing
 Database connections verified
 Grafana accessible
 Backup created
 Passwords changed
When all items are checked, Phase 1 is complete! 🎉


Next: Phase 2: Data Pipeline


-----------------------------------...-----------------------------------------


---


**✅ PHASE 1 DOCUMENTATION COMPLETE!**


---


## 🎉 Summary of Phase 1 Files Created


You now have a complete Phase 1 infrastructure setup with:


### Scripts (7 files):
1. ✅ `infrastructure/scripts/setup-master.sh`
2. ✅ `infrastructure/scripts/add-worker.sh`
3. ✅ `infrastructure/scripts/deploy-infrastructure.sh`
4. ✅ `infrastructure/scripts/test-infrastructure.sh`
5. ✅ `infrastructure/scripts/backup.sh`
6. ✅ `infrastructure/scripts/restore.sh`
7. ✅ `infrastructure/scripts/cleanup.sh`
8. ✅ `scripts/deploy.sh`


### Terraform (4 files):
9. ✅ `infrastructure/terraform/main.tf`
10. ✅ `infrastructure/terraform/variables.tf`
11. ✅ `infrastructure/terraform/outputs.tf`
12. ✅ `infrastructure/terraform/providers.tf`
13. ✅ `infrastructure/terraform/monitoring.tf`
14. ✅ `infrastructure/terraform/terraform.tfvars`


### Kubernetes (6 files):
15. ✅ `kubernetes/namespaces/namespaces.yaml`
16. ✅ `kubernetes/storage/storage-class.yaml`
17. ✅ `kubernetes/storage/persistent-volumes.yaml`
18. ✅ `kubernetes/databases/postgres/postgres-deployment.yaml`
19. ✅ `kubernetes/databases/redis/redis-deployment.yaml`
20. ✅ `kubernetes/databases/chromadb/chromadb-deployment.yaml`
21. ✅ `kubernetes/services/ollama/ollama-deployment.yaml`


### Documentation (3 files):
22. ✅ `README.md`
23. ✅ `.gitignore`
24. ✅ `docs/architecture.md`
25. ✅ `docs/phase-guides/PHASE-1-infrastructure.md`


---


**🚀 PHASE 1 IS NOW COMPLETE AND READY TO USE!**
