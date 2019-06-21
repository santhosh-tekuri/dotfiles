# reevaluate the prompt expression each time a prompt is displayed
setopt prompt_subst

# remove any right prompt from display when accepting a command line
setopt transientrprompt 

PS1="%(?..%F{red})\$(git-ps1)➤ %f "
RPS1='%K{blue}[%~]%k'
zle_highlight=(default:fg=yellow,bold)
