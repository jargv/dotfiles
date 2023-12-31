#! /usr/bin/env bash
set -euo pipefail
set -v
set -o xtrace

DOT_CONFIG=${XDG_CONFIG_HOME:-~/.config}

# install all the dotfiles
dir=$(pwd)
for dotfile in dotfiles/* ; do
  dest=$(echo $dotfile | sed "
    s/^dotfiles\///
    s/\.el$//
    s/\.vim$//
  ")

  if [[ -d $dotfile ]]; then
    ln -snf $dir/$dotfile $DOT_CONFIG/$dest/
  else
    ln -snf $dir/$dotfile $HOME/.$dest
  fi
done;

echo config installed
echo "don't forget tpm ~/config/setup/tpm.sh"
