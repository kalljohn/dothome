#!/bin/sh

# use vim-plug to manage plugins.

curl -fLo ./autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
    vim -E -s -u ./_vimrc +PlugInstall +qall
