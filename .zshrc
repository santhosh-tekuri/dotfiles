dir=~/dotfiles

source $dir/.profile

# add custom completion scripts
fpath=(~/.zsh/completion $fpath)

# enable command completions
autoload -U compinit
compinit -u -D

mkdir -p ~/.cache/zsh
zstyle ':completion:*' cache-path ~/.cache/zsh/zcompcache

# case-insensitive tab completion for filenames (useful on Mac OS X)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# graphical menu to select completion options. (hit TAB to enable)
zstyle ':completion:*' menu select

setopt CORRECT # spell check commands
setopt AUTO_CD # just type `dir` to cd

bindkey -e # use emacs keymap for command line editing
bindkey \^U backward-kill-line # ctrl-u -> kill before cursor

# open command in $EDITOR using ctrl+x ctrl+e
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

setopt interactivecomments # ignore text folliwing # on command line

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

source ~/.local/share/zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# setup prompt --
setopt prompt_subst # reevaluate the prompt expression each time a prompt is displayed
setopt transientrprompt # remove any right prompt from display when accepting a command line
PS1="%(?..%F{red})\$(ssh-ps1)\$(git-ps1)❯%f "
RPS1='[%~]%f%k'
zle_highlight=(default:fg=yellow,bold)

# setup history --
mkdir -p ~/.local/state/zsh
HISTFILE=~/.local/state/zsh/history # history file name
SAVEHIST=500000 # number of lines in histoty
HISTSIZE=$SAVEHIST # number of lines the shell will keep within one session
HISTORY_IGNORE="(ls|ll|cd|pwd|exit|cls|kls)" # matching commands not written to history
setopt bang_hist # use ! for history expansion
setopt append_history # do not overwrite old history
setopt hist_ignore_dups # do not record consecutive duplicates
setopt hist_ignore_all_dups # do not record duplicates
setopt hist_save_no_dups # do not save duplicate entries
setopt hist_find_no_dups # do not display duplicates
setopt hist_ignore_space # do not record commands starting with space
setopt share_history # share history between sessions

source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh # suggest from history
source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# alias expansion --
function expand-alias() {
    [[ ! $BUFFER =~ "^\\\\.*" ]] && zle _expand_alias # expand only if not starts with '\'
    zle self-insert
}
zle -N expand-alias
bindkey -M main ' ' expand-alias
bindkey '^ '   magic-space          # control-space to bypass completion
bindkey -M isearch " "  magic-space # normal space during searches

# command customization --
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    compdef _gnu_generic fzf
    source ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh
    zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept
fi

if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
fi

# misc --
source $dir/bin/docker.sh
