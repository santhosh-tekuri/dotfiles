# history file name
HISTFILE=~/.zsh_history

# number of lines in histoty
SAVEHIST=1000

# number of lines the shell will keep within one session
HISTSIZE=1200

# append the new history to the old
setopt APPEND_HISTORY

# do not record duplicates
setopt HIST_IGNORE_DUPS

# do not record commands starting with space
setopt HIST_IGNORE_SPACE

# new sessions inherit current history
setopt SHARE_HISTORY

