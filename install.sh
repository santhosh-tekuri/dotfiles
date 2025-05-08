#!/usr/bin/env bash

function addline() {
    if [ -f "$2" ]; then
        grep -qxF "$1" "$2" || echo "$2" >> "$1"
    else
        echo "$2" >> "$1"
    fi
}

addline "source $PWD/.bashrc" ~/.bashrc
addline "source $PWD/.zshrc" ~/.zshrc
addline "source $PWD/.vimrc" ~/.vimrc
addline "source $PWD/.screenrc" ~/.screenrc
mkdir -p ~/.ssh
addline "Include $PWD/.ssh/config" ~/.ssh/config

function link() {
    local src=$1
    local tgt=$2
    local tgtfile=$tgt/$(basename $src)
    if [ -e $tgtfile ]; then
        if [ $(readlink $tgtfile) == $src ]; then
            return 0
        fi
    fi
    ln -s $src $tgt
}

# link .config subfolders
mkdir -p ~/.config
for dir in $PWD/.config/*; do
    link $dir ~/.config
done

function gitclone() {
    local url=$1
    local last=${url##*/}
    local name=${last%%.git}
    [ ! -d $name ] && git clone $url
}

# install zsh plugins
mkdir -p ~/.local/share/zsh
cd ~/.local/share/zsh
gitclone https://github.com/zdharma-continuum/fast-syntax-highlighting.git
gitclone https://github.com/zsh-users/zsh-autosuggestions.git
gitclone https://github.com/zsh-users/zsh-history-substring-search.git
gitclone https://github.com/Aloxaf/fzf-tab.git
cd - > /dev/null

