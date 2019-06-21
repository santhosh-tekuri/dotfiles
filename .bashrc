dir=$(dirname `readlink ~/.zshrc`)

source $dir/.shrc

function ps1_color() {
    if [ $? -ne 0 ]; then
        echo -n -e "\033[31m"
    fi
}
PS1='$(ps1_color)\w $(git-ps1) ➤ \033[0m '
