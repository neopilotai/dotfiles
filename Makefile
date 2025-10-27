.PHONY: help install update diff apply clean lint validate test

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Chezmoi operations
install: ## Initialize and apply dotfiles using chezmoi
	chezmoi init https://github.com/neopilotai/dotfiles.git
	chezmoi apply

update: ## Update dotfiles from repository
	chezmoi update

diff: ## Show diff of changes
	chezmoi diff

apply: ## Apply changes without confirmation
	chezmoi apply --force

# Development and testing
lint: ## Lint configuration files
	@echo "Running comprehensive linting..."
	@./scripts/bin/executable_lint.zsh

validate: ## Validate dotfiles configuration
	@echo "Validating dotfiles configuration..."
	@chezmoi doctor || echo "Some files may differ from target state"
	@echo "Checking for required tools..."
	@command -v chezmoi >/dev/null 2>&1 || { echo "chezmoi is required but not installed"; exit 1; }
	@command -v shellcheck >/dev/null 2>&1 || echo "shellcheck not found (optional)"
	@command -v yamllint >/dev/null 2>&1 || echo "yamllint not found (optional)"
	@echo "Running security validation..."
	@./scripts/bin/executable_validate_security.zsh

security: ## Run security validation only
	@echo "Running security validation..."
	@./scripts/bin/executable_validate_security.zsh

test: ## Test dotfiles setup (dry run)
	@echo "Testing chezmoi configuration..."
	@chezmoi diff | head -20

# Cleanup
clean: ## Clean up temporary files and caches
	@echo "Cleaning up..."
	@find . -name "*.tmp" -delete || true
	@find . -name "*.bak" -delete || true
	@find . -name ".DS_Store" -delete || true

# Documentation
docs: ## Generate documentation
	@echo "README.md is the main documentation"
	@echo "Consider updating docs if structure changes"

# Status and info
status: ## Show current dotfiles status
	@chezmoi status
	@echo ""
	@echo "Repository status:"
	@git status --short

info: ## Show information about dotfiles setup
	@echo "Dotfiles Repository: $(shell basename $(CURDIR))"
	@echo "Chezmoi status:"
	@chezmoi status || true
	@echo ""
	@echo "Git remotes:"
	@git remote -v
	@echo ""
	@echo "Required tools:"
	@which chezmoi || echo "chezmoi: NOT FOUND"
	@which shellcheck || echo "shellcheck: NOT FOUND (optional)"
	@which yamllint || echo "yamllint: NOT FOUND (optional)"

# Development helpers
edit: ## Edit dotfiles with chezmoi
	chezmoi edit

add: ## Add a new dotfile (usage: make add FILE=path/to/file)
	@if [ -z "$(FILE)" ]; then echo "Usage: make add FILE=path/to/file"; exit 1; fi
	chezmoi add $(FILE)

# Backup existing dotfiles before installation
backup: ## Backup existing dotfiles
	@echo "Backing up existing dotfiles..."
	@chezmoi backup --target ~/.config/chezmoi/backup/
