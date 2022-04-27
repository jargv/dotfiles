#!/bin/bash

set -e

if [ $(uname) == "Linux" ]; then
  if [ -x /usr/bin/apt ]; then
    sudo apt install libmsgpack-dev libuv1-dev
  else
    echo "couldn't find linux version"
    exit
  fi
fi

mkdir -p ~/build
cd ~/build
if [ ! -d neovim ]; then
  git clone https://github.com/neovim/neovim.git
  cd neovim
else
  cd neovim
  git pull
fi

mkdir -p build && cd build
cmake -GNinja ..
cmake --build .
