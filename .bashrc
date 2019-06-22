dir=$(dirname `readlink ~/.zshrc`)

source $dir/.shrc

function exit_color() {
    if [ $? -ne 0 ]; then
        echo -n -e "\033[31m"
    fi
}
PS1='$(exit_color)\w $(git-ps1) ➤ \033[0m '
