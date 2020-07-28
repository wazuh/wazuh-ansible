FROM quay.io/ansible/molecule:2.20

VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock" ]

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
