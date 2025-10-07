Dotfiles Setup

Prerequisites
- macOS (tested), zsh
- curl, git, Ruby or system Ruby for running setup.rb

Bootstrap on macOS
- Run: ruby osx/setup.rb
- The script will:
  - Install Homebrew non-interactively and add zsh to /etc/shells safely
  - Install Brewfile packages and casks
  - Clone or reuse ~/.dotfiles
  - Initialize symlinks with backups and XDG config shims
  - Install vim-plug and Zim, then install Vim plugins
  - Install asdf Ruby, set global version, and install bundler via asdf exec
  - Install pipx and ensure PATH
  - Optionally install Phoenix generator if Elixir is available
  - Print notes for manual steps like SSH keys, iTerm schemes, and font changes

Manual steps
- Generate SSH keys if missing: ssh-keygen -t ed25519 -C "you@example.com"
- iTerm2: import color schemes from osx/*.itermcolors; set a Powerline/Nerd Font
- Change terminal font to Monaco for Powerline or Meslo Nerd Font

Updating packages
- Brewfile: edit osx/Brewfile; run brew bundle --file osx/Brewfile
- Vim plugins: update .vimrc and run :PlugUpdate
- Zsh modules: edit .zimrc and run zimfw update

Per-host configuration
- Add ~/.zshrc.local for host-specific shell settings
- Git can include ~/.gitconfig.work via includeIf

Uninstall/cleanup (manual for now)
- Remove symlinks in $HOME
- Restore backups with .bak.TIMESTAMP suffix created by init_dotfiles.sh