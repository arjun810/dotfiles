PLATFORM=`uname`

export PATH=~/bin:/usr/local/bin:/usr/sbin:$PATH

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
        export PATH=/opt/homebrew-cask/Caskroom/git-annex/latest/git-annex.app/Contents/MacOS:/usr/texbin:$PATH
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
alias ompcmb='cd build; CXX=clang-omp CC=clang-omp cmake ..; make; cd ..'

# MKL stuff on linux
if [[ $platform = "Linux" ]]; then
    source /opt/intel/bin/ifortvars.sh intel64
    source /opt/intel/bin/compilervars.sh intel64
    source /opt/intel/bin/iccvars.sh intel64
fi

function viewpcd(){
    if [[ -e $1:r.pcd ]]; then
        pcl_pcd2ply $1 $1:r.ply
    fi
    meshlab $1:r.ply
}

source ~/.secrets.env

if [[ -e /usr/local/share/chruby/chruby.sh ]]; then
    source /usr/local/share/chruby/chruby.sh
    source /usr/local/share/chruby/auto.sh
    chruby 2.4.2
fi

if type hub > /dev/null; then
    alias git=hub
fi

function gs_ip_from_instance() {
    echo $(aws ec2 describe-instances --region us-west-2 --profile gradescope --filters "Name=instance-state-name,Values=running" "Name=tag:Name,Values=$1" --query='Reservations[0].Instances[0].PublicIpAddress' | tr -d '"')
}

function list_ecs() {
    echo $(aws ec2 describe-instances --region us-west-2 --profile gradescope --filters "Name=tag:aws:autoscaling:groupName,Values=Production ECS" "Name=instance-state-name,Values=running" --query='Reservations[*].Instances[*].PublicIpAddress')
}

function gs-ssh-aws() {
    ssh ubuntu@$(gs_ip_from_instance "$1")
}

function web0() {
    gs-ssh-aws production-web-0
}

function web1() {
    gs-ssh-aws production-web-1
}

function redis() {
    gs-ssh-aws production-redis-sidekiq-0
}

function sidekiq() {
    gs-ssh-aws production-sidekiq-0
}

function staging() {
    gs-ssh-aws staging-web-0
}

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh
