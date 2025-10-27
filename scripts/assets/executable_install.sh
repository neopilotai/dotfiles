#!/bin/bash

# installer for dotfiles
function brew_shellenv() {
	if [ -d "$HOME/homebrew" ]; then
		eval "$("$HOME"/homebrew/bin/brew shellenv)"
	else
		if [[ $OSTYPE == 'darwin'* ]]; then
			test -d /opt/homebrew && eval "$(/opt/homebrew/bin/brew shellenv)"
			test -f /usr/local/bin/brew && eval "$(/usr/local/bin/brew shellenv)"
		else
			test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		fi
	fi
}

cd "$HOME" || exit

# ask the user whether they want to use system's homebrew or use a local install
echo "Do you want to use the system's homebrew? (recommended) [Y/n]"
read -r answer
if [ "$answer" = "n" ]; then
	echo "Installing local homebrew..."
	mkdir homebrew
	# Use official Homebrew installation with verification
	curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
else
	# delete local homebrew if it exists
	rm -rf ~/homebrew
	echo "Installing system homebrew..."
	# Use official installation method
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew_shellenv

# install github cli
brew install gh
# install chezmoi
brew install chezmoi
# install zsh
brew install zsh
# install gum
brew install gum

# Safely add zsh to shells if not present
ZSH_PATH=$(which zsh)
if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
	echo "Adding $ZSH_PATH to /etc/shells"
	sudo sh -c "echo '$ZSH_PATH' >> /etc/shells"
fi
chsh -s "$ZSH_PATH"

echo "Authenticating with GitHub. Please make sure to choose ssh option for authentication."

# authenticate with github
gh auth login -p ssh

# check if $HOME/.git exists and back it up if it does
if [ -d "$HOME"/.git ]; then
	echo "Backing up $HOME/.git to $HOME/.git.bak"
	mv "$HOME"/.git "$HOME"/.git.bak
fi

echo "Setting up .gitconfig_local"
# ask the user to input email address
email=$(gum input --placeholder "Please enter your NeoPilot email address")

# ask the user to input their name
name=$(gum input --placeholder "Please enter your name")

# create .gitconfig_local
# File contents:
# [user]
#   name = $name
#   email = $email
echo "[user]" >"$HOME"/.gitconfig_local
echo "  name = $name" >>"$HOME"/.gitconfig_local
echo "  email = $email" >>"$HOME"/.gitconfig_local

chezmoi init git@github.com:neopilotai/dotfiles.git
chezmoi apply -v

# run autoupdate script
echo "Running autoupdate script..."
~/scripts/bin/autoupdate.zsh --force
# if autoupdate failed, exit
if [ $? -ne 0 ]; then
	echo "Failed to run autoupdate script"
	exit 1
fi

# Ask user before rebooting instead of forcing it
echo "Installation complete! A restart is recommended to apply all changes."
echo "Would you like to restart now? [y/N]"
read -r restart_answer
if [[ $restart_answer =~ ^[Yy]$ ]]; then
	echo "Restarting computer..."
	sudo reboot
else
	echo "Please restart your computer manually when convenient."
fi
