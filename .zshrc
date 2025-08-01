dir=~/dotfiles

source $dir/.profile

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

# enable command completions
autoload -U compinit
compinit -u -D

if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    compdef _gnu_generic fzf
    source ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh
    zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept
fi

mkdir -p ~/.cache/zsh
zstyle ':completion:*' cache-path ~/.cache/zsh/zcompcache

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

# ctrl-u -> kill before cursor
bindkey \^U backward-kill-line

# open command in $EDITOR using ctrl+x ctrl+e
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# turns on interactive comments; comments begin with a #
setopt interactivecomments

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

# suffix aliases - "Open With..."
alias -s txt=vi

#export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
#source /Users/santhosh/.rvm/scripts/rvm

source ~/.local/share/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
fi

function setup_ps1() {
    # reevaluate the prompt expression each time a prompt is displayed
    setopt prompt_subst

    # remove any right prompt from display when accepting a command line
    setopt transientrprompt

    PS1="%(?..%F{red})\$(ssh-ps1)\$(git-ps1)❯%f "
    RPS1='[%~]%f%k'
    zle_highlight=(default:fg=yellow,bold)
}
setup_ps1

function setup_history() {
    mkdir -p ~/.local/state/zsh
    HISTFILE=~/.local/state/zsh/history # history file name
    SAVEHIST=1000 # number of lines in histoty
    HISTSIZE=1200 # number of lines the shell will keep within one session
    setopt APPEND_HISTORY # append the new history to the old
    setopt HIST_IGNORE_DUPS # do not record duplicates
    setopt HIST_IGNORE_SPACE # do not record commands starting with space
    setopt SHARE_HISTORY # share history between sessions
}
setup_history

#######################[ alias expansion ]##########################
function expand-alias() {
    [[ ! $BUFFER =~ "^\\\\.*" ]] && zle _expand_alias # expand only if not starts with '\'
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias
bindkey '^ '   magic-space          # control-space to bypass completion
bindkey -M isearch " "  magic-space # normal space during searches

source $dir/bin/docker.sh
