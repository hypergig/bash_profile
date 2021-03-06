#! /bin/bash

set -o vi

# default vars
export EDITOR='subl -w'
_repos_dir="$HOME/repos"
_bash_profile_loc="$(dirname $(readlink ${BASH_SOURCE[0]}))"
_bash_profile_lib_loc="${_bash_profile_loc}/lib"
_fav_containers=(alpine:latest ubuntu:latest debian:latest python:3 hypergig/parrotsay)

# property_file.sh looks like, needs to be in the $HOME directory
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. $HOME/.property_file.env

# aliases
alias gr="cd $_repos_dir"
alias ga="cd $_repos_dir/$_most_common_repo"
alias jork="${_bash_profile_lib_loc}/jork.sh"
alias copy='tee /dev/stderr | xclip -sel clip'


# docker functions
docker-dedangle(){
  docker rmi -f $(docker images -q --filter "dangling=true")
}

docker-warm(){
  printf 'docker pull %s\n' ${_fav_containers[@]} | jork | grep 'Status'
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
  tmux -2 new-session htop -p $(cat /var/run/docker.pid)\; split-window -v docker stats\; split-window -v  watch -td docker ps\; attach
}


# git bash prompt
export GIT_PROMPT_ONLY_IN_REPO=1
export GIT_PROMPT_THEME=Minimal
source ~/repos/bash-git-prompt/gitprompt.sh

# you complete me
complete -C '/usr/local/bin/aws_completer' aws
source <(kubectl completion bash)

# my screen
docker run -t hypergig/parrotsay

