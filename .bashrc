dir=$(cd $(dirname $BASH_SOURCE) && pwd)

source $dir/.shrc

bind 'set completion-ignore-case on'

function exit_color() {
    if [ $? -ne 0 ]; then
        echo -n -e "\033[31m"
    fi
}
PS1='$(exit_color)$(ssh-ps1)\w $(git-ps1)❯\033[0m '

# bash completion
test -f /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion
if [ "$(uname -s)" == "Darwin" ]; then
    export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
    [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
fi

export HISTFILE=${XDG_STATE_HOME}/bash/history
export HISTCONTROL=erasedups:ignorespace

# append current session history to .bash_history, rather than overwriting it
shopt -s histappend

# number of commands stored in memory history for current session
HISTSIZE=1000000

# number of commands allowed at startup & stored in history file
HISTFILESIZE=1000000

# record command in .bash_history immediately, to avoid losing history if you crash
PROMPT_COMMAND='history -a'

if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
fi
