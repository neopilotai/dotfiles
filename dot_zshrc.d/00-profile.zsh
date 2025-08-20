# source ~/.zprofile if ZPROFILE_SOURCED is not set
if [[ -z "$ZPROFILE_SOURCED" ]]; then
  source ~/.zprofile
fi

# Check for Homebrew to be present, install if it's missing
if ! command -v brew &> /dev/null; then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # source ~/.zprofile to update PATH
  source ~/.zprofile
  ~/bin/executable_autoupdate.zsh --force
fi

figlet -w 80 NeoPilot Zsh && echo "" 2&>/dev/null
