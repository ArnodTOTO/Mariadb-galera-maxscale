#!/bin/bash
#url: https://itdraft.ru/2022/08/29/ustanovka-keycloak-i-postgesql-v-linux-centos-rocky-debian/
#hostnamectl set-hostname keycloak.technobrain.com

#git clone https://github.com/ArnodTOTO/Mariadb-galera-maxscale.git
export KEYCLOAK_ADMIN=admin
export KEYCLOAK_ADMIN_PASSWORD=Spart-08

echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts
echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts

mkdir -p /etc/yum.repos.d/old
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/

mv /home/toto/*.repo /etc/yum.repos.d/

dnf update -y
dnf install -y sshpass

groupadd -r keycloak
useradd -m -d /var/lib/keycloak -s /sbin/nologin -r -g keycloak keycloak

mkdir -p /opt/keycloak
cd /opt/keycloak
#wget https://github.com/keycloak/keycloak/releases/download/25.0.1/keycloak-25.0.1.zip

sshpass -p toto scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/keycloak-25.0.1.zip ./
unzip keycloak-25.0.1.zip

cd /opt

chown -R keycloak. keycloak
chmod o+x /opt/keycloak/keycloak-25.0.1/bin/

dnf -y install java-21-openjdk

############ configuration de mariadb ###############
sshpass -p "toto" ssh -o StrictHostKeyChecking=no -T toto@BDD1 << 'EOF1'
mysql -u root -pSpart-08 << 'EOF2'
CREATE DATABASE keycloak;
GRANT ALL ON keycloak.* TO keycloak@'%' identified by 'keycloak';
flush privileges;
exit
EOF2
exit
EOF1

#openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout /opt/keycloak/keycloak-25.0.1/conf/server.key.pem -out /opt/keycloak/keycloak-25.0.1/conf/server.crt.pem

sshpass -p toto scp toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/keycloak/server.key.pem /opt/keycloak/keycloak-25.0.1/conf/
sshpass -p toto scp toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/keycloak/server.crt.pem /opt/keycloak/keycloak-25.0.1/conf/

chown keycloak. /opt/keycloak/keycloak-25.0.1/conf/server*

#vim /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf
mv /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf /opt/keycloak/keycloak-25.0.1/conf/keycloak.conf.old
sshpass -p toto scp toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/keycloak/keycloak.conf /opt/keycloak/keycloak-25.0.1/conf/

firewall-cmd --permanent --zone=public --add-port=8443/tcp
firewall-cmd --reload


/opt/keycloak/keycloak-25.0.1/bin/kc.sh build
#/opt/keycloak/keycloak-25.0.1/bin/kc.sh start

sshpass -p toto scp toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/keycloak/keycloak.service /etc/systemd/system/

systemctl daemon-reload
systemctl start keycloak
systemctl enable keycloak
systemctl status keycloak

