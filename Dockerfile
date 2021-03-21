FROM ubuntu:focal

########################################################
# Essential packages for remote debugging and login in
########################################################

ARG DEBIAN_FRONTEND='noninteractive'
ENV TZ='America/Los_Angeles'
RUN apt-get update
RUN apt-get -y install \
    apt-transport-https \
    build-essential \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    manpages-dev \
    software-properties-common \
    wget

RUN echo \
      "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" \
      | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN wget -O - 'https://apt.kitware.com/keys/kitware-archive-latest.asc' 2>/dev/null \
    | gpg --dearmor - \
    | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

RUN curl -fsSL 'https://download.docker.com/linux/ubuntu/gpg' \
    | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

RUN apt-add-repository -y -u ppa:longsleep/golang-backports \
    && apt-add-repository -y -u ppa:deadsnakes/ppa \
    && apt-key adv --keyserver 'keyserver.ubuntu.com' --recv-key 'C99B11DEB97541F0' \
    && apt-add-repository -y -u 'https://cli.github.com/packages' \
    && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main'

RUN curl -sL 'https://deb.nodesource.com/setup_15.x' | bash -

RUN apt update && apt-get install -y \
        apt-utils \
        default-jdk \
        cmake \
        curl \
        docker-ce \
        docker-ce-cli \
        gcc-multilib \
        gdb \
        gh \
        gnupg \
        golang \
        make \
        neovim \
        ssh \
        python3 \
        rsync \
        tzdata \
        wget \
        zsh

RUN mkdir /var/run/sshd \
        && echo 'root:root' | chpasswd \
        && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
        && sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd \
        && chsh -s '/bin/zsh' \
        && update-alternatives --set editor /usr/bin/nvim \
        && update-alternatives --install /usr/bin/python python /usr/bin/python3 100


ADD "https://github.com/austintraver.keys" "/root/.ssh/authorized_keys"
ADD "https://weiwei.page.link/zshrc" "/root/.zshrc"

# 22 for ssh server
EXPOSE 22

########################################################
# Add custom packages and development environment here
########################################################

########################################################

#ENTRYPOINT ["/bin/zsh", "-o", "pipefail", "-c"]
CMD ["/usr/sbin/sshd", "-D"]
