#!/usr/bin/env bash

dir=/tmp/base16

mkdir -p $dir
cd $dir
git clone https://github.com/chriskempson/base16-gnome-terminal.git base16
cd base16
for file in *.sh; do
  echo "doing ${file}"
  chmod +x $file
  ./$file
done;

rm -rf $dir
