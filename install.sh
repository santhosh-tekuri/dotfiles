#!/usr/bin/env bash

set -e

function addline() {
    if [ -f "$2" ]; then
        grep -qxF "$1" "$2" || echo "$2" >> "$1"
    else
        echo appending to $1
        echo "$2" >> "$1"
    fi
}

function link() {
    local src=$1
    local tgt=$2
    local tgtfile=$tgt/$(basename $src)
    if [ -e $tgtfile ]; then
        if [ $(readlink $tgtfile) == $src ]; then
            return 0
        fi
    fi
    echo linking $src
    ln -s $src $tgt
}

function gitclone() {
    local url=$1
    local last=${url##*/}
    local name=${last%%.git}
    if [ -d $name ]; then
        echo pulling $name
        cd $name && git pull && cd - > /dev/null
    else
        echo fetching $name
        git clone $url
    fi
}

addline "source $PWD/.bashrc" ~/.bashrc
addline "source $PWD/.zshrc" ~/.zshrc
addline "source $PWD/.vimrc" ~/.vimrc
mkdir -p ~/.ssh
addline "Include $PWD/.ssh/config" ~/.ssh/config

# link .config subfolders
mkdir -p ~/.config
for dir in $PWD/.config/*; do
    link $dir ~/.config
done

# install zsh plugins
mkdir -p ~/.local/share/zsh
cd ~/.local/share/zsh
gitclone https://github.com/zdharma-continuum/fast-syntax-highlighting.git
gitclone https://github.com/zsh-users/zsh-autosuggestions.git
gitclone https://github.com/zsh-users/zsh-history-substring-search.git
gitclone https://github.com/Aloxaf/fzf-tab.git
cd - > /dev/null

