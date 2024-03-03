#! /bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)
COPYPATH="${SCRIPTPATH}/copy"

echo "copy the original bashrc and vimrc to bashrc_origin and vimrc_origin"
cp ~/.bashrc ~/.bashrc_origin
cp ~/.vimrc ~/.vimrc_origin

echo "copy the new bashrc and vimrc"
cat "${COPYPATH}/copy_to_vimrc.txt" > ~/.vimrc
cat "${COPYPATH}/copy_to_bashrc.txt" > ~/.bashrc

echo "end..!"