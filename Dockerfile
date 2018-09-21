FROM debian:9.5

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	apt-get install -y git tmux vim dos2unix ssh openssh-server locales curl

ARG user

RUN useradd -ms /bin/bash -u 1001 $user  

RUN mkdir /var/run/sshd && chmod 0750 /var/run/sshd 

COPY configurations/.dircolors /home/$user/.dircolors

COPY configurations/.gitconfig /home/$user/.gitconfig

COPY configurations/.tmux.conf /home/$user/.tmux.conf

# Configure timezone and locale
RUN echo "Europe/Helsinki" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_GB.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_GB.UTF-8

# Install and clean up build packages
RUN build_dependencies="curl unzip gettext pkg-config libtool-bin automake cmake build-essential" && \
   apt-get update && apt-get install -y $build_dependencies && \ 
   git clone https://github.com/neovim/neovim.git && \
   cd neovim && git checkout tags/v0.3.1 -b 0.3.1 && \
   make CMAKE_BUILD_TYPE=Release && \
   make install && \
   make clean && cd .. && rm -rf neovim && \
   apt-get remove -y $build_dependences && apt-get -y autoremove && apt-get -y autoclean

# fzf finder
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/$user/.fzf && \
    dos2unix /home/$user/.fzf/install && \ 
    chown $user:$user -R /home/$user/.fzf && \
    runuser -l $user -c "/home/$user/.fzf/install"

RUN mkdir /home/$user/.ssh && \ 
    printf 'TCPKeepAlive yes\nServerAliveInterval 30' >> /home/$user/.ssh/config 

# X11
RUN echo X11Forwarding yes >> /etc/ssh/sshd_config && \
    echo X11UseLocalhost yes >> /etc/sshsshd_config && \ 
    echo AddressFamily inet >> /etc/ssh/sshd_config 

# VIM Customization
# Global configuration
#COPY configurations/vimrc.local /etc/vim/vimrc.local

# User-only configuration, packages can be freely installed
COPY configurations/vimrc.local /home/$user/.vimrc

    
RUN chown -R $user:$user /home/$user

COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
