#! /bin/bash

mkdir ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/naver/d2codingfont/releases/download/VER1.3.2/D2Coding-Ver1.3.2-20180524.zip
unzip D2Coding-Ver1.3.2-20180524.zip

fc-cache -f -v
fc-list | grep -i d2coding

# rm -rf d2coding*