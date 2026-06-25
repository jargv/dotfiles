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

# Claude Code has no XDG split: ~/.claude mixes config with live state
# (credentials, history, sessions). It also ignores ~/.config, so we keep the
# config dirs outside dotfiles/ (so the loop above doesn't mirror them to
# ~/.config/claude) and symlink them straight into ~/.claude, leaving state be.
mkdir -p $HOME/.claude
for sub in commands skills; do
  ln -snf $dir/claude/$sub $HOME/.claude/$sub
done

echo config installed
# echo "don't forget tpm ~/config/setup/tpm.sh"
