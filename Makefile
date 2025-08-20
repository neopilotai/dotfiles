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

install: ## Install all dotfiles by creating symlinks
	@echo "🔗 Installing dotfiles..."
	@$(MAKE) install-zsh
	@$(MAKE) install-git
	@$(MAKE) install-nvim
	@$(MAKE) install-tmux
	@$(MAKE) install-prettier
	@$(MAKE) install-golangci
	@$(MAKE) install-urlview
	@$(MAKE) install-bin
	@$(MAKE) install-config
	@echo "✅ Dotfiles installed."

install-zsh: ## Install Zsh dotfiles
	@echo "🔗 Installing Zsh dotfiles..."
	ln -sf $(CURDIR)/dot_zshrc $(HOME)/.zshrc
	ln -sf $(CURDIR)/dot_zprofile $(HOME)/.zprofile
	ln -sf $(CURDIR)/dot_aliases $(HOME)/.aliases
	ln -sf $(CURDIR)/dot_completions $(HOME)/.completions
	@echo "✅ Zsh dotfiles installed."

install-git: ## Install Git dotfiles
	@echo "🔗 Installing Git dotfiles..."
	ln -sf $(CURDIR)/dot_gitconfig $(HOME)/.gitconfig
	ln -sf $(CURDIR)/dot_gitconfig_themes $(HOME)/.gitconfig_themes
	@echo "✅ Git dotfiles installed."

install-nvim: ## Install Neovim dotfiles
	@echo "🔗 Installing Neovim dotfiles..."
	mkdir -p $(HOME)/.config
	ln -sf $(CURDIR)/dot_config/nvim $(HOME)/.config/nvim
	ln -sf $(CURDIR)/dot_vim $(HOME)/.vim
	@echo "✅ Neovim dotfiles installed."

install-tmux: ## Install Tmux dotfiles
	@echo "🔗 Installing Tmux dotfiles..."
	ln -sf $(CURDIR)/dot_tmux.conf $(HOME)/.tmux.conf
	ln -sf $(CURDIR)/dot_tmux.conf.settings $(HOME)/.tmux.conf.settings
	@echo "✅ Tmux dotfiles installed."

install-prettier: ## Install Prettier dotfiles
	@echo "🔗 Installing Prettier dotfiles..."
	ln -sf $(CURDIR)/dot_prettierrc $(HOME)/.prettierrc
	@echo "✅ Prettier dotfiles installed."

install-golangci: ## Install GolangCI-Lint dotfiles
	@echo "🔗 Installing GolangCI-Lint dotfiles..."
	ln -sf $(CURDIR)/dot_golangci.yml $(HOME)/.golangci.yml
	@echo "✅ GolangCI-Lint dotfiles installed."

install-urlview: ## Install URLView dotfiles
	@echo "🔗 Installing URLView dotfiles..."
	ln -sf $(CURDIR)/dot_urlview $(HOME)/.urlview
	@echo "✅ URLView dotfiles installed."

install-bin: ## Install bin scripts
	@echo "🔗 Installing bin scripts..."
	ln -sf $(CURDIR)/bin $(HOME)/bin
	@echo "✅ Bin scripts installed."

install-config: ## Install XDG config directories
	@echo "🔗 Installing XDG config directories..."
	mkdir -p $(HOME)/.config
	ln -sf $(CURDIR)/dot_config/broot $(HOME)/.config/broot
	ln -sf $(CURDIR)/dot_config/fsh $(HOME)/.config/fsh
	ln -sf $(CURDIR)/dot_config/ghostty $(HOME)/.config/ghostty
	ln -sf $(CURDIR)/dot_config/pip $(HOME)/.config/pip
	ln -sf $(CURDIR)/dot_config/smug $(HOME)/.config/smug
	@echo "✅ XDG config directories installed."

clean: ## Remove all installed dotfile symlinks
	@echo "🗑️ Cleaning up dotfile symlinks..."
	rm -f $(HOME)/.zshrc
	rm -f $(HOME)/.zprofile
	rm -f $(HOME)/.aliases
	rm -f $(HOME)/.gitconfig
	rm -f $(HOME)/.gitconfig_themes
	rm -f $(HOME)/.tmux.conf
	rm -f $(HOME)/.tmux.conf.settings
	rm -f $(HOME)/.prettierrc
	rm -f $(HOME)/.golangci.yml
	rm -f $(HOME)/.urlview
	rm -rf $(HOME)/.completions
	rm -rf $(HOME)/.config/nvim
	rm -rf $(HOME)/.vim
	rm -rf $(HOME)/bin
	rm -rf $(HOME)/.config/broot
	rm -rf $(HOME)/.config/fsh
	rm -rf $(HOME)/.config/ghostty
	rm -rf $(HOME)/.config/pip
	rm -rf $(HOME)/.config/smug
	@echo "✅ Cleanup complete."

force-install: clean install ## Clean and then install all dotfiles
	@echo "🔄 Forcing reinstallation of dotfiles..."

## ----------------------------
## Phony Targets
## ----------------------------

.PHONY: help update dotfiles-pull brew-sync npm-update pip-update zinit-update \
	nvim-update vale-sync tldr-update neopilot-sync fluxninja-sync doctor \
	install install-zsh install-git install-nvim install-tmux install-prettier \
	install-golangci install-urlview install-bin install-config clean force-install

