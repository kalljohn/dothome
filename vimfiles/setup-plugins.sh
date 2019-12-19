#!/bin/bash

# use vim-plug to manage plugins.

curl -fLo ./autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
    vim +PlugInstall +qall

([ ! -e ~/.vimrc ] || rm ~/.vimrc) && ln -s -f `pwd`/_vimrc ~/.vimrc
