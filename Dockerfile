FROM alpine:3.10

ENV OPENSSH_VERSION=8.0_p1-r0
ENV SHADOW_VERSION=4.6-r2
ENV SUDO_VERSION=1.8.27-r0

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/v3.10/community" >> /etc/apk/repositories && \
    apk add --no-cache bash iptables ip6tables fail2ban python2 shadow@community=${SHADOW_VERSION} openssh=${OPENSSH_VERSION} openssh-sftp-server=${OPENSSH_VERSION} sudo=${SUDO_VERSION} && \
    sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

RUN sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd

COPY etc /etc
COPY entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1