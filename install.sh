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

#have to do this separately since '.vim' is removed from filenames...
ln -snf $dir/vim $HOME/.vim

# nvim setup
ln -snf $dir/vim ${XDG_CONFIG_HOME:-~/.config}/nvim

#setup autokey
# mkdir -p ~/.config/autokey/data
# (cd ~/.config/autokey/data && ln -sf ~/config/autokey .)

#report completion of install script
echo config installed
echo "don't forget tpm ~/config/setup/tpm.sh"
