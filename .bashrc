dir=$(dirname `readlink ~/.zshrc`)

source $dir/.shrc

function exit_color() {
    if [ $? -ne 0 ]; then
        echo -n -e "\033[31m"
    fi
}
PS1='$(exit_color)\w $(git-ps1) ➤ \033[0m '

# bash completion
test -f /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion
if [ "$(uname -s)" == "Darwin" ]; then
    export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
    [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"
fi
