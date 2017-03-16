FROM centos:7

RUN set -x \
        && curl -fLo /etc/yum.repos.d/yarn.repo https://dl.yarnpkg.com/rpm/yarn.repo \
        && curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -

RUN set -x \
        && yum install -y git \
        vim \
        screen \
        tree \
        telnet \
        which \
        mariadb \
        yarn \
        && ln -f -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV USERDIR /home/development

#ENV USER_NAME user1
#ENV USER_HOME /home/$USER_NAME

# Create a run user
#RUN useradd -m $USER_NAME
RUN mkdir -p ${USERDIR}
WORKDIR ${USERDIR}

# Add init files
ADD .aliases .bashrc .screenrc .vimrc .zshrc .shrc_common ${USERDIR}/

# Add vim plugins
RUN git clone https://github.com/Shougo/neobundle.vim ${USERDIR}/.vim/bundle/neobundle.vim
RUN curl -fLo ${USERDIR}/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Add anyenv
ENV ANYENV_ROOT=${USERDIR}/.anyenv
RUN git clone https://github.com/riywo/anyenv ${ANYENV_ROOT}

CMD bash --rcfile ${USERDIR}/.bashrc
