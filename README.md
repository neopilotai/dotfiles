# NeoPilot Dotfiles

![NeoPilot Neovim](./scripts/assets/vim.png)

## Table of Contents

- [Introduction](#introduction)
- [Quick Start](#quick-start)
- [Features](#features)
  - [Terminal (Zsh)](#terminal-zsh)
  - [Tmux](#tmux)
  - [Neovim](#neovim)
  - [Git](#git)
- [Configuration](#configuration)
  - [Local Overrides](#local-overrides)
  - [Colors and Themes](#colors-and-themes)
- [Development](#development)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

## Introduction

Welcome to NeoPilot optimized development environment that is well integrated with our stack.

This dotfiles repository provides a comprehensive development setup including:

- **Zsh** with modern plugins and fuzzy completion
- **Tmux** with session management and productivity features
- **Neovim** with AI-powered completion and modern tooling
- **Git** with enhanced workflows and theming

## Quick Start

### Prerequisites

- [chezmoi](https://www.chezmoi.io) - Dotfile manager
- [Homebrew](https://brew.sh) - Package manager (macOS/Linux)

### Installation

#### Automatic Setup (Recommended)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/neopilotai/dotfiles/master/scripts/assets/executable_install.sh)"
```

#### Manual Setup

```bash
cd $HOME
chezmoi init git@github.com:neopilotai/dotfiles.git
# Show diff of changes that will be made
chezmoi diff
# Apply changes
chezmoi apply -v
```

After installation, close and reopen your terminal to trigger first-time setup.

### Post-Installation

1. **GitHub Authentication**: Run `gh auth login` or add SSH key to your GitHub account
2. **Nerd Fonts**: Enable a nerd font (e.g., `Hack Nerd Font`) in your terminal
3. **iTerm2 Integration**: On macOS, the setup will offer to install the bundled iTerm2 profile

## Features

### Terminal (Zsh)

![Zsh](./scripts/assets/zsh.png)

#### Core Features
- **Fuzzy Menus**: Press `TAB` for command completion, `^R` for history search
- **Vi Mode**: Press `ESC` to enter Vi NORMAL mode
- **Smart Prompt**: Shows Git status, exit codes, and contextual information
- **Auto-complete**: Enhanced completion with previews and descriptions

#### Quality of Life
- **Insults/Cheers**: Fun feedback for command success/failure (configurable)
- **Weather Display**: Shows current weather on startup
- **GitHub Status**: Displays GitHub service status
- **Auto-updates**: Automatic dotfile updates every 7 days

#### Key Bindings
- `<TAB>` - Command completion menu
- `^R` - History fuzzy search
- `ESC` - Enter Vi mode
- `vv` (in Vi mode) - Open file in Neovim with Copilot

### Tmux

![Tmux Menu](./scripts/assets/tmux-menu.png)
![Tmux Fuzzy Menu](./scripts/assets/tmux-fzf.png)

#### Core Features
- **Session Management**: Automatic session restoration and fuzzy session switching
- **Fuzzy Menu**: Press `<C-a><C-Space>` for quick tmux management
- **Tmux Menu**: Press `F12` for session/window/pane management
- **Nested Sessions**: Press `F1` to suspend/unsuspend local tmux

#### Key Bindings
- `<C-a>` or `<C-b>` - Prefix key
- `<C-a><C-Space>` - Fuzzy menu
- `F12` - Tmux management menu
- `F1` - Toggle nested sessions
- `<C-a><C-/>` - Fuzzy search in terminal buffer
- `<C-a><C-P>` - PathPicker integration

### Neovim

This environment provides a modern Neovim setup optimized for development.

![Fuzzy Menu](./scripts/assets/fuzzymenu.png)
![IDE](./scripts/assets/vim_ide.png)

#### AI Integration
- **GitHub Copilot**: Type `:Copilot setup` to configure
- **CodeGPT**: Highlight code and press `<space><space>` for AI options
- **LanguageTool**: Premium integration for grammar checking

#### Key Features
- **Fuzzy Menu**: Press `<space><space>` or `Shift+LeftMouse` for contextual actions
- **Color Schemes**: Multiple themes with Gruvbox as default
- **Landing Page**: Helpful links and discoverability aids

#### Configuration
You can provide additional settings in:
- `$HOME/.vimrc_local` - Additional Vim configuration
- `$HOME/.vimrc_plugins` - Additional plugins
- `$HOME/.config/nvim/init.vim` - Neovim-specific settings

### Git

#### Enhanced Configuration
- **Delta Integration**: Modern diff viewer with syntax highlighting
- **Git Extras**: Additional Git commands and utilities
- **Smart Defaults**: Optimized merge and push behavior

#### Theme Integration
See `.gitconfig_themes` for available themes. Override in your local `.gitconfig_local`.

## Configuration

### Local Overrides

All tools support local override files that won't be overwritten by updates:

| Tool | Override File | Purpose |
|------|---------------|---------|
| Zsh | `.zshrc_local` | Additional shell configuration |
| Vim | `.vimrc_local` | Additional Vim settings |
| Tmux | `.tmux.conf_local` | Additional tmux settings |
| Git | `.gitconfig_local` | Personal Git configuration |
| Homebrew | `.brew_local` | Private package list |
| Fsh | `.config/fsh_local` | Fast syntax highlighting theme |

### Colors and Themes

The setup uses **Gruvbox Dark** as the default theme across all tools.

#### Terminal Colors
- **macOS**: iTerm2 profile installation offered during setup
- **Linux**: Colors set via escape codes (disable with `SET_TERMINAL_COLORS=false`)
- **Alternative**: Use terminal's built-in color profiles

#### Available Themes
- **bat**: `BAT_THEME` environment variable
- **FZF**: Base16 color schemes from [base16-fzf](https://github.com/fnune/base16-fzf)
- **LS_COLORS**: [vivid](https://github.com/sharkdp/vivid) integration
- **Git**: Multiple themes in `.gitconfig_themes`

## Development

### Repository Structure

```
├── dot_*                    # Chezmoi dotfiles (prefixed with dot_)
├── scripts/                 # Scripts and assets
│   ├── assets/             # Configuration assets, scripts, images
│   └── bin/                # Executable scripts
├── .github/workflows/       # GitHub Actions
├── .chezmoidot.toml        # Chezmoi configuration
├── .chezmoiignore          # Chezmoi ignore patterns
├── Makefile                # Development tasks
└── README.md              # This file
```

### Development Commands

```bash
# Show available commands
make help

# Lint configuration files
make lint

# Validate setup and run security checks
make validate

# Run security validation only
make security

# Update dotfiles
make update

# Show current status
make status
```

### Adding New Dotfiles

```bash
# Add a new file to be managed
make add FILE=path/to/your/file

# Edit existing dotfile with chezmoi
make edit
```

## Troubleshooting

### Common Issues

#### Terminal Colors Not Working
```bash
# Disable automatic color setting
echo 'export SET_TERMINAL_COLORS=false' >> ~/.zshrc_local
```

#### Missing Dependencies
```bash
# Install Homebrew (required)
make install
# or manually:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Chezmoi Issues
```bash
# Check chezmoi status
chezmoi doctor

# Force update
chezmoi update --force

# Show what would change
chezmoi diff
```

#### Permission Issues
```bash
# Fix chezmoi permissions
chezmoi state reset
chezmoi apply
```

### Getting Help

1. **Check Status**: Run `make status` to see current state
2. **Validate Setup**: Run `make validate` to check for issues
3. **View Diff**: Run `chezmoi diff` to see pending changes
4. **Documentation**: Check tool-specific documentation in comments

### Manual Recovery

If something breaks, you can:

1. **Backup current setup**: `chezmoi backup`
2. **Reset to known state**: `chezmoi apply --force`
3. **Check logs**: Look for error messages in terminal output

## Security

### Security Features

This dotfiles repository includes several security measures:

- **No Hardcoded Secrets**: All sensitive data uses environment variables or secure vaults
- **Safe Installation**: Verified downloads and proper input validation
- **Secure Defaults**: Conservative permissions and safe shell practices
- **Regular Validation**: Automated security checks and linting

### Security Validation

Run security checks before making changes:

```bash
# Run full validation
make validate

# Run security validation only
make security

# Lint all configuration files
make lint
```

### Best Practices

#### For Users
- Store API keys and tokens in environment variables, not config files
- Use `*_local` files for personal settings (they're automatically ignored)
- Regularly update your system and packages
- Use SSH keys instead of passwords when possible

#### For Contributors
- Never commit secrets or personal information
- Use `make security` before submitting changes
- Follow shell scripting best practices
- Validate all user input in scripts

### Security Considerations

#### Installation Security
- Homebrew installation uses official sources
- No automatic privilege escalation
- User confirmation for system changes

#### Update Security
- Package updates use safe practices
- npm audit runs before applying fixes
- pip updates respect requirements files when available

#### Configuration Security
- Local override files are never committed
- Sensitive paths are properly ignored
- No world-writable files by default

## Contributing

1. **Test changes**: Use `make validate` before committing
2. **Security check**: Run `make security` to ensure no security issues
3. **Update documentation**: Keep README.md in sync with changes
4. **Follow conventions**: Use existing patterns for new configurations
