#!/usr/bin/env bash

echo source `pwd`/.bashrc >> ~/.bashrc
echo source `pwd`/.zshrc >> ~/.zshrc
echo source `pwd`/.vimrc >> ~/.vimrc
echo source `pwd`/.screenrc >> ~/.screenrc
mkdir -p ~/.ssh
echo Include `pwd`/.ssh/config >> ~/.ssh/config

mkdir -p ~/.config
for dir in `pwd`/.config/*; do
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

