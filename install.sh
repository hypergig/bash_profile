#! /bin/bash

ln -sf "$(pwd)/bash_profile" ~/.bash_profile
touch ~/.property_file.env
cd ~/repos
git clone git@github.com:magicmonty/bash-git-prompt.git
cd -
