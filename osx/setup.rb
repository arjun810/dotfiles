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

def cask(cask_name)
    command = "brew cask install #{cask_name}"
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

def brew(packages, opts={})
    packages = [packages].flatten
    command = "brew install #{packages.join(" ")}"
    if opts[:cc]
        command += " --cc=#{opts[:cc]}"
    end
    if opts[:verbose]
        command += " --verbose"
    end
    if opts[:flags]
        opts[:flags] = [opts[:flags]].flatten
        command += " #{opts[:flags].join(" ")}"
    end
    system command
end

def pip(packages, opts={})
    packages = [packages].flatten
    command = "pip install #{packages.join(" ")}"
    system command
end

def prompt(message)
    puts message
    puts "Hit enter to continue."
    gets
end

step "Install homebrew" do
    command 'ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"'
end

step "Install wget git" do
    brew ['git', 'wget']
end

step "Prompt for ssh keys" do
    prompt "Ensure your ssh keys are set up."
    File.exists? File.expand_path("~/.ssh")
end

step "Install dotfiles" do
    command "git clone git@github.com:arjun810/dotfiles ~/.dotfiles"
end

step "Init dotfiles" do
    command "cd ~/.dotfiles && ./init_dotfiles.sh"
end

# .theanorc has to be done manually since it's osx specific
step "Link .theanorc" do
    command "ln -s ~/.dotfiles/osx/.theanorc ~/.theanorc"
end

# Install pcre separately because we want to use gcc-4.8 for it, since other
# formulas in the future are likely to depend on pcre. We need to install this
# before zsh because zsh depends on pcre.
step "Install pcre" do
    brew 'pcre', cc: "gcc-4.8"
end

step "Install zsh" do
    brew 'zsh'
end

step "Add zsh to system shells" do
    command "echo /usr/local/bin/zsh | sudo tee -a /etc/shells"
end

step "Get oh-my-zsh" do
    command "git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh"
end

step "Change shell to zsh" do
    command "chsh -s /usr/local/bin/zsh"
end

step "Install Monaco" do
    note "You should remember to change your terminal font to Monaco for Powerline."
    prompt "A prompt will pop up so you can install Monaco. Make sure to hit 'Install Font.'"
    command 'open ~/.dotfiles/osx/"Monaco for Powerline.otf"'
end

step "Make ~/bin" do
    command "mkdir ~/bin"
end

step "Install homebrew-cask" do
    command "brew tap phinze/homebrew-cask && brew install brew-cask"
end

step "Install iTerm2" do
    note "Don't forget to add the iTerm colorschemes. They're in ~/.dotfiles/osx."
    note "Don't forget to set up iTerm's fonts and update it so Powerline works."
    cask "iterm2"
end

step "Install MacVim" do
    note "Don't forget to link cask's mvim script to ~/bin/gvim"
    cask "macvim"
end

step "Install Chrome" do
    cask "google-chrome"
end

step "Install Firefox" do
    cask "firefox"
end

step "Install Alfred" do
    note "Don't forget to set up your hotkeys for Alfred."
    cask "alfred"
end

step "Set up Alfred with homebrew-cask" do
    command "brew cask alfred link"
end

step "Install f.lux" do
    cask "f-lux"
end

step "Install autojump" do
    brew "autojump"
end

step "Install git-annex" do
    cask "git-annex"
end

step "Install unrar" do
    brew "unrar"
end

step "Install ag" do
    brew "ag"
end

step "Install vlc" do
    cask "vlc"
end

step "Install mactex" do
    cask "mactex"
end

step "Install latexit" do
    cask "latexit"
end

step "Install VirtualBox" do
    cask "virtualbox"
end

step "Install Vagrant" do
    cask "vagrant"
end

step "Install Tunnelblick" do
    note "Don't forget to set up tunnelblick connections"
    cask "tunnelblick"
end

step "Install Skim" do
    cask "Skim"
end

step "Install meshlab" do
    cask "meshlab"
end

step "Install Google Voice/Video plugin" do
    cask "google-hangouts"
end

step "Install Flash" do
    cask "flash"
end

step "Tap homebrew/versions for gcc" do
    command "brew tap homebrew/versions"
end

step "Wait for Xcode to be installed" do
    prompt "Install Xcode via the App Store"
end

step "Accept Xcode license" do
    command "sudo xcodebuild -license"
end

step "Install gcc" do
    brew "gcc48"
end

