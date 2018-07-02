#! /bin/bash

# property_file.sh looks like, needs to be in the $HOME directory
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. $HOME/property_file.sh


# default vars
export EDITOR='subl -w'
export repos_dir="$HOME/repos"
export bash_profile_loc="$(dirname $(readlink ${BASH_SOURCE[0]}))"
export bash_profile_lib_loc="${bash_profile_loc}/lib"
export FAV_CONTAINERS='alpine:latest
                       busybox:latest
                       java:latest
                       jenkins:latest
                       quay.io/coreos/etcd:latest
                       python:2
                       python:3
                       ethereum/client-go:latest
                       kylemanna/bitcoind:latest
                       hypergig/parrotsay'


# aliases
alias gr="cd $repos_dir"
alias ga="cd $repos_dir/$most_common_repo"
alias jork="${bash_profile_lib_loc}/jork.sh"
alias reload="source ${BASH_SOURCE[0]}"
alias copy='xclip -sel clip'


# docker functions
docker-dedangle(){
  docker rmi -f $(docker images -q --filter "dangling=true")
}

docker-warm(){
  printf 'docker pull %s\n' $FAV_CONTAINERS | jork | grep 'Status'
}

docker-happy-compose(){
  docker-compose down -v && docker-compose build && docker-compose up
}

docker-reboot(){
  sudo systemctl restart docker.service
  sleep 3
  until docker images --all &> /dev/null; do
    echo 'waiting for docker to start'
    sleep 2
  done
  echo 'docker is up!'
}

docker-kill-all(){
  docker ps -aq | xargs docker rm -fv
}

docker-nuke(){
  docker-kill-all
  docker volume ls -q | xargs docker volume rm
  docker images -aq | xargs docker rmi -f
  docker-reboot
  echo 'warming docker cache background'
  docker-warm &> /dev/null &
}

docker-watch(){
  tmux -2 new-session htop\; split-window -v docker stats\; split-window -v  watch -td docker ps\; attach
}


# git bash prompt
export GIT_PROMPT_ONLY_IN_REPO=1
export GIT_PROMPT_THEME=Solarized_Ubuntu
source ~/repos/bash-git-prompt/gitprompt.sh

# my screen
docker run -t hypergig/parrotsay

