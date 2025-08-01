alias karabiner="sudo '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'"
alias kanata='sudo kanata -c ~/.config/kanata/kanata.kbd'

if ! command -v nvim &> /dev/null; then
    export EDITOR=nvim
    export MANPAGER='nvim +Man!'
fi
export CLICOLOR=true
export LSCOLORS=cxFxCxDxBxegedabagacad # to get colors in ls output
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export SCREENRC=$XDG_CONFIG_HOME/screen/screenrc
export NPM_CONFIG_CACHE=~/.cache/npm
export RUSTUP_HOME=$XDG_DATA_HOME/rustup
export FZF_DEFAULT_OPTS=--reverse

if [ -f /usr/local/bin/bash ]; then
    alias bash=/usr/local/bin/bash
fi

export GOPATH=~/go
export PATH=/usr/local/sbin:$GOPATH/bin:$PATH

alias cls=clear
alias kls="clear && printf '\e[3J'"
if ls --color=auto> /dev/null 2>&1; then
    alias ls="ls --color=auto"
fi
alias ll="ls -alh"
alias vi="vim -p"
alias chmox="chmod +x"
alias myip="ipconfig getifaddr en0"
alias mvn="mvn -Dhttps.protocols=TLSv1.2"
alias ssh-gen="ssh-keygen -t rsa -b 4096 -C"
alias encrypt="openssl enc -aes-256-cbc -salt"
alias decrypt="openssl enc -aes-256-cbc -d -md md5"

alias get='curl -G'
alias post='curl -XPOST'
alias postj='curl -XPOST -H "Content-Type: application/json"'
alias put='curl -XPUT'
alias putj='curl -XPUT -H "Content-Type: application/json"'
alias delete='curl -XDELETE'


# cd to git repo root directory
alias .git='cd "$(git rev-parse --show-toplevel)"'

export PATH=$dir/bin:$PATH
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

test -d /opt/homebrew/bin/ && eval $(/opt/homebrew/bin/brew shellenv)

# to get mouse scrolling work for git-log, man
export LESS=-R

# make grep highlight results using color
export GREP_OPTIONS='--color=auto'

export JDEBUG='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address'
export JSUSPEND='-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address'
if /usr/libexec/java_home -v 1.6 >/dev/null 2>&1; then
    export JAVA6_HOME=`/usr/libexec/java_home -v 1.6`
fi
if /usr/libexec/java_home -v 1.7 >/dev/null 2>&1; then
    export JAVA7_HOME=`/usr/libexec/java_home -v 1.7`
fi
if /usr/libexec/java_home -v 1.8 >/dev/null 2>&1; then
    export JAVA8_HOME=`/usr/libexec/java_home -v 1.8`
fi

# if screen session, unset PROMT_COMMAND
if [ -n "$STY" ]; then
    unset PROMPT_COMMAND
fi
