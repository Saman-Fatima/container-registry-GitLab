ARG FROM=debian:buster-slim
FROM ${FROM}

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_VERSION="2.26.2"
ARG DOCKER_COMPOSE_VERSION="1.27.4"
ARG USER_HOME

ENV GITHUB_ACCESS_TOKEN=""
ENV AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache


RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y \
        curl \
        unzip \
        apt-transport-https \
        ca-certificates \
        software-properties-common \
        sudo \
        supervisor \
        jq \
        iputils-ping \
        build-essential \
        zlib1g-dev \
        chrpath cpio diffstat gawk wget locales python3-distutils rsync expect \
        gettext \
        liblttng-ust0 \
        libcurl4-openssl-dev \
        texinfo gcc-multilib socat cpio  xz-utils debianutils libsdl1.2-dev xterm autoconf libtool libglib2.0-dev \
        libarchive-dev sed cvs subversion coreutils texi2html docbook-utils python-pysqlite2 help2man make gcc g++ \
        desktop-file-utils libgl1-mesa-dev libglu1-mesa-dev mercurial automake groff curl lzop asciidoc u-boot-tools \
        dos2unix mtd-utils pv libncurses5 libncurses5-dev libncursesw5-dev libelf-dev zlib1g-dev bc rename \
        openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod 644 /etc/supervisor/conf.d/supervisord.conf

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o- | sh && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Install Docker-Compose
RUN curl -L -o /usr/local/bin/docker-compose \
    "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" && \
    chmod +x /usr/local/bin/docker-compose

RUN cd /tmp && \
    curl -sL -o git.tgz \
    https://www.kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.gz && \
    tar zxf git.tgz  && \
    cd git-${GIT_VERSION}  && \
    ./configure --prefix=/usr  && \
    make && \
    make install && \
    rm -rf /tmp/*



# Setting locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en     

# create non-root user for yocto-build
RUN useradd -u 1022 -g users -d /home/nonroot -s /bin/bash -p $(echo mypasswd | openssl passwd -1 -stdin) nonroot
RUN usermod -aG sudo nonroot
# RUN chown nonroot /home/nonroot/


# COPY id_rsa /home/nonroot/.ssh/id_rsa
COPY entrypoint.sh /home/nonroot/
RUN echo mypasswd | sudo -S chmod +x /home/nonroot/entrypoint.sh  
# RUN chmod +r /home/nonroot/.ssh/id_rsa

ENTRYPOINT ["/home/nonroot/entrypoint.sh"]
USER nonroot
WORKDIR /home/nonroot
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
