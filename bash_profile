#! /bin/bash

# property_file.sh looks like, needs to be in the $HOME directory 
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. $HOME/property_file.sh

echo "Hello $USER."

# terminal hacks
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it
shopt -s checkwinsize

# default vars
export PATH=/usr/local/bin:$PATH
export EDITOR='subl -w'
export DOCKER_MACHINE_NAME='dev'
export repos_dir="$HOME/repos"
export FAV_CONTAINERS="alpine:latest\n
                       busybox:latest\n
                       java:latest\n
                       jenkins:latest\n
                       quay.io/coreos/etcd:v2.2.0\n
                       python:2\n
                       $private_docker_repo/jessie\n
                       ethereum/client-go:latest\n
                       kylemanna/bitcoind:latest\n"

# docker functions
docker-dedangle(){
  docker rmi -f $(docker images -q --filter "dangling=true")
}

docker-refresh(){  
  docker images | grep "$private_docker_repo" | awk '{ print $1 ":" $2 }' | xargs -I {} -P10 docker pull {} | grep Status
}

docker-prewarm(){
  echo -e $FAV_CONTAINERS | xargs -I {} -P10 docker pull {} | grep Status
}

docker-happy-compose(){
  docker-compose down -v && docker-compose build && docker-compose up
}

docker-reboot(){
  kill $(ps aux | grep com.docker.hyperkit | grep -v grep | awk '{ print $2 }')
}

docker-nuke(){
  docker ps -aq | xargs docker rm -fv
  docker volume ls -q | xargs docker volume rm
  docker images -aq | xargs docker rmi -f
  docker-reboot
  sleep 3
  until docker images --all; do sleep 1; done
  echo 'docker is up!'
}

# aliases 
alias ll='ls -lahpr'
alias gr="cd $repos_dir"
alias ga="cd $repos_dir/$most_common_repo"

# ansible stuff
ANSIBLE_CONFIG="$repos_dir/$most_common_repo/tools/ansible/ansible.cfg"
export ANSIBLE_CONFIG

# brew stuff
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Solarized
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

# run every terminal 
echo $BASH_VERSION
. ~/.virtualenv-profile.sh
echo virtenv loaded
