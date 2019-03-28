function precmd(){
	echo -n -e "\033]7;${PWD}\007"
}

function preexec(){
	print -nrP %b%f
	echo -en "\e[0m"
}

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

# reevaluate the prompt expression each time a prompt is displayed
setopt prompt_subst

# remove any right prompt from display when accepting a command line
setopt transientrprompt 

PS1="%(?..%F{red})\$(git_prompt)➤ %f %F{yellow}%B"
RPS1='%K{blue}[%~]%k'
