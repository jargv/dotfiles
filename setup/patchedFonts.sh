#!/usr/bin/env zsh

# if [ -x pacman ]; then
#   sudo pacman -S fontforge
# fi

sudo apt-get install python python-fontforge

cd /tmp
git clone https://github.com/Lokaltog/vim-powerline.git
cd vim-powerline/fontpatcher
for font in $(find /usr/share/fonts/ -name '*.ttf' -or -name '*.otf') ~/.fonts/*; do
  python2 fontpatcher $font
done
mkdir -p ~/.fonts/
mv *.ttf ~/.fonts/
sudo fc-cache -vf
