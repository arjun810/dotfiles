#! /bin/bash

set -euo pipefail

DOTDIR="${HOME}/.dotfiles"
FILES=(.vimrc .zshrc .zshenv .zlogin .zimrc .gemrc .gitconfig .tool-versions)

for file in "${FILES[@]}"; do
  target="${HOME}/${file}"
  src="${DOTDIR}/${file}"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "${target}.bak.$(date +%s)"
  fi
  ln -sfn "$src" "$target"
done

git submodule update --init --recursive

# XDG config symlinks where supported
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
mkdir -p "${XDG_CONFIG_HOME}/vim" "${XDG_CONFIG_HOME}/git"

# vimrc -> ~/.config/vim/vimrc
vim_target="${XDG_CONFIG_HOME}/vim/vimrc"
vim_src="${DOTDIR}/.vimrc"
if [ -e "$vim_target" ] && [ ! -L "$vim_target" ]; then
  mv "$vim_target" "${vim_target}.bak.$(date +%s)"
fi
ln -sfn "$vim_src" "$vim_target"

# git config -> ~/.config/git/config
git_target="${XDG_CONFIG_HOME}/git/config"
git_src="${DOTDIR}/.gitconfig"
if [ -e "$git_target" ] && [ ! -L "$git_target" ]; then
  mv "$git_target" "${git_target}.bak.$(date +%s)"
fi
ln -sfn "$git_src" "$git_target"
