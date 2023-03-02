FROM ubuntu:22.04

# Variables
ARG REPO_DIR=/var/www/html/git-repo
ARG USER_REPO_DIR=test.git
ARG USER=testuser
ARG PASSWORD=testing

# Install apt packages to be used for this
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    fcgiwrap spawn-fcgi apache2-utils unzip nginx git openssh-server acl \
    && rm -rf /var/lib/apt/lists/*

# Create a "testuser" for SSH, and assign both this and the "www-data" system
# account to a group called "git".
RUN useradd -ms /bin/bash testuser \
    && addgroup git \
    && usermod -a -G git testuser \
    && usermod -a -G git www-data

# Set up repo directories.  The user repo directory will always be writable
# by a user in the "git" group.  This lets us write to the repo using both HTTP
# and SSH.
RUN mkdir -p ${REPO_DIR}/${USER_REPO_DIR} \
    && chgrp git ${REPO_DIR}/${USER_REPO_DIR} \
    && chmod g+s ${REPO_DIR}/${USER_REPO_DIR} \
    && setfacl -m "default:group::rwx" ${REPO_DIR}/${USER_REPO_DIR} \
    && cd ${REPO_DIR}/${USER_REPO_DIR} \
    && git --bare init \
    && git update-server-info \
    && chmod -R 755 ${REPO_DIR} \
    && htpasswd -b -c ${REPO_DIR}/htpasswd ${USER} ${PASSWORD} \
    && ln -s ${REPO_DIR}/${USER_REPO_DIR} /${USER_REPO_DIR}

# Push configuration files for both HTTP and SSH
ADD nginx-default /etc/nginx/sites-available/default
ADD git.conf /etc/nginx/conf.d/git.conf
ADD ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key
ADD sshd_config /etc/ssh/sshd_config

# Set user SSH keys
ADD ssh_user_key /ssh_user_key
ADD ssh_user_key.pub /ssh_user_key.pub
RUN chmod 400 /etc/ssh/ssh_host_rsa_key \
    && mkdir -p /home/${USER}/.ssh \
    && chmod 700 /home/${USER}/.ssh \
    && cp /ssh_user_key.pub /home/${USER}/.ssh/authorized_keys \
    && chmod 400 /home/${USER}/.ssh/authorized_keys \
    && chown -R ${USER}:${USER} /home/${USER}

# Our entrypoint runner
ADD run.sh /run.sh
RUN chmod 755 /run.sh

EXPOSE 81
EXPOSE 22

CMD /run.sh
