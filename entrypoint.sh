#!/bin/bash

user=plainbash
# Retrieving user id to use it in chown commands instead of the user name
# to avoid problems on alpine when the user name contains a '.'
uid="$(id -u $user)"

# Add SSH keys to authorized_keys with valid permissions
if [ -d /home/$user/ssh_keys ]; then
	for publickey in /home/$user/ssh_keys/*; do
		cat $publickey >> /home/$user/.ssh/authorized_keys
	done
	chown $uid /home/$user/.ssh/authorized_keys
	chmod 600 /home/$user/.ssh/authorized_keys
fi

# Run ssh server
/usr/sbin/sshd -D
