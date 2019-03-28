SAVEHIST=1000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY
HISTSIZE=1200

export EDITOR=vi
export CLICOLOR=true
export LSCOLORS=cxFxCxDxBxegedabagacad # to get colors in ls output

hash -d personal="/Backup/projects/personal"
hash -d cognitree="/Backup/projects/cognitree"

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

## Completions
autoload -U compinit
compinit -D

# case-insensitive tab completion for filenames (useful on Mac OS X)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# graphical menu to select completion options. (hit TAB to enable)
zstyle ':completion:*' menu select

setopt CORRECT # spell check commands
setopt AUTO_CD # just type `dir` to cd
setopt HIST_IGNORE_DUPS # don't record duplicares
setopt HIST_IGNORE_SPACE # don't record commands starting with space
setopt interactivecomments
setopt transientrprompt # remove any right prompt from display when accepting a command line

bindkey -e

function precmd(){
	echo -n -e "\033]7;${PWD}\007"
}

function preexec(){
	print -nrP %b%f
	echo -en "\e[0m"
}

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

alias .git='cd "$(git rev-parse --show-toplevel)"'
function git_prompt {
    curr_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null);
    if [ $? -eq 0 ]; then
        curr_remote=$(git config branch.$curr_branch.remote);
        if git config branch.$curr_branch.merge > /dev/null; then
            curr_merge_branch=$(git config branch.$curr_branch.merge | cut -d / -f 3);
            ahead=$(git rev-list --left-only --count $curr_branch...$curr_remote/$curr_merge_branch);
            behind=$(git rev-list --right-only --count $curr_branch...$curr_remote/$curr_merge_branch);

            if [ $ahead -ne 0 ]; then
                echo -n "+$ahead "
            fi
            if [ $behind -ne 0 ]; then
                echo -n "-$behind "
            fi
        fi
        echo -n $curr_branch
        #git diff HEAD --quiet &> /dev/null || echo -n " *"
        echo -n " "
    fi
}
setopt prompt_subst
PS1="%(?..%F{red})\$(git_prompt)➤ %f %F{yellow}%B"
RPS1='%K{blue}[%~]%k'

dir=$(dirname `readlink ~/.zshrc`)
source $dir/bin/docker.sh
source $dir/bin/virtualbox.sh
source $dir/bin/jdk.sh
