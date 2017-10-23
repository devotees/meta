#!/bin/bash

function cleanup {
    rm -rf ~/wemux
}
trap cleanup EXIT

create_devotee () {
    # create user
    dev=$1
    DATEHASH=`echo "$dev $(date)" | md5sum`
    P=${DATEHASH:1:8}
    printf "$P\n$P\n" | adduser $dev --gecos ''
    echo $dev password is $P

    # add to groups
    usermod -aG sudo $dev
    usermod -aG devotees $dev
}

apt-get update && apt-get install -y tmux git vim irssi

addgroup devotees

for devname in $* ; do create_devotee $devname ; done

# allow devotees to log-in with ssh
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# wemux initial setup
if [ ! -d /usr/local/share/wemux ] ; then
  git clone https://github.com/zolrath/wemux.git
  mv -f wemux /usr/local/share/
  ln -sf /usr/local/share/wemux/wemux /usr/local/bin/wemux
  cp /usr/local/share/wemux/wemux.conf.example /usr/local/etc/wemux.conf
  cat <<HERE >> /usr/local/etc/wemux.conf
host_groups=devotees
default_client_mode=rogue
allow_server_change=true
options=-u
HERE
fi


