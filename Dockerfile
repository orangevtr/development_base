FROM centos:7

# Install prerequisites
RUN set -x \
        && curl -fLo /etc/yum.repos.d/yarn.repo https://dl.yarnpkg.com/rpm/yarn.repo \
        && curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -

RUN yum install -y gcc make sudo file git vim screen tree telnet which mariadb yarn wget bzip2 readline-devel openssh-server openssl-devel openssl-libs

# Setup timezone
RUN ln -f -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

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
