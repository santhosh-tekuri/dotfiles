#!/usr/bin/env bash

echo source $PWD/.bashrc >> ~/.bashrc
echo source $PWD/.zshrc >> ~/.zshrc
echo source $PWD/.vimrc >> ~/.vimrc
echo source $PWD/.screenrc >> ~/.screenrc
mkdir -p ~/.ssh
echo Include $PWD/.ssh/config >> ~/.ssh/config

# link .config subfolders
mkdir -p ~/.config
for dir in $PWD/.config/*; do
    ln -s $dir ~/.config
done

# install zsh plugins
mkdir -p ~/.local/share/zsh
cd ~/.local/share/zsh
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/zsh-users/zsh-history-substring-search.git
git clone https://github.com/Aloxaf/fzf-tab
cd -

