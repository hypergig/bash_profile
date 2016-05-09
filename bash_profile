#! /bin/bash

# property_file.sh looks like, needs to be in the $HOME directory 
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. $HOME/property_file.sh

echo "Hello $USER."

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
                       $private_docker_repo/jessie\n"

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
  nosetests && docker-compose rm -f && docker-compose build && docker-compose up
}

docker-machine-reboot(){
  docker-machine restart $DOCKER_MACHINE_NAME && \
  docker-machine regenerate-certs -f $DOCKER_MACHINE_NAME && \
  docker-machine-environment
}

docker-machine-environment(){
  docker_machine_count=$(docker-machine ls --quiet | wc -l)
  if [ $docker_machine_count -ne 0 ]
  then
    if [ $(docker-machine status $DOCKER_MACHINE_NAME) == "Running" ]
    then
      eval "$(docker-machine env $DOCKER_MACHINE_NAME)"
      echo "docker host: $DOCKER_HOST"
    else
      echo "docker not running"
    fi
  else
    echo "no docker machines created"
  fi
}

docker-machine-make(){
  docker_machine_count=$(docker-machine ls --quiet | wc -l)
  if [ $docker_machine_count -eq 0 ]
  then
    docker-machine create \
      --driver "virtualbox" \
      --virtualbox-cpu-count "2" \
      --virtualbox-memory "2096" \
      $DOCKER_MACHINE_NAME 
  else
    echo "docker machine already created"
  fi

  docker-machine-environment
  docker-prewarm
}

docker-machine-rebuild(){
  docker-machine rm -f $DOCKER_MACHINE_NAME && docker-machine-make
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
docker-machine-environment
echo $BASH_VERSION
