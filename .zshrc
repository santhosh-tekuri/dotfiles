export EDITOR=vi
export CLICOLOR=true
export LSCOLORS=cxFxCxDxBxegedabagacad # to get colors in ls output

hash -d personal="/Backup/projects/personal"
hash -d cognitree="/Backup/projects/cognitree"

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

# enable command completions
autoload -U compinit
compinit -D

# case-insensitive tab completion for filenames (useful on Mac OS X)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# graphical menu to select completion options. (hit TAB to enable)
zstyle ':completion:*' menu select

 # spell check commands
setopt CORRECT

# just type `dir` to cd
setopt AUTO_CD


# use emacs keymap for command line editing
bindkey -e

# turns on interactive comments; comments begin with a #
setopt interactivecomments

function ip(){
    if [ "$#" -eq 0 ]; then
        {
        for interface in `ifconfig | grep -o -e '^[a-z0-9]\+'`; do
            address=`ifconfig $interface | grep 'inet ' | cut -di -f 2 | cut -d ' ' -f2`
            if [ -n "$address" ]; then
                echo $interface $address
            fi
        done
        } | column -t
    else
        ifconfig $1 | grep 'inet ' | cut -di -f 2 | cut -d ' ' -f2
    fi        
}

function hilite(){
    echo -en "\033[31m"  ## red
    eval $* | while read line; do
        echo -en "\033[0m"  ## reset color
        echo $line
        echo -en "\033[31m"  ## red
    done
    exit_code=${pipestatus[1]}
    echo -en "\033[0m"  ## reset color
    return $exit_code
}

export GOPATH=~/go
export PATH=/usr/local/sbin:~/.scripts:$GOPATH/bin:$PATH

function color(){
    awk '
      /WARN/ {print "\033[35m" $0 "\033[39m"; system(""); next}
      /SEVERE/ {print "\033[31m" $0 "\033[39m"; system(""); next}
      /ERROR/ {print "\033[31m" $0 "\033[39m"; system(""); next}
      1; system("")
    '
}
alias cls=clear
alias ll="ls -alh"
alias grep="grep --color"
alias myip="ipconfig getifaddr en0"
alias mvn="mvn -Dhttps.protocols=TLSv1.2"

# suffix aliases - "Open With..."
alias -s txt=vi

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
#source /Users/santhosh/.rvm/scripts/rvm

# cd to git repo root directory
alias .git='cd "$(git rev-parse --show-toplevel)"'

dir=$(dirname `readlink ~/.zshrc`)
source $dir/bin/ps1.sh
source $dir/bin/hist.sh
source $dir/bin/docker.sh
source $dir/bin/virtualbox.sh
source $dir/bin/jdk.sh
source $dir/bin/go.sh
source ~/.localrc
