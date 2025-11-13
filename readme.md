
# 🤖 Trading AI System


> AI-powered trading bot analysis, backtesting, and optimization platform for cTrader


[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s-326CE5?logo=kubernetes)](https://k3s.io/)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python)](https://www.python.org/)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-7B42BC?logo=terraform)](https://www.terraform.io/)


---


## 📋 Table of Contents


- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Phase Implementation](#phase-implementation)
- [Usage](#usage)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)


---


## 🎯 Overview


The **Trading AI System** is a comprehensive platform designed to analyze, optimize, and enhance trading bot performance using advanced AI techniques. Built specifically for cTrader cBot users, it provides:


- **Deep Data Analysis**: Process millions of transactions using RAG (Retrieval Augmented Generation)
- **Distributed Computing**: Leverage multiple machines for parallel backtesting
- **AI-Powered Insights**: Natural language queries over trading data
- **Strategy Optimization**: Genetic algorithms and ML-based parameter tuning
- **Code Generation**: Reverse engineer C# cBot code from trading patterns


---


## ✨ Features


### 🔍 Data Analysis
- Parse and analyze 900K+ line JSON exports from cTrader
- Process 16M+ transactions with semantic search
- Vector database (ChromaDB) for fast similarity queries
- Time-series pattern detection


### 🤖 AI Integration
- Local LLM (Ollama + Llama 3.1) for privacy
- RAG system for context-aware answers
- Natural language querying of trading data
- Automated insight generation


### ⚡ Distributed Computing
- Kubernetes (K3s) cluster orchestration
- Multi-machine backtesting parallelization
- Celery task queue for job distribution
- Auto-scaling workers


### 📊 Optimization
- Genetic algorithm parameter optimization
- Walk-forward analysis validation
- Monte Carlo simulation
- Multi-objective optimization (profit, drawdown, Sharpe)


### 🛠️ Infrastructure
- Infrastructure as Code (Terraform)
- GitOps workflow
- Automated backups and restore
- Monitoring with Prometheus + Grafana


---


## 🏗️ Architecture


┌─────────────────────────────────────────────────────────────┐ │                     User Interface Layer                     │ │  CLI Tool | Web Dashboard | API Gateway | Jupyter Notebooks │ └─────────────────────────────────────────────────────────────┘ │ ┌─────────────────────────────────────────────────────────────┐ │                   Application Layer (K8s)                    │ │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │ │  │   RAG    │  │Backtesting│  │    ML    │  │  API     │   │ │  │  Engine  │  │  Engine   │  │Optimizer │  │ Gateway  │   │ │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │ └─────────────────────────────────────────────────────────────┘ │ ┌─────────────────────────────────────────────────────────────┐ │                    Data & AI Layer (K8s)                     │ │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │ │  │PostgreSQL│  │  Redis   │  │ ChromaDB │  │  Ollama  │   │ │  │(Trades)  │  │ (Cache)  │  │(Vectors) │  │  (LLM)   │   │ │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │ └─────────────────────────────────────────────────────────────┘ │ ┌─────────────────────────────────────────────────────────────┐ │              Infrastructure Layer (K3s Cluster)              │ │  Master Node (24GB RAM) + Worker Nodes (Expandable)         │ └─────────────────────────────────────────────────────────────┘


-----------------------------------...-----------------------------------------


See [docs/architecture.md](docs/architecture.md) for detailed architecture documentation.


---


## 📦 Prerequisites


### Hardware Requirements


**Master Node (Minimum):**
- CPU: 4 cores (Intel i5 or better)
- RAM: 16GB (24GB recommended)
- Storage: 500GB SSD
- OS: Ubuntu 22.04 LTS


**Worker Nodes (Optional):**
- CPU: 2+ cores
- RAM: 8GB+
- Storage: 100GB+


### Software Requirements


- Ubuntu 22.04 LTS (or compatible Linux distribution)
- Internet connection (for initial setup)
- Root/sudo access


**All other dependencies are installed automatically by setup scripts!**


---


## 🚀 Quick Start


### Step 1: Clone Repository


```bash
git clone https://github.com/knrchy/ai-system.git
cd ai-system


Step 2: Run Master Node Setup
-----------------------------------0-----------------------------------------
chmod +x infrastructure/scripts/setup-master.sh
./infrastructure/scripts/setup-master.sh
This installs:

Docker & Docker Compose
K3s (Kubernetes)
kubectl & Helm
Terraform
Python 3.10+
Time: ~10-15 minutes


Step 3: Deploy Infrastructure
-----------------------------------0-----------------------------------------
# Log out and back in for Docker group to take effect
# Then run:

>  Make sure  to create the ones who will be the workesrs or have the operatives systems already atleas to deploythe add worker file. or have a real big machine like 64 RAM and 300 HDD

run
chmod +x infrastructure/scripts/setup-master.sh \
infrastructure/scripts/add-worker.sh \
infrastructure/scripts/deploy-infrastructure.sh \
infrastructure/scripts/test-infrastructure.sh \
infrastructure/scripts/cleanup.sh \
infrastructure/scripts/backup.sh \
infrastructure/scripts/restore.sh \
infrastructure/scripts/deploy.sh \
./infrastructure/scripts/deploy-infrastructure.sh

This deploys:


PostgreSQL database
Redis cache
ChromaDB vector database
Ollama LLM (with Llama 3.1 model)
Monitoring stack (Prometheus + Grafana)
Time: ~20-30 minutes


Step 4: Verify Installation
-----------------------------------0-----------------------------------------
chmod +x infrastructure/scripts/test-infrastructure.sh
./infrastructure/scripts/test-infrastructure.sh

Step 5: (Optional) Add Worker Nodes
On each worker machine:


-----------------------------------0-----------------------------------------
# Get join token from master node (saved in ~/k3s-join-info.txt)
chmod +x infrastructure/scripts/add-worker.sh
./infrastructure/scripts/add-worker.sh
📁 Project Structure
-----------------------------------...-----------------------------------------
ai-system/
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
├── docs/                              # Documentation
│   ├── architecture.md                # System architecture
│   ├── phase-guides/                  # Phase-by-phase guides
│   │   ├── PHASE-1-infrastructure.md
│   │   ├── PHASE-2-data-pipeline.md
│   │   └── ...
│   └── troubleshooting.md             # Common issues
├── infrastructure/                    # Infrastructure as Code
│   ├── terraform/                     # Terraform configs
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ansible/                       # Ansible playbooks (future)
│   └── scripts/                       # Setup scripts
│       ├── setup-master.sh            # Master node setup
│       ├── add-worker.sh              # Worker node setup
│       ├── deploy-infrastructure.sh   # Deploy all infrastructure
│       ├── test-infrastructure.sh     # Test deployment
│       ├── backup.sh                  # Backup system
│       ├── restore.sh                 # Restore from backup
│       └── cleanup.sh                 # Remove all resources
├── kubernetes/                        # Kubernetes manifests
│   ├── namespaces/                    # Namespace definitions
│   ├── storage/                       # PV, PVC, StorageClass
│   ├── databases/                     # Database deployments
│   │   ├── postgres/
│   │   ├── redis/
│   │   └── chromadb/
│   ├── services/                      # Application services
│   │   ├── ollama/
│   │   ├── rag-service/
│   │   ├── api-gateway/
│   │   └── celery-workers/
│   ├── monitoring/                    # Monitoring stack
│   │   ├── prometheus/
│   │   └── grafana/
│   └── ingress/                       # Ingress rules
├── applications/                      # Application code
│   ├── data-pipeline/                 # Data ingestion & processing
│   ├── rag-engine/                    # RAG implementation
│   ├── backtesting-engine/            # Backtesting system
│   ├── ml-optimizer/                  # ML optimization
│   └── api-gateway/                   # REST API
├── data/                              # Data storage
│   ├── raw/                           # Raw cTrader exports
│   ├── processed/                     # Processed data
│   ├── embeddings/                    # Vector embeddings
│   └── models/                        # ML models
├── configs/                           # Configuration files
│   ├── development/
│   ├── staging/
│   └── production/
└── scripts/                           # Utility scripts
    ├── deploy.sh                      # Main deployment script
    ├── backup.sh                      # Backup utilities
    └── restore.sh                     # Restore utilities
🎯 Phase Implementation
The project is built in phases for incremental value delivery:


Phase	Name	Status	Duration	Description
1	Infrastructure Foundation	✅ Complete	2-3 days	K3s cluster, databases, monitoring
2	Data Pipeline	🚧 In Progress	3-4 days	JSON parsing, ETL, data validation
3	RAG System	⏳ Planned	4-5 days	Vector DB, embeddings, LLM integration
4	Distributed Computing	⏳ Planned	3-4 days	Task queue, worker distribution
5	Backtesting Engine	⏳ Planned	5-7 days	Custom backtester, parameter sweeps
6	ML Optimization	⏳ Planned	7-10 days	Genetic algorithms, feature engineering
7	API & UI	⏳ Planned	4-5 days	REST API, web dashboard, CLI
8	Production Hardening	⏳ Planned	3-4 days	Security, backups, monitoring
See individual phase guides in docs/phase-guides/


💻 Usage
Access Services
PostgreSQL:


-----------------------------------0-----------------------------------------
# From host machine
psql -h localhost -p 30432 -U trading_user -d trading_db


# From within cluster
kubectl exec -it -n databases <postgres-pod> -- psql -U trading_user -d trading_db
Redis:


-----------------------------------0-----------------------------------------
# From host machine
redis-cli -h localhost -p 30379


# From within cluster
kubectl exec -it -n databases <redis-pod> -- redis-cli
ChromaDB:


-----------------------------------0-----------------------------------------
# API endpoint
curl http://localhost:30800/api/v1/heartbeat


# From within cluster
curl http://chromadb.databases.svc.cluster.local:8000/api/v1/heartbeat
Ollama:


-----------------------------------0-----------------------------------------
# Test LLM
curl http://localhost:31434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Explain trading strategies",
  "stream": false
}'
Monitoring
Grafana Dashboard:


-----------------------------------0-----------------------------------------
# Access at: http://localhost:30300
# Default credentials: admin / admin
Prometheus:


-----------------------------------0-----------------------------------------
# Access at: http://localhost:30900
Backup & Restore
Create Backup:


-----------------------------------0-----------------------------------------
./infrastructure/scripts/backup.sh
Restore Backup:


-----------------------------------0-----------------------------------------
./infrastructure/scripts/restore.sh <backup-name>
List Backups:


-----------------------------------0-----------------------------------------
ls -lh /mnt/backups/*.tar.gz
📚 Documentation
Architecture Overview
Phase 1: Infrastructure
Phase 2: Data Pipeline
Troubleshooting Guide
API Documentation (Coming soon)
Contributing Guide (Coming soon)
🛠️ Troubleshooting
Common Issues
Pods not starting:


-----------------------------------0-----------------------------------------
kubectl describe pod -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name>
Storage issues:


-----------------------------------0-----------------------------------------
kubectl get pv
kubectl get pvc -A
Network issues:


-----------------------------------0-----------------------------------------
kubectl get svc -A
kubectl get endpoints -A
See docs/troubleshooting.md for detailed solutions.


🤝 Contributing
Contributions are welcome! Please see CONTRIBUTING.md for guidelines.


📄 License
This project is licensed under the MIT License - see the LICENSE file for details.


🙏 Acknowledgments
cTrader - Trading platform
Ollama - Local LLM runtime
ChromaDB - Vector database
K3s - Lightweight Kubernetes
LangChain - RAG framework
📞 Support
Issues: GitHub Issues
Discussions: GitHub Discussions
Email: your.email@example.com
Built with ❤️ for traders who code


-----------------------------------...-----------------------------------------
     _____ _____ _____ _____ 
    |_   _|  _  |  _  |  _  |
      | | | |_| | | | | | | |
      | | |  _  | | | | | | |
      |_| |_| |_|_| |_|_| |_|
                             
    Trading AI System v1.0
-----------------------------------...-----------------------------------------


---


**✅ File complete!**

---


## 🚦 Getting Started Checklist


- [ ] Clone repository
- [ ] Run `setup-master.sh`
- [ ] Log out and back in
- [ ] Run `deploy-infrastructure.sh`
- [ ] Run `test-infrastructure.sh`
- [ ] Access Grafana dashboard
- [ ] Export cTrader data
- [ ] Proceed to Phase 2


---


## 📊 System Status


Check system health:


```bash
# Quick status check
kubectl get nodes
kubectl get pods -A


# Detailed health check
./infrastructure/scripts/test-infrastructure.sh
🔐 Security Notes
Default Passwords (CHANGE THESE!):


PostgreSQL: TradingAI2025!
Grafana: admin / admin
To change passwords:


-----------------------------------0-----------------------------------------
# PostgreSQL
kubectl exec -it -n databases <postgres-pod> -- psql -U trading_user -d postgres
ALTER USER trading_user WITH PASSWORD 'new_password';


# Grafana
# Change via web UI after first login
🎓 Learning Resources
Kubernetes Basics
Terraform Getting Started
LangChain Documentation
Ollama Documentation
ChromaDB Guide
🗺️ Roadmap
Q4 2025
✅ Phase 1: Infrastructure
🚧 Phase 2: Data Pipeline
⏳ Phase 3: RAG System
Q1 2026
⏳ Phase 4: Distributed Computing
⏳ Phase 5: Backtesting Engine
Q2 2026
⏳ Phase 6: ML Optimization
⏳ Phase 7: API & UI
⏳ Phase 8: Production Hardening
💡 Tips & Best Practices
Always backup before major changes


-----------------------------------0-----------------------------------------
./infrastructure/scripts/backup.sh
Monitor resource usage


-----------------------------------0-----------------------------------------
kubectl top nodes
kubectl top pods -A
Check logs regularly


-----------------------------------0-----------------------------------------
kubectl logs -f -n <namespace> <pod-name>
Use namespaces for organization


databases - All database services
trading-system - Trading applications
monitoring - Monitoring stack
Keep your cluster updated


-----------------------------------0-----------------------------------------
# Update K3s
curl -sfL https://get.k3s.io | sh -
🐛 Known Issues
Issue: Ollama model download can be slow


Solution: Be patient, model is ~4.7GB
Issue: PostgreSQL pod restarts on first deploy


Solution: Normal behavior, wait for initialization
Issue: ChromaDB slow on first query


Solution: Warming up, subsequent queries are fast
See docs/troubleshooting.md for more.


📈 Performance Benchmarks
Expected Performance (Master Node: i7 5th gen, 24GB RAM):


Operation	Time	Notes
Parse 900K JSON lines	~2-5 min	Depends on complexity
Generate embeddings (50K chunks)	~10-15 min	CPU-based
RAG query	<3 sec	After indexing
Backtest (1 year data)	~30 sec	Single parameter set
Optimization (100 scenarios)	~5-10 min	With 12 cores
🌟 Star History
If you find this project useful, please consider giving it a star! ⭐


Last Updated: October 31, 2025
Version: 1.0.0
Maintainer: Your Name


-----------------------------------...-----------------------------------------


---


**✅ README.md complete!**




#### create `docs/architecture.md`
```md
# Trading AI System Architecture

## Overview
This document provides an in-depth look at the architecture of the Trading AI System. It covers the infrastructure components, deployment configurations, and rationale behind the architectural choices.

## Components
- **K3s (Kubernetes)**
  - Lightweight Kubernetes distribution ideal for edge, IoT, and CI environments.
- **Docker**
  - Container runtime used for running application containers.
- **Terraform**
  - Infrastructure as Code tool for provisioning and managing infrastructure.

## Kubernetes Namespaces
Namespaces separate different functional components:
- **trading-system**: Main components of the trading system.
- **databases**: Database-related pods and services.
- **monitoring**: Monitoring tools and services.

## Persistent Volumes
Persistent Volumes (PVs) provide stable storage for database and application data:
- **trading-data-pv**: Stores trading data.
- **models-pv**: Stores machine learning models.
- **postgres-pv**: PostgreSQL data storage.
- **redis-pv**: Redis data storage.
- **chromadb-pv**: ChromaDB data storage.

## Kubernetes Resources
Resources like deployments, services, config maps, and secrets are defined under `kubernetes` directory.

## Data Flow
1. **Data Ingestion**: Data is pulled from trading systems and ingested into the databases.
2. **Data Processing**: Data is processed using machine learning models.
3. **Model Training**: Models are trained and stored.
4. **Prediction and Backtesting**: Predictions are made using trained models and validated using backtesting techniques.
5. **Monitoring**: The system is monitored using Prometheus and Grafana.

## Infrastructure Deployment
1. **Terraform** is used to define and provision infrastructure.
2. **Kubernetes Manifests** are deployed for managing application lifecycle.
3. **Helm** is used for package management.

## Backup and Restore
Scripts are provided to backup and restore the system state, ensuring data integrity and system resilience.

## Security Considerations
- Sensitive data is managed using Kubernetes secrets.
- Namespace isolation ensures separation of concerns.
- Persistent volumes are configured with appropriate access controls.

## Future Improvements
- Expand monitoring capabilities.
- Introduce CI/CD pipelines for automated deployments.
- Enhance security measures.

## Diagram
![Architecture Diagram](architecture-diagram.png)

## Conclusion
The Trading AI System architecture is designed to be robust, scalable, and flexible, enabling efficient trading operations and rapid development of trading algorithms.



Setup
Master Node Setup
Execute the master node setup script:

Copy bash
./infrastructure/scripts/setup-master.sh
Add Worker Node
Execute the worker node setup script:

Copy bash
./infrastructure/scripts/add-worker.sh
Deploy Infrastructure
Execute the deployment script:

Copy bash
./infrastructure/scripts/deploy.sh
Test Infrastructure
Execute the test script:

Copy bash
./infrastructure/scripts/test-infrastructure.sh
Backup and Restore
Backup:

Copy bash
./infrastructure/scripts/backup.sh
Restore:

Copy bash
./infrastructure/scripts/restore.sh <backup-name>
Cleanup
Cleanup Infrastructure:

Copy bash
./infrastructure/scripts/cleanup.sh

chmod +x 01_os_setup.sh 02_configure_hostname_network.sh 03_install_docker.sh 04_install_k3s.sh 05_setup_git_repo.sh 06_setup_terraform.sh 07_setup_kubernetes_manifests.sh

./01_os_setup.sh
./02_configure_hostname_network.sh
./03_install_docker.sh
./04_install_k3s.sh
./05_setup_git_repo.sh
./06_setup_terraform.sh
./07_setup_kubernetes_manifests.sh

# Trading AI System

## Overview
This project sets up a complete infrastructure for a Trading AI System using Kubernetes (K3s), Docker, and Terraform. This document provides a high-level overview of the project, the setup process, and how to get started.

## Prerequisites
- Ubuntu 22.04 LTS Server
- Basic understanding of Docker, Kubernetes, and Terraform

## Project Structure
```bash
trading-ai-system/
├── infrastructure/
│   ├── terraform/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── monitoring.tf
│   │   ├── providers.tf
│   │   └── terraform.tfvars
│   └── scripts/
│       ├── setup-master.sh
│       ├── add-worker.sh
│       ├── deploy-infrastructure.sh
│       ├── test-infrastructure.sh
│       ├── cleanup.sh
│       ├── backup.sh
│       ├── restore.sh
└── kubernetes/
    ├── namespaces.yaml
    ├── storage/
    │   ├── persistent-volumes.yaml
    │   └── storage-class.yaml
    └── databases/
        ├── postgres/
        │   └── postgres-deployment.yaml
        ├── redis/
        │   └── redis-deployment.yaml
        └── chromadb/
            └── chromadb-deployment.yaml
    └── services/
        └── ollama/
            └── ollama-deployment.yaml
