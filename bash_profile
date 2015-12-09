# property_file.sh looks like, needs to be in the ~ directory 
# export private_docker_repo=something.io/this
# export most_common_repo=foo
#
. property_file.sh

echo Hello Jordan.

export PATH=/usr/local/bin:$PATH
export EDITOR='subl -w'

docker-dedangle(){
  docker rmi -f $(docker images -q --filter "dangling=true")
}

docker-refresh(){  
  docker images | grep "$private_docker_repo" | awk '{ print $1 ":" $2 }' | xargs -I {} -P10 docker pull {} | grep Status
}

docker-happy-compose(){
  nosetests && docker-compose rm -f && docker-compose build && docker-compose up
}


alias ll='ls -lahpr'

export repos_dir='~/repos'

alias gr="cd $repos_dir"
alias ga="cd $repos_dir/$most_common_repo"


ANSIBLE_CONFIG="/Users/jordan/$repos_dir/$most_common_repo/tools/ansible/ansible.cfg"
export ANSIBLE_CONFIG

if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Solarized
  GIT_PROMPT_ONLY_IN_REPO=1
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

if [ $(docker-machine status dev) == "Running" ]
then
  eval "$(docker-machine env dev)"
  echo "docker host: $DOCKER_HOST"
else
  echo "docker not running"
fi

echo $BASH_VERSION
