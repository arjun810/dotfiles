PLATFORM=`uname`

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git autojump)

# Some platform-specific stuff
case "$PLATFORM" in
    Darwin)
        plugins+=(brew)
	mailer_bin=mail
        ;;
    Linux)
	mailer_bin=mutt
	alias pbcopy='xclip -selection clipboard'
	alias pbpaste='xclip -selection clipboard -o'
        ;;
esac

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

alias ack=ack-grep

unsetopt correct_all

function edx() {
  pushd ~/Documents/cs188/edx
  . ./setup_env.sh
  popd
}

function rz() {
  . ~/.zshrc
}

function textme() {
  echo "$@" | $mailer_bin -s "new notification" 7029857442@txt.att.net
}

alias cmb='cd build; cmake ..; make; cd ..'

# MKL stuff on linux
if [[ $platform = "Linux" ]]; then
    source /opt/intel/bin/ifortvars.sh intel64
    source /opt/intel/bin/compilervars.sh intel64
    source /opt/intel/bin/iccvars.sh intel64 
fi

export PATH=~/bin:/usr/local/bin:$PATH
