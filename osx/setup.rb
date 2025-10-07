$steps_filename = File.expand_path "~/.setup_steps"
if File.file? $steps_filename
    File.open($steps_filename, 'r') do |f|
        $completed = f.readlines.map{|x| x.strip}
    end
else
    $completed = []
end

$notes = []

# Keep sudo alive for the duration of the setup
begin
  if system('command -v sudo >/dev/null 2>&1')
    system 'sudo -v'
    Thread.new do
      loop do
        system 'sudo -n true'
        sleep 60
      end
    end
  end
rescue
  # ignore
end

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
    command = "python3 -m pip install #{packages.join(" ")}"
    system command
end

def gem(packages, opts={})
    packages = [packages].flatten
    command = "asdf exec gem install #{packages.join(" ")}"
    system command
end

def prompt(message)
    puts message
    puts "Hit enter to continue."
    gets
end

step "Install homebrew" do
    ENV["NONINTERACTIVE"] = "1"
    command "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
end

step "Check ssh keys" do
    ssh_dir = File.expand_path("~/.ssh")
    have_dir = File.exist?(ssh_dir)
    have_key = ["id_ed25519.pub", "id_rsa.pub"].any? { |k| File.exist?(File.join(ssh_dir, k)) }
    unless have_dir && have_key
      note "SSH keys not found. Generate one with: ssh-keygen -t ed25519 -C \"your_email@example.com\""
    end
    true
end

step "Install dotfiles" do
    dest = File.expand_path("~/.dotfiles")
    if File.exist?(dest)
      puts "~/.dotfiles already exists; skipping clone."
      true
    else
      clone "git@github.com:arjun810/dotfiles", dest
    end
end

step "Install Homebrew bundle" do
  prefix = `brew --prefix 2>/dev/null`.strip
  if prefix.nil? || prefix.empty?
    prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
  end
  ENV["PATH"] = "#{prefix}/bin:#{ENV["PATH"]}"
  command "brew bundle --file ~/.dotfiles/osx/Brewfile"
end

step "Install ruby build dependencies" do
  prefix = `brew --prefix 2>/dev/null`.strip
  if prefix.nil? || prefix.empty?
    prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
  end
  ENV["PATH"] = "#{prefix}/bin:#{ENV["PATH"]}"
  deps = %w[autoconf bison openssl@3 readline libyaml gmp zlib]
  command "brew install #{deps.join(' ')}"
end

step "Install ruby" do
  plugins = `asdf plugin list 2>/dev/null`.lines.map { |l| l.strip }
  added = true
  unless plugins.include?("ruby")
    added = command "asdf plugin add ruby"
  end
  installed = command "asdf install ruby latest"
  set_global = command "asdf global ruby latest"
  added && installed && set_global
end

step "Install vim-plug" do
    plug_path = File.expand_path("~/.vim/autoload/plug.vim")
    if File.exist?(plug_path)
      true
    else
      command 'curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    end
end

step "Init dotfiles" do
    command "cd ~/.dotfiles && ./init_dotfiles.sh"
end

step "Install vim plugins" do
  command "vim -c \"PlugInstall\" -c \"qa\""
end

step "Add zsh to system shells" do
    shells_file = "/etc/shells"
    prefix = `brew --prefix 2>/dev/null`.strip
    if prefix.nil? || prefix.empty?
      prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
    end
    zsh_path = File.join(prefix, "bin", "zsh")
    lines = File.readlines(shells_file).map { |l| l.strip }
    if lines.include?(zsh_path)
      true
    else
      command "echo #{zsh_path} | sudo tee -a #{shells_file}"
    end
end

step "Change shell to zsh" do
    current = ENV["SHELL"]
    prefix = `brew --prefix 2>/dev/null`.strip
    if prefix.nil? || prefix.empty?
      prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
    end
    target = File.join(prefix, "bin", "zsh")
    if current == target
      true
    else
      command "chsh -s #{target}"
    end
end

step "Install Monaco" do
    note "Change your terminal font to Monaco for Powerline (installed in ~/.dotfiles/osx)."
    command 'open ~/.dotfiles/osx/"Monaco for Powerline.otf"'
end

step "Install iTerm2 colorschemes and fonts." do
    note "Import iTerm2 color schemes from ~/.dotfiles/osx and set Powerline-compatible fonts."
    true
end

step "Install zim" do
  ok = command "mkdir -p ~/.zim"
  ok = ok && command "wget https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh -O ~/.zim/zimfw.zsh"
  ok = ok && command "zsh -i -c \"~/.zim/zimfw.zsh install\""
  ok
end

step "Install bundler" do
  gem "bundler"
end

step "Install hex" do
  if system('mix --version >/dev/null 2>&1')
    command "mix local.hex --force"
  else
    note "Elixir/mix not found; install Elixir/Erlang via Homebrew or asdf before running mix commands."
    true
  end
end

step "Install phoenix application generator" do
  if system('mix --version >/dev/null 2>&1')
    command "mix archive.install hex phx_new --force"
  else
    note "Skipping Phoenix installer because mix is not available."
    true
  end
end

step "Install pipx" do
  prefix = `brew --prefix 2>/dev/null`.strip
  if prefix.nil? || prefix.empty?
    prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
  end
  ENV["PATH"] = "#{prefix}/bin:#{ENV["PATH"]}"
  ok = command "brew install pipx"
  ok = ok && command "pipx ensurepath"
  ok
end

step "Install Nerd Font via Homebrew cask" do
  prefix = `brew --prefix 2>/dev/null`.strip
  if prefix.nil? || prefix.empty?
    prefix = File.directory?("/opt/homebrew") ? "/opt/homebrew" : "/usr/local"
  end
  ENV["PATH"] = "#{prefix}/bin:#{ENV["PATH"]}"
  ok = command "brew tap homebrew/cask-fonts"
  ok = ok && command "brew install --cask font-meslo-lg-nerd-font"
  ok
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
