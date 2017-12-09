FROM debian:wheezy
MAINTAINER Karl Hepworth

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       sudo \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean

# Install Ansible via pip.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential libffi-dev libssl-dev python-dev \
       zlib1g-dev libncurses5-dev systemd python-setuptools curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \

# Unfortunately, PIP 1.x simply won't do anymore...
RUN curl https://bootstrap.pypa.io/get-pip.py | python && \
    pip install urllib3 pyOpenSSL ndg-httpsclient pyasn1 cryptography
RUN pip install ansible

# General clean-up
RUN apt-get clean

COPY initctl_faker .
RUN chmod +x initctl_faker && rm -fr /sbin/initctl && ln -s /initctl_faker /sbin/initctl

# Install Ansible inventory file
RUN mkdir -p /etc/ansible \
    && echo "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

# Installs nodejs
RUN apt-get install curl --yes && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y nodejs
RUN node --version
RUN npm --version

# Report some information
RUN python --version
RUN ansible --version