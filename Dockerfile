FROM alpine:3.12

ENV LANG=ru_RU.UTF-8 \
LANGUAGE=ru_RU.UTF-8 \
ROOT_PASS=qwe123 \
WEBMIN_USERNAME=admin \
WEBMIN_PASSWORD=webmin \
WEBMIN_VERSION=1.954 \
NOPRIVUSER=False \
NOPRIVUSER_NAME=user \
NOPRIVUSER_GID=1000 \
NOPRIVUSER_UID=1000 \
NOPRIVUSER_PASS=qwe123

RUN apk add --update at gzip curl rsync jq git dcron wget procps bash nano openssh tzdata sudo htop ca-certificates supervisor openssl perl perl-net-ssleay expect coreutils mysql-client postgresql-client python3 \
&& cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
&& echo "Europe/Moscow" > /etc/timezone \
&& apk del tzdata

ADD conf/entrypoint.sh /entrypoint.sh
ADD conf/install.exp /install.exp
#pass
RUN echo -n root:$ROOT_PASS | chpasswd \
&& chmod 755 /entrypoint.sh

#configure and run supervisor
RUN mkdir -p /etc/supervisor.d && mkdir -p /var/log/webmin
ADD conf/crond.ini /etc/supervisor.d/crond.ini
ADD conf/webmin.ini /etc/supervisor.d/webmin.ini
ADD conf/sshd.ini /etc/supervisor.d/sshd.ini
ADD conf/ssh/sshd_config /etc/sshd_config
RUN chmod 600 /etc/sshd_config

VOLUME	["/etc/webmin" , "/opt", "/var/spool/cron", "/etc/crontabs", "/etc/periodic", "/root/.ssh", "/etc/ssh"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
ENTRYPOINT ["/entrypoint.sh"]
