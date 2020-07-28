FROM python:3.7-alpine

LABEL "com.github.actions.name"="molecule"
LABEL "com.github.actions.description"="Run Ansible Molecule"
LABEL "com.github.actions.icon"="upload"
LABEL "com.github.actions.color"="green"

ARG BUILD_DEPS="\
    gcc \
    libc-dev \
    make \
    musl-dev \
    libffi-dev \
    openssl-dev \
    "

ARG PACKAGES="\
    docker \
    git \
    openssh-client \
    "

ARG PIP_INSTALL_ARGS="\
    --no-cache-dir \
    "

# ARG PIP_MODULES="\
#     netaddr \
#     "

ARG MOLECULE_EXTRAS="docker"

RUN apk add --update --no-cache ${BUILD_DEPS} ${PACKAGES} && \
    pip install ${PIP_INSTALL_ARGS} ${PIP_MODULES} "molecule[${MOLECULE_EXTRAS}]" && \
    apk del --no-cache ${BUILD_DEPS} && \
    rm -rf /root/.cache

# CMD cd ${GITHUB_REPOSITORY}; molecule ${INPUT_MOLECULE_OPTIONS} ${INPUT_MOLECULE_COMMAND} ${INPUT_MOLECULE_ARGS}
# Adding systemd compatibility.
COPY . /wazuh-ansible
WORKDIR /wazuh-ansible

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

