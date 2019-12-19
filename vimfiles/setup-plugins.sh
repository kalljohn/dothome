#!/bin/sh

# use vim-plug to manage plugins.

curl -fLo ./autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

([ ! -e ~/.vimrc ] || rm ~/.vimrc) && ln -s -f `pwd`/_vimrc ~/.vimrc

sh -c "vim +PlugInstall +qall"
