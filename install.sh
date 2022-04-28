#! /usr/bin/env bash

#install all the dotfiles
dir=$(pwd)
for dotfile in dotfiles/*; do
  dest=$(echo $dotfile | sed "
    s/^dotfiles\///
    s/\.el$//
    s/\.vim$//
  ")
  ln -snf $dir/$dotfile $HOME/.$dest
done;

# vim directory setup
# ln -snf $dir/vim $HOME/.vim

# nvim directory setup
ln -snf $dir/nvim ${XDG_CONFIG_HOME:-~/.config}/nvim

echo config installed
echo "don't forget tpm ~/config/setup/tpm.sh"
