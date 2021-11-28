#! /bin/bash

pushd ~
ln -s .dotfiles/.vimrc ~/.vimrc
ln -s .dotfiles/.zshrc ~/.zshrc
ln -s .dotfiles/.zshenv ~/.zshenv
ln -s .dotfiles/.zshlogin ~/.zshlogin
ln -s .dotfiles/.zimrc ~/.zimrc
ln -s .dotfiles/.gemrc ~/.gemrc
ln -s .dotfiles/.gitconfig ~/.gitconfig
ln -s .dotfiles/.tool-versions ~/.tool-versions
popd

git submodule init
git submodule update
