RESEARCH = false
JULIA = false
JAVA = false
XCODE = false

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

def gem(packages, opts={})
    packages = [packages].flatten
    command = "gem install #{packages.join(" ")}"
    system command
end

def prompt(message)
    puts message
    puts "Hit enter to continue."
    gets
end

step "Install homebrew" do
    command '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
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

if RESEARCH
  # .theanorc has to be done manually since it's osx specific
  step "Link .theanorc" do
      command "ln -s ~/.dotfiles/osx/.theanorc ~/.theanorc"
  end
end

# .amethyst has to be done manually since it's osx specific
step "Link .amethyst" do
    command "ln -s ~/.dotfiles/osx/.amethyst ~/.amethyst"
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

step "Install iTerm2" do
    note "Don't forget to add the iTerm colorschemes. They're in ~/.dotfiles/osx."
    note "Don't forget to set up iTerm's fonts and update it so Powerline works."
    cask "iterm2"
end

step "Install MacVim" do
    note "Don't forget to link cask's mvim script to ~/bin/gvim"
    cask "macvim"
end

step "Install amethyst" do
    note "You'll need to set up the privacy accessibility settings for Amethyst
    after starting it for the first time. You'll also need to set up spaces
    support as described at https://github.com/ianyh/Amethyst"
    cask "amethyst"
end

step "Install Chrome" do
    cask "google-chrome"
end

step "Install Firefox" do
    cask "firefox"
end

step "Install silverlight" do
    cask "silverlight"
end

if JAVA
  step "Install java" do
      cask "java"
  end
end

step "Install Alfred" do
    note "Don't forget to set up your hotkeys for Alfred."
    cask "alfred"
end

step "Install f.lux" do
    cask "flux"
end

step "Install autojump" do
    brew "autojump"
end

step "Install aria2" do
    brew "aria2"
end

if RESEARCH
  step "Install xquartz" do
      cask "xquartz"
  end
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
    cask "skim"
end

if RESEARCH
  step "Install meshlab" do
      cask "meshlab"
  end

  step "Link meshlab bins" do
    system "ln -s /opt/homebrew-cask/Caskroom/meshlab/*/meshlab.app/Contents/MacOS/meshlab ~/bin/meshlab"
    system "ln -s /opt/homebrew-cask/Caskroom/meshlab/*/meshlab.app/Contents/MacOS/meshlabserver ~/bin/meshlabserver"
  end
end

step "Install Google Voice/Video plugin" do
    cask "google-hangouts"
end

step "Install Google Drive" do
    cask "google-drive"
end

step "Install Flash" do
    cask "flash"
end

step "Install Google Music client" do
    cask "radiant-player"
end

step "Install omnigraffle" do
  cask "omnigraffle"
end

if XCODE
  step "Wait for Xcode to be installed" do
      prompt "Install Xcode via the App Store"
  end

  step "Accept Xcode license" do
      command "sudo xcodebuild -license"
  end
end

if RESEARCH
  step "Tap homebrew/versions for gcc" do
      command "brew tap homebrew/versions"
  end

  step "Install gcc" do
      brew "gcc48"
  end

  step "Tap arjun810/openmp" do
      command "brew tap arjun810/openmp && brew update"
  end

  step "Install OpenMP Runtime" do
      brew "openmp-rt", flags: "--debug"
  end

  step "Install clang with OpenMP" do
      brew "llvm-omp", flags: "--HEAD"
  end

  step "Install cmake" do
      brew "cmake"
  end

  step "Install Ceres dependency gflags" do
      brew "gflags"
  end

  step "Install Ceres dependency glog" do
      brew "glog"
  end

  step "Tap homebrew/science" do
      command "brew tap homebrew/science"
  end

  step "Install Ceres dependency suite-sparse" do
      brew "suite-sparse"
  end

  step "Install Ceres dependency eigen" do
      brew "eigen"
  end

  step "Install Ceres" do
      brew "ceres-solver"
      #brew "arjun810/openmp/ceres-solver"
  end
end

