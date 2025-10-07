#!/usr/bin/env bash
set -euo pipefail

DOTDIR="${HOME}/.dotfiles"
FILES=(.vimrc .zshrc .zshenv .zlogin .zimrc .gemrc .gitconfig .tool-versions)

for file in "${FILES[@]}"; do
  target="${HOME}/${file}"
  if [ -L "$target" ]; then
    rm -f "$target"
  fi
  # restore latest backup if exists
  latest_backup=$(ls -1t ${target}.bak.* 2>/dev/null | head -n1 || true)
  if [ -n "${latest_backup}" ]; then
    mv "${latest_backup}" "$target"
  fi
done

# XDG config shims
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
rm -f "${XDG_CONFIG_HOME}/vim/vimrc" || true
rm -f "${XDG_CONFIG_HOME}/git/config" || true