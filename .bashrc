dir=$(dirname `readlink ~/.zshrc`)

source $dir/.shrc

function ps1() {
    if [ $? -ne 0 ]; then
        echo -n -e "\033[31m"
    fi
    echo -n -e "$(git-ps1)➤ \033[0m"
}
PS1='$(ps1) '
