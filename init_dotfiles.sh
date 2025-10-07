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
