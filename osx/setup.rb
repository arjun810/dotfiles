$steps_filename = File.expand_path "~/.setup_steps"
if File.file? $steps_filename
    File.open($steps_filename, 'r') do |f|
        $completed = f.readlines.map{|x| x.strip}
    end
else
    $completed = []
end

$notes = []

def step(name)
    if $completed.include? name
        puts "Step '#{name}' already done; skipping."
        return
    else
        puts "Starting step '#{name}.'"
    end
    success = yield
    if success
        $completed << name
        File.open($steps_filename, 'a') do |f|
            f.write("#{name}\n")
        end
    else
        puts "Failed executing step '#{name}.' Aborting."
        exit
    end
end

def note(note)
    $notes << note
end

def command(command)
    system command
end

def clone(repo, destination)
    if repo.include? ":"
        command = "git clone #{repo} #{destination}"
    else
        command = "git clone git@github.com:#{repo} #{destination}"
    end
    system command
end

def pip(packages, opts={})
    packages = [packages].flatten
    command = "pip3 install #{packages.join(" ")}"
    system command
end

def gem(packages, opts={})
    packages = [packages].flatten
    command = "`asdf which gem` install #{packages.join(" ")}"
    system command
end

def prompt(message)
    puts message
    puts "Hit enter to continue."
    gets
end

step "Install homebrew" do
    command "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
end

step "Prompt for ssh keys" do
    prompt "Ensure your ssh keys are set up."
    File.exists? File.expand_path("~/.ssh")
end

step "Install dotfiles" do
    clone "git@github.com:arjun810/dotfiles", "~/.dotfiles"
end

step "Install Homebrew bundle" do
  command "brew bundle --file ~/.dotfiles/osx/Brewfile"
end

step "Install ruby" do
  command "asdf plugin add ruby"
  command "asdf install ruby latest"
end

step "Prompt for vim-plug" do
    prompt "Ensure you've installed vim-plug."
    File.exists? File.expand_path("~/.vim/autoload/plug.vim")
end

step "Init dotfiles" do
    command "cd ~/.dotfiles && ./init_dotfiles.sh"
end

step "Install vim plugins" do
  command "vim -c \"PlugInstall\" -c \"qa\""
end

step "Add zsh to system shells" do
    command "echo /opt/homebrew/bin/zsh | sudo tee -a /etc/shells"
end

step "Change shell to zsh" do
    command "chsh -s /opt/homebrew/bin/zsh"
end

step "Install Monaco" do
    note "You should remember to change your terminal font to Monaco for Powerline."
    prompt "A prompt will pop up so you can install Monaco. Make sure to hit 'Install Font.'"
    command 'open ~/.dotfiles/osx/"Monaco for Powerline.otf"'
end

step "Install iTerm2 colorschemes and fonts." do
    prompt "Don't forget to add the iTerm colorschemes. They're in ~/.dotfiles/osx."
    prompt "Don't forget to set up iTerm's fonts and update it so Powerline works."
end

step "Install zim" do
  command "mkdir ~/.zim"
  command "wget https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh -O ~/.zim/zimfw.zsh"
end

step "Install bundler" do
  gem "bundler"
end

# .amethyst has to be done manually since it's osx specific
# step "Link .amethyst" do
#     command "ln -s ~/.dotfiles/osx/.amethyst ~/.amethyst"
# end
# step "Install amethyst" do
#     note "You'll need to set up the privacy accessibility settings for Amethyst
#     after starting it for the first time. You'll also need to set up spaces
#     support as described at https://github.com/ianyh/Amethyst"
#     cask "amethyst"
# end

$notes.each do |note|
    puts note
end
