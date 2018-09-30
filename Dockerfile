FROM debian:9.5

## Basic setup
#
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y git tmux vim dos2unix ssh openssh-server locales wget dbus-x11 

ARG user

RUN useradd -ms /bin/bash -u 1001 $user && \
    mkdir /var/run/sshd && chmod 0750 /var/run/sshd 

RUN mkdir /home/$user/.ssh && \ 
    printf 'TCPKeepAlive yes\nServerAliveInterval 30' >> /home/$user/.ssh/config 

# Proper directory color, useful when using WSL
COPY configurations/.dircolors /home/$user/.dircolors

# Configure timezone and locale
RUN echo "Europe/Helsinki" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_GB.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_GB.UTF-8

# X11
RUN echo X11Forwarding yes >> /etc/ssh/sshd_config && \
    echo X11UseLocalhost yes >> /etc/sshsshd_config && \
    echo AddressFamily inet >> /etc/ssh/sshd_config
## End basic setup

## Tmux
COPY configurations/.tmux.conf /home/$user/.tmux.conf
RUN echo "\nalias tmux='tmux -2'\n" >> /home/$user/.bashrc

## Neovim
# Since the image app doesn't work, build and install instead
#RUN build_dependencies="curl unzip gettext pkg-config libtool-bin automake cmake build-essential" && \
#  apt-get update && apt-get install -y $build_dependencies && \ 
#  git clone https://github.com/neovim/neovim.git && \
#  cd neovim && git checkout tags/v0.3.1 -b 0.3.1 && \
#  make CMAKE_BUILD_TYPE=Release && \
#  make install && \
#  make clean && cd .. && rm -rf neovim && \
#  apt-get remove -y $build_dependences && apt-get -y autoremove && apt-get -y autoclean

# fzf finder
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/$user/.fzf && \
    dos2unix /home/$user/.fzf/install && \ 
    chown $user:$user -R /home/$user/.fzf && \
    runuser -l $user -c "/home/$user/.fzf/install"

## VIM Customization
# Global configuration
#COPY configurations/vimrc.local /etc/vim/vimrc.local

# User-only configuration, packages can be freely installed
COPY configurations/vimrc.local /home/$user/.vimrc

## Development package installation
# WARNING installation order does matter from now

## Spacemacs
# Use develop branch for latest language support
RUN apt-get install -y emacs25 && \
    git clone --branch develop https://github.com/syl20bnr/spacemacs /home/$user/.emacs.d

# Java for Spacemacs
RUN mkdir -p /home/$user/.emacs.d/eclipse.jdt.ls/server && \
    cd /home/$user/.emacs.d/eclipse.jdt.ls/ && \
    wget http://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz -O jdt.tar && \
    tar xf jdt.tar -C server && \
    rm -rf jdt.tar

# This setting is important when working in Windows machine
# This should be set after Emacs due to this issue 
# https://github.com/syl20bnr/spacemacs/issues/10645
COPY configurations/.gitconfig /home/$user/.gitconfig

## Setting correct permission, this should be at bottom.
RUN chown -R $user:$user /home/$user

## Rust
# Install Rust, must make sure all installation after this has correct permission for user
RUN apt-get install -y build-essential curl && \
   runuser -l $user -c "curl https://sh.rustup.rs -sSf | sh -s -- -y" && \
   runuser -l $user -c "rustup toolchain add nightly && cargo +nightly install racer" && \
   runuser -l $user -c "rustup component add rust-src"

RUN echo '\nexport RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"\n' \ 
   >> /home/$user/.profile

COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
