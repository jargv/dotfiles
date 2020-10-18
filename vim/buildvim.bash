#!/bin/bash

set -e

if [ $(uname) == "Linux" ]; then
  echo "TODO: check if --with-x is ned in the configure command below"
  exit
  if [ -x /usr/bin/pacman ]; then
    sudo pacman -S xorg-server-devel
  elif [ -x /usr/bin/apt ]; then
    sudo apt install build-essential xorg-dev libx11-dev \
      libxtst-dev python3-dev libncurses5-dev gnome-devel
  else
    echo "couldn't find linux version"
    exit
  fi
fi

mkdir -p ~/build
cd ~/build
if [ ! -d vim ]; then
  git clone https://github.com/vim/vim.git
fi
cd vim
git pull

make distclean

#find the feature list in vim with :h feature-list
./configure \
  --with-features=huge \
  --enable-multibyte \
  --enable-gui \
  --enable-job \
  --enable-channel \
  --enable-terminal \
  --enable-python3interp=yes \
  --with-python3-config-dir=$(python3-config --configdir) \
  --enable-luainterp

make
sudo make install

vim --version | grep clipboard
vim --version | grep terminal
vim --version | grep python3
