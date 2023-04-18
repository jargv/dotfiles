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

DOT_CONFIG=${XDG_CONFIG_HOME:-~/.config}

# nvim directory setup
ln -snf $dir/nvim ${DOT_CONFIG}/nvim

# ranger config setup
ln -snf $dir/ranger ${DOT_CONFIG}/ranger
ln -snf $dir/alacritty ${DOT_CONFIG}/alacritty
ln -snf $dir/kitty ${DOT_CONFIG}/kitty

echo config installed
echo "don't forget tpm ~/config/setup/tpm.sh"
