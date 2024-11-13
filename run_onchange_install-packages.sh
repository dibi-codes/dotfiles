#!/bin/bash

set -eu

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || echo "oh-my-zsh might already be installed"

# Install p10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k || echo "powerlevel10k might already be installed"

# Install auto-suggestions
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions  || echo "zsh-autosuggestions might already be installed"

# Install syntax-highlights
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting || echo "zsh-syntax-highlighting might already be installed"

# Install oh-my-tmux
git clone --depth=1 https://github.com/gpakosz/.tmux.git "${HOME}/.tmux" || echo "oh-my-tmux might already be installed"