step "Install python" do
    brew "python"
end

step "Upgrade setuptools and pip" do
    command "pip install --upgrade setuptools && pip install --upgrade pip"
end

step "Install qt" do
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

step "Install nosy, nosegrowlnotify" do
    pip ["nosy", "nosegrowlnotify"]
end

step "Install nose-parameterized" do
    pip "nose-parameterized"
end


step "Install ipython" do
    pip "ipython[zmq,qtconsole,notebook,test]"
end

step "Tap homebrew/python" do
    command "brew tap homebrew/python && brew update && brew upgrade"
end

step "Install numpy and scipy" do
    brew ["numpy", "scipy"]
end

step "Install freetype" do
    brew "freetype"
end

# May no longer be necessary
#step "Link freetype2 to freetype" do
#  note "Symlinking freetype2 to freetype for matplotlib. May want to remove this later."
#  command "ln -s /usr/local/include/freetype2 /usr/local/include/freetype"
#end

step "Install pillow" do
    brew "pillow"
end

step "Install matplotlib dependencies: pyparsing python-dateutil" do
    pip "pyparsing python-dateutil"
end

step "Install matplotlib" do
    pip "matplotlib"
end

step "Install pyyaml" do
    pip "pyyaml"
end

step "Install cython" do
    pip "cython"
end

if RESEARCH
  step "Install theano" do
      pip "theano --no-deps git+git://github.com/Theano/Theano.git"
  end
  step "Install hdf5" do
    brew "hdf5", flags: "--enable-cxx"
  end

  step "Install h5py" do
      pip "h5py"
  end

  step "Install h5py" do
      pip "h5py"
  end

  step "Install opencv" do
      brew "opencv", flags: ["--with-qt"]
  end

  # For PCL. Last I checked, their opencv formula was just for enabling OpenNI
  # from OpenCV, which we don't care about.
  step "Tap homebrew-cv" do
      command "brew tap fran6co/cv"
  end

  step "Install vtk5" do
      note "Using vtk5 for PCL. PCL will soon be updated for VTK6, so you may
      want to reinstall at that point."
      brew "vtk5", flags: ["--with-python", "--with-qt"]
  end

  step "Install boost" do
      brew "boost"
  end

  step "Install flann" do
    brew "flann", flags: "--enable-python"
  end

  step "Install pcl" do
      brew "pcl", flags: ["--HEAD", '--debug']
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
end

if JULIA
  # Needed for julia
  step "Install gfortran" do
    brew "gfortran"
  end

  step "Tap staticfloat/julia" do
      command "brew tap staticfloat/julia && brew update"
  end

  step "Install julia" do
    brew "julia", flags: "--with-accelerate"
  end
end

step "Install chruby" do
    brew "chruby"
end

step "Install ruby-build" do
    brew "ruby-build"
end

step "Make /opt/rubies" do
    prompt "You'll need to enter your sudo password"
    command "sudo mkdir /opt/rubies"
    command "sudo chown arjun:staff /opt/rubies"
end

step "Install ruby 2.3.0" do
    prompt "You may want to see if there's a new ruby version available before installing 2.3.0."
    system "ruby-build 2.3.0 /opt/rubies/2.3.0"
end

step "Ensure chruby is sourced properly in your .zshrc" do
    prompt "In order for 'gem' to work properly, make sure .zshrc is sourcing chruby."
end

step "Install bundler" do
  gem "bundler"
end

step "Install ansible" do
    brew "ansible"
end

# TODO try without this.
#step "Prompt about growl" do
#    prompt "Install growl from the App Store."
#end

step "Install slack" do
  cask "slack"
end

step "Install front" do
  cask "front"
end

step "Install quip" do
  cask "quip"
end

step "Install 1password" do
  cask "1password"
end

step "Install dropbox" do
  cask "dropbox"
end

step "Install packer" do
    brew "packer"
end

step "Install arq" do
  cask "arq"
end

step "Install sketch" do
  cask "sketch"
end

$notes.each do |note|
    puts note
end
