#!/usr/bin/env bash

#fail on first error
set -e

if [ $(uname) == "Linux" ]; then
  sudo apt-get install xorg-dev # for x, for clipboard
fi

mkdir -p ~/build
cd ~/build
if [ ! -d vim ]; then
  git clone https://github.com/vim/vim.git
fi
cd vim

make distclean

#find the feature list in vim with :h feature-list
./configure \
  --with-features=huge \
  --enable-multibyte \
  --with-x \
  --enable-python3interp \
  --with-python3-config-dir=/usr/lib/python3.5/config \
  --enable-luainterp

make
sudo make install
