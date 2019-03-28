alias dm=docker-machine
alias dc=docker-compose
alias dmls='docker-machine ls'

function dmenv(){
    eval "$(docker-machine env ${1:-default})"
}

function dbash(){
    docker exec -it $1 bash
}

function dtail(){
    docker logs -f --tail 100 $1 2>&1 | color
}

function dip(){
    docker inspect --format='{{range $p, $conf := .NetworkSettings.Networks}}{{$p}}: {{.IPAddress}}{{end}}' $1
}

function dkill(){
    if [ $1 = "-a" ]; then
        docker kill $(docker ps --format "{{.Names}}")
    else
        docker kill $*
    fi
}

function drm(){
    if [ $1 = "-a" ]; then
        docker rm $(docker ps -f status=exited --format "{{.Names}}")
    else
        docker rm $*
    fi
}

function docker_running_containers(){
    reply=($(docker ps --format "{{.Names}}"))
}

function docker_exited_containers(){
    reply=($(docker ps -f status=exited --format "{{.Names}}"))
}

function docker_all_containers(){
    reply=($(docker ps -a --format "{{.Names}}"))
}

compctl -K docker_running_containers dbash
compctl -K docker_all_containers dtail
compctl -K docker_running_containers dip
compctl -K docker_running_containers dkill
compctl -K docker_exited_containers drm

function docker-logs(){
    if [ "$#" -eq 0 ]; then
        session='*'
        pattern='^'
    else
        session="$1"
        pattern="^$1"
    fi

    tmux kill-session -t $session
    tmux -2 new-session -d -s "$session"

    i=0
    docker ps -a --format '{{.Names}}' | grep $pattern | while read container;
    do
        ((i++))
        tmux new-window -t $session:$i -n $container
        tmux send-keys 'eval $(docker-machine env ' "$DOCKER_MACHINE_NAME)" C-m
        tmux send-keys "clear && printf '\e[3J'" C-m
        tmux send-keys "docker logs -f $container" C-m
    done
    tmux kill-window -t $session:0
    tmux attach -t $session
    tmux kill-session -t $session
}
