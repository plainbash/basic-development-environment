FROM debian:9.5

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	apt-get install -y git tmux vim dos2unix ssh  openssh-server locales

RUN useradd -ms /bin/bash -u 1001 plainbash && \
	adduser plainbash sudo

RUN mkdir /var/run/sshd && chmod 0750 /var/run/sshd

COPY configurations/.dircolors /home/plainbash/.dircolors

COPY configurations/.gitconfig /home/plainbash/.gitconfig

COPY configurations/.tmux.conf /home/plainbash/.tmux.conf

# The secrets directory must be manually created
COPY secrets/authorized_keys /home/plainbash/.ssh/authorized_keys

# Use this for debuging
# COPY secrets/authorized_keys /root/.ssh/authorized_keys

# Configure timezone and locale
RUN echo "Europe/Helsinki" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="nb_NO.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=nb_NO.UTF-8


CMD ["/usr/sbin/sshd", "-D"]
