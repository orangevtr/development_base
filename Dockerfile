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

# Add init files
# [TODO] replace by cloning dotfiles
ADD .aliases .bashrc .screenrc .vimrc .zshrc .shrc_common ${HOME}/

# vim
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install vimproc before installing modules with neobundle
# c.f. https://github.com/Shougo/vimproc.vim#manual-install
RUN git clone https://github.com/Shougo/vimproc.vim ~/.vim/bundle/vimproc.vim
RUN cd ~/.vim/bundle/vimproc.vim && make
RUN for d in autoload lib plugin; do mkdir -p ~/.vim/$d; cp -pr ~/.vim/bundle/vimproc.vim/$d/* ~/.vim/$d; done

# install packages with neobundle
RUN git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
RUN ~/.vim/bundle/neobundle.vim/bin/neoinstall

# volumes
USER orangevtr
RUN mkdir ~/workspace

# Add anyenv
RUN git clone https://github.com/riywo/anyenv ~/.anyenv

# rbenv
RUN bash -l -c "anyenv install rbenv"
RUN bash -l -c "rbenv install 2.4.0"

# node.js
RUN bash -l -c "anyenv install ndenv"
RUN bash -l -c "ndenv install v6.10.0"

# tmp
RUN mkdir -p ~/tmp

# ssh
USER root
EXPOSE 22
RUN ssh-keygen -A
CMD ["/usr/sbin/sshd", "-D"]
