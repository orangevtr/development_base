FROM ubuntu:latest

# Install prerequisites
RUN set -x \
        && apt-get update \
        && apt-get install -y gcc make sudo vim screen tree telnet mysql-client \
        wget bzip2 openssh-server git \
        curl apt-transport-https libssl-dev libreadline-dev zlib1g-dev

# Install YARN
RUN set -x \
        && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
        && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
        && apt-get update \
        && apt-get install -y yarn 

# Setup timezone
RUN ln -f -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# Setup locale
RUN set -x \
        && apt-get install -y language-pack-ja \
        && update-locale LANG=ja_JP.UTF-8

ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8

# sshd config
RUN perl -i -ple 's{(session.*)required(.*pam_loginuid.so)}{$1optional$2}' /etc/pam.d/sshd
RUN mkdir /var/run/sshd

# user
RUN echo 'root:root' | chpasswd
RUN useradd -m orangevtr \
        && echo "orangevtr ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
        && echo 'orangevtr:orangevtr' | chpasswd

USER orangevtr
ENV HOME /home/orangevtr
WORKDIR /home/orangevtr

# volumes
USER orangevtr
RUN mkdir ~/workspace

# Setup dotfiles and bootstrap
RUN git clone https://github.com/orangevtr/dotfiles.git ~/.dotfiles
RUN ~/.dotfiles/bootstrap.sh
RUN cd ~/.dotfiles && git remote set-url origin github-mine:orangevtr/dotfiles.git

# ssh
USER root
EXPOSE 22
RUN ssh-keygen -A
CMD ["/usr/sbin/sshd", "-D"]
