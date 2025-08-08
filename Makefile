# Minimal Data Science Project Makefile
# Conda + dlt + dbt workflow

ENV_NAME := newspaper-jobs
DLT_PIPELINE := newspaper_jobs
DBT_PROJECT := newspaper_jobs

# Colors
GREEN := \033[0;32m
BLUE := \033[0;34m
NC := \033[0m

.PHONY: help
help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'

.PHONY: setup
setup: ## Create conda environment from environment.yml
	@echo "$(BLUE)Creating conda environment...$(NC)"
	conda env create -f environment.yml --name $(ENV_NAME)
	@echo "$(GREEN)✓ Environment created. Activate with: conda activate $(ENV_NAME)$(NC)"

.PHONY: update-env
update-env: ## Update conda environment
	@echo "$(BLUE)Updating conda environment...$(NC)"
	conda env update -f environment.yml --name $(ENV_NAME)
	@echo "$(GREEN)✓ Environment updated$(NC)"

.PHONY: extract
extract: ## Run dlt pipeline to extract data
	@echo "$(BLUE)Running dlt pipeline...$(NC)"
	cd $(DLT_PIPELINE) && dlt pipeline $(DLT_PIPELINE) run
	@echo "$(GREEN)✓ Data extraction complete$(NC)"

.PHONY: transform
transform: ## Run dbt transformations
	@echo "$(BLUE)Running dbt transformations...$(NC)"
	cd $(DBT_PROJECT) && dbt deps && dbt run
	@echo "$(GREEN)✓ Transformations complete$(NC)"

.PHONY: test
test: ## Run dbt tests
	@echo "$(BLUE)Running dbt tests...$(NC)"
	cd $(DBT_PROJECT) && dbt test
	@echo "$(GREEN)✓ Tests complete$(NC)"

.PHONY: pipeline
pipeline: extract transform test ## Run full data pipeline
	@echo "$(GREEN)✓ Full pipeline complete!$(NC)"

.PHONY: docs
docs: ## Generate dbt documentation
	@echo "$(BLUE)Generating dbt docs...$(NC)"
	cd $(DBT_PROJECT) && dbt docs generate && dbt docs serve --port 8080
	@echo "$(GREEN)✓ Docs available at http://localhost:8080$(NC)"

.PHONY: clean
clean: ## Clean dbt artifacts
	@echo "$(BLUE)Cleaning artifacts...$(NC)"
	cd $(DBT_PROJECT) && rm -rf dbt_packages/ target/ logs/
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

.PHONY: status
status: ## Show project status
	@echo "$(BLUE)Project Status$(NC)"
	@echo "=============="
	@echo "Conda env: $(ENV_NAME)"
	@if conda env list | grep -q $(ENV_NAME); then \
		echo "$(GREEN)✓ Environment exists$(NC)"; \
	else \
		echo "❌ Environment not found"; \
	fi
	@if [ -f environment.yml ]; then echo "$(GREEN)✓ environment.yml$(NC)"; fi
	@if [ -f dbt_project.yml ]; then echo "$(GREEN)✓ dbt_project.yml$(NC)"; fi
	@if [ -d .dlt ]; then echo "$(GREEN)✓ .dlt directory$(NC)"; fi

.DEFAULT_GOAL := help