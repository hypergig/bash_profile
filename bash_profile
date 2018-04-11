#! /bin/bash

# property_file.sh looks like, needs to be in the $HOME directory
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. $HOME/property_file.sh


# terminal hacks
export CLICOLOR=1
export LSCOLORS=GxBxCxDxexegedabagaced
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
shopt -s checkwinsize


# default vars
export PATH="/usr/local/opt/python/libexec/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export EDITOR='subl -w'
export DOCKER_MACHINE_NAME='dev'
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
alias ll='ls -lahpr'
alias gr="cd $repos_dir"
alias ga="cd $repos_dir/$most_common_repo"
alias jork="${bash_profile_lib_loc}/jork.sh"
alias reload="source ${BASH_SOURCE[0]}"


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
  kill $(ps aux | grep com.docker.hyperkit | grep -v grep | awk '{ print $2 }')
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


# git bash prompt
GIT_PROMPT_ONLY_IN_REPO=1
GIT_PROMPT_THEME=Solarized
if [ -f "/usr/local/opt/bash-git-prompt/share/gitprompt.sh" ]; then
  __GIT_PROMPT_DIR="/usr/local/opt/bash-git-prompt/share"
  source "/usr/local/opt/bash-git-prompt/share/gitprompt.sh"
fi


# bash completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion


# my screen
docker run -t hypergig/parrotsay
