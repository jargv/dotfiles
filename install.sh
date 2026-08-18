#! /usr/bin/env bash
set -euo pipefail

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
    rm -rf $DOT_CONFIG/$dest
    ln -snf $dir/$dotfile $DOT_CONFIG/$dest
  else
    ln -snf $dir/$dotfile $HOME/.$dest
  fi
done;

# Claude Code Setup
mkdir -p $HOME/.claude
for sub in commands skills; do
  ln -snf $dir/claude/$sub $HOME/.claude/$sub
done

# PI setup
mkdir -p $HOME/.pi/agent
rm -rf $HOME/.pi/agent/extensions
ln -snf $dir/pi/agent/extensions $HOME/.pi/agent/extensions
for resource in keybindings.json; do
  ln -snf $dir/pi/agent/$resource $HOME/.pi/agent/$resource
done

echo config installed
# echo "don't forget tpm ~/config/setup/tpm.sh"
