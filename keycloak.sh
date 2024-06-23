#!/bin/bash
#hostnamectl set-hostname keycloak.technobrain.com

#git clone https://github.com/ArnodTOTO/Mariadb-galera-maxscale.git



groupadd -r keycloak
useradd -m -d /var/lib/keycloak -s /sbin/nologin -r -g keycloak keycloak

mkdir -p /opt/keycloak
cd /opt/keycloak
wget https://github.com/keycloak/keycloak/releases/download/25.0.1/keycloak-25.0.1.zip
unzip keycloak-25.0.1.zip

cd /opt

chown -R keycloak. keycloak
chmod o+x /opt/keycloak/keycloak-25.0.1/bin/

dnf -y install java-21-openjdk

dnf install -y postgresql-server glibc-all-langpacks

postgresql-setup --initdb
systemctl start postgresql
systemctl enable postgresql

su postgres << EOF
psql
create user keycloak with password 'keycloak';
create database keycloak owner keycloak;
grant all privileges on database keycloak to keycloak;
\q
exit
EOF

#vim /var/lib/pgsql/data/pg_hba.conf
mv /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.old
cp /home/toto/Mariadb-galera-maxscale/keycloak/pg_hba.conf /var/lib/pgsql/data/ 
systemctl restart postgresql.service

#openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /opt/keycloak/keycloak-25.0.1/conf/server.key.pem -out /opt/keycloak/keycloak-25.0.1/conf/server.crt.pem

cp /home/toto/Mariadb-galera-maxscale/keycloak/server.key.pem /opt/keycloak/keycloak-25.0.1/conf/
cp /home/toto/Mariadb-galera-maxscale/keycloak/server.crt.pem /opt/keycloak/keycloak-25.0.1/conf/

chown keycloak. /opt/keycloak/keycloak-25.0.1/conf/server*

#vim /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf
mv /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf.old
cp /home/toto/Mariadb-galera-maxscale/keycloak/keycloak.conf /opt/keycloak/keycloak-25.0.1/conf/

firewall-cmd --permanent --zone=public --add-port=8443/tcp
firewall-cmd --reload

export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=Spart-08

/opt/keycloak/keycloak-25.0.1/bin/kc.sh build
/opt/keycloak/keycloak-25.0.1/bin/kc.sh start



