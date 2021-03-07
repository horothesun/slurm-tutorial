FROM docker-slurm:latest

#RUN groupadd -r mysql && useradd -r -g mysql mysql
RUN yum -y install mariadb-server mariadb-client
# TODO: add `mariadb-libs` to the line above if `sacct` doesn't work
#EXPOSE 3306
ADD deploy.sh /root/deploy.sh
RUN chmod +x /root/deploy.sh

#COPY server.cnf /etc/my.cnf.d/server.cnf

# MariaDB volume and go
#VOLUME /var/lib/mysql
#ADD docker-entrypoint.sh /root/
#RUN chmod +x /root/docker-entrypoint.sh

ADD launch_DB.sh /opt/slurm-17.11.9/
ADD slurmdbd.conf /usr/local/etc/
ADD supervisord.slurmctld /etc/supervisord.d/slurmctld.ini
#ADD supervisord.slurmdbd /etc/supervisord.d/slurmdbd.ini
#ADD supervisord.mariadb /etc/supervisord.d/mariadb.ini

EXPOSE 3306 22
#ENTRYPOINT ["/root/docker-entrypoint.sh"]
#CMD ["mysqld"]
CMD ["/bin/bash","/root/deploy.sh"]
#CMD /usr/bin/supervisord
#CMD ["sh", "-c", "exec /usr/sbin/slurmctld"]
