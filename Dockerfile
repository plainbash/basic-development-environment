FROM debian:9.5

RUN apt-get update && \
	apt-get dist-upgrade -y && \
	apt-get install -y git tmux vim dos2unix ssh  openssh-server locales

RUN useradd -ms /bin/bash -u 1001 plainbash  

RUN mkdir /var/run/sshd && chmod 0750 /var/run/sshd

COPY configurations/.dircolors /home/plainbash/.dircolors

COPY configurations/.gitconfig /home/plainbash/.gitconfig

COPY configurations/.tmux.conf /home/plainbash/.tmux.conf

# The secrets directory must be manually created
#COPY secrets/authorized_keys /home/plainbash/.ssh/authorized_keys

# Use this for debuging
# It is probably ok if the SSH key is protected by passphrase
# COPY secrets/authorized_keys /root/.ssh/authorized_keys

# Configure timezone and locale
RUN echo "Europe/Helsinki" > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata && \
    sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_GB.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_GB.UTF-8

RUN mkdir /home/plainbash/.ssh && chown -R plainbash:plainbash /home/plainbash

COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
