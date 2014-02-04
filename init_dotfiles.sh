#! /bin/bash

pushd ~
ln -s .dotfiles/.vimrc ~/.vimrc
ln -s .dotfiles/.zshrc ~/.zshrc
ln -s .dotfiles/.gemrc ~/.gemrc
if [ ! -L ~/.vim ]
then
    ln -s .dotfiles/.vim ~/.vim
fi
popd

git submodule init
git submodule update

vim -c "BundleInstall" -c "qa"