step "Link gcc and g++" do
    command "ln -s /usr/local/bin/{gcc-4.8,gcc} && ln -s /usr/local/bin/{g++-4.8,g++}"
end

step "Install cmake" do
    brew "cmake"
end

step "Install Ceres dependency gflags" do
    brew "gflags", cc: "gcc-4.8"
end

step "Install Ceres dependency glog" do
    brew "glog", cc: "gcc-4.8"
end

step "Tap homebrew/science" do
    command "brew tap homebrew/science"
end

# WARNING: This relies on a custom version of the tbb formula, which I've
# submitted as a pull request to homebrew.
step "Install Ceres dependency suite-sparse" do
    prompt "Ensure that you're using the modified tbb formula that enables
    gcc-4.8, or that this has been merged into homebrew."
    brew "suite-sparse", cc: "gcc-4.8"
end

step "Install Ceres dependency eigen" do
    brew "eigen", cc: "gcc-4.8"
end

step "Install Ceres" do
    brew "ceres-solver", cc: "gcc-4.8"
end

step "Install python" do
    brew "python", cc: "gcc-4.8"
end

step "Upgrade setuptools and pip" do
    command "pip install --upgrade setuptools && pip install --upgrade pip"
end

step "Install qt" do
    note "Using clang for qt. This means that there may be future troubles
    linking against it. If so, when trying to get it to work with gcc, patch to
    remove the incompatible flags and see what happens."
    brew "qt"
end

step "Install pyqt" do
    brew "pyqt"
end

step "Install zeromq" do
    brew "zmq"
end

step "Install nose" do
    pip "nose"
end

step "Install ipython" do
    pip "ipython[zmq,qtconsole,notebook,test]"
end

step "Tap samueljohn/python" do
    command "brew tap samueljohn/python && brew update && brew upgrade"
end

step "Install numpy and scipy" do
    brew ["numpy", "scipy"], cc: "gcc-4.8"
end

step "Install theano" do
    pip "theano --no-deps git+git://github.com/Theano/Theano.git"
end

step "Install cython" do
    pip "cython"
end

step "Install opencv" do
    note "Using clang for opencv. This means that there may be future troubles
    linking against it. If so, when trying to get it to work with gcc, may need
    to disable QtKit (and video altogether) with a patch."
    brew "opencv", flags: ["--with-qt"]
end

# For PCL. Last I checked, their opencv formula was just for enabling OpenNI
# from OpenCV, which we don't care about.
step "Tap homebrew-cv" do
    command "brew tap fran6co/cv"
end

# For PCL.
step "Install libusb" do
    note "Using clang for libusb. This means that there may be future troubles
    linking against it. Couldn't easily get it to build with gcc."
    brew "libusb"
end

step "Install vtk5" do
    note "Using vtk5 for PCL. PCL will soon be updated for VTK6, so you may
    want to reinstall at that point."
    brew "vtk5", cc: "gcc-4.8", flags: ["--with-python", '-v', '--debug']
end

step "Install boost" do
    brew "boost", cc: "gcc-4.8", flags: ["--build-from-source"]
end

step "Install pcl" do
    prompt "PCL is being installed with debug enabled, because you'll need to
    accept that it's being linked against a Clang-based qt even though we're
    installing it with gcc."
    brew "pcl", cc: "gcc-4.8", flags: ["--HEAD", '--debug']
end

step "Link pcl_viewer" do
    command "ln -s /usr/local/Cellar/pcl/HEAD/bin/pcl_viewer.app/Contents/MacOS/pcl_viewer /usr/local/bin/pcl_viewer"
end

step "Make berkeley/v" do
    command "mkdir -p ~/Documents/berkeley/v"
end

step "Clone cyres" do
    clone "rll/cyres", "~/Documents/berkeley/v/cyres"
end

step "Install cyres" do
    command "cd ~/Documents/berkeley/v/cyres && python setup.py install"
end

step "Clone cycloud" do
    clone "rll/cycloud", "~/Documents/berkeley/v/cycloud"
end

step "Install cycloud" do
    command "cd ~/Documents/berkeley/v/cycloud && python setup.py install"
end

step "Clone pycb" do
    clone "rll/pycb", "~/Documents/berkeley/v/pycb"
end

step "Install pycb" do
    command "cd ~/Documents/berkeley/v/pycb && python setup.py install"
end

step "Clone perception" do
    clone "rll/perception", "~/Documents/berkeley/v/perception"
end

$notes.each do |note|
    puts note
end
