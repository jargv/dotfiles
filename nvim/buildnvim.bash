#!/bin/bash

set -e

if [ $(uname) == "Linux" ]; then
  if [ -x /usr/bin/apt ]; then
    sudo apt-get install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
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

make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
