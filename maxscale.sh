#!/bin/bash

source /root/env_password_maxscale

echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts


dnf update -y
dnf install -y sshpass
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
dnf install -y maxscale


sshpass -p "${password_toto}" ssh -o StrictHostKeyChecking=no toto@BDD1 << EOF1
mysql -u root -p${root_pass_mysql} << EOF2
show global status like 'wsrep_cluster_size';
create user 'maxscale'@'%' identified by 'Maxadmin-69';
grant select on mysql.* to 'maxscale'@'%';
GRANT SHOW DATABASES, BINLOG ADMIN, READ ONLY ADMIN, RELOAD, REPLICATION MASTER ADMIN, REPLICATION SLAVE ADMIN, REPLICATION SLAVE, SLAVE MONITOR ON *.* TO 'maxscale'@'%';
create database projet42;
create user userjovan@'%' identified by 'Userjovan-69';
GRANT ALL ON projet42.* TO userjovan@'%' identified by 'Userjovan-69';
flush privileges;
exit
EOF2
exit
EOF1


mv /etc/maxscale.cnf /etc/maxscale.cnf.old
sshpass -p ${password_toto} scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/conf/Maxscale/maxscale.cnf /etc/

systemctl enable --now maxscale
firewall-cmd --permanent --add-port={8989,3306}/tcp

firewall-cmd --reload

maxctrl create user "maxadmin" "${maxscale_pass}" --type=admin