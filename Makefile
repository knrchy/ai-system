# Trading AI System - Makefile


.PHONY: help setup deploy-infra deploy-pipeline test clean


help:
	@echo "Trading AI System - Available Commands"
	@echo ""
	@echo "Setup:"
	@echo "  make setup              - Run initial system setup"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-infra       - Deploy infrastructure (Phase 1)"
	@echo "  make deploy-pipeline    - Deploy data pipeline (Phase 2)"
	@echo "  make deploy-all         - Deploy everything"
	@echo ""
	@echo "Testing:"
	@echo "  make test-infra         - Test infrastructure"
	@echo "  make test-pipeline      - Test data pipeline"
	@echo "  make test-all           - Run all tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make backup             - Create system backup"
	@echo "  make logs               - View application logs"
	@echo "  make clean              - Clean up resources"
	@echo ""


setup:
	@echo "Running system setup..."
	chmod +x infrastructure/scripts/setup-master.sh
	./infrastructure/scripts/setup-master.sh


deploy-infra:
	@echo "Deploying infrastructure..."
	chmod +x infrastructure/scripts/deploy-infrastructure.sh
	./infrastructure/scripts/deploy-infrastructure.sh


deploy-pipeline:
	@echo "Deploying data pipeline..."
	chmod +x scripts/deploy-data-pipeline.sh
	./scripts/deploy-data-pipeline.sh


deploy-all: deploy-infra deploy-pipeline
	@echo "Full deployment complete!"


test-infra:
	@echo "Testing infrastructure..."
	chmod +x infrastructure/scripts/test-infrastructure.sh
	./infrastructure/scripts/test-infrastructure.sh


test-pipeline:
	@echo "Testing data pipeline..."
	chmod +x scripts/test-data-pipeline.sh
	./scripts/test-data-pipeline.sh


test-all: test-infra test-pipeline
	@echo "All tests complete!"


backup:
	@echo "Creating backup..."
	chmod +x infrastructure/scripts/backup.sh
	./infrastructure/scripts/backup.sh


logs:
	@echo "Viewing logs..."
	kubectl logs -f deployment/data-pipeline -n trading-system


clean:
	@echo "Cleaning up..."
	kubectl delete -f kubernetes/services/data-pipeline/deployment.yaml || true
	docker system prune -f


status:
	@echo "System Status:"
	@echo ""
	@echo "Nodes:"
	kubectl get nodes
	@echo ""
	@echo "Pods:"
	kubectl get pods -A
	@echo ""
	@echo "Services:"
	kubectl get svc -A
