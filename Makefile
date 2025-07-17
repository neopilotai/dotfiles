# Dotfiles Automation and Maintenance

.DEFAULT_GOAL := help

# Main script
AUTOSCRIPT := ./bin/autoupdate.zsh

# Required tools for doctor check
REQUIRED := chezmoi zinit nvim npm pip3 tldr vale revolver

## ----------------------------
## Tasks
## ----------------------------

help: ## Show available commands
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

update: ## Run the full autoupdate workflow
	@$(AUTOSCRIPT)

dotfiles-pull: ## Force chezmoi pull
	chezmoi update --force -v

brew-sync: ## Sync Homebrew packages
	@./bin/sync_brews.sh

npm-update: ## Update global npm packages
	npm update && npm upgrade && npm audit fix --force && npm prune --production --force

pip-update: ## Update Python packages
	pip3 install --upgrade pip setuptools wheel
	pip3 freeze --local | grep -v '^-e' | cut -d = -f 1 | xargs -n1 pip3 install --upgrade

zinit-update: ## Update zinit plugins
	source $$HOME/.local/share/zinit/zinit.git/zinit.zsh && \
	zinit self-update && \
	zinit update --quiet --parallel 8 && \
	zinit cclear

nvim-update: ## Update Neovim plugins and Treesitter
	nvim +PlugUpgrade +PlugClean! +PlugUpdate +PlugInstall +CocUpdateSync +TSUpdateSync +qall

vale-sync: ## Sync Vale styles
	cd styles && vale sync

tldr-update: ## Update TLDR cache
	tldr --update

neopilot-sync: ## Sync NeoPilot repo
	@./bin/sync_neopilotai.sh

fluxninja-sync: ## Sync FluxNinja repo
	@./bin/sync_fluxninja.sh

doctor: ## Check required tools
	@echo "🔍 Checking environment..."
	@missing=0; \
	for tool in $(REQUIRED); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "❌ Missing: $$tool"; \
			missing=1; \
		else \
			echo "✅ Found:   $$tool"; \
		fi; \
	done; \
	if [ $$missing -eq 1 ]; then \
		echo "⚠️  One or more required tools are missing."; exit 1; \
	else \
		echo "✅ All required tools are installed."; \
	fi

## ----------------------------
## Phony Targets
## ----------------------------

.PHONY: help update dotfiles-pull brew-sync npm-update pip-update zinit-update \
	nvim-update vale-sync tldr-update neopilot-sync fluxninja-sync doctor
