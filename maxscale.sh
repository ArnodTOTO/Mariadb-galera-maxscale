#!/bin/bash
echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts


mkdir -p /etc/yum.repos.d/old
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/

mv /home/toto/*.repo /etc/yum.repos.d/


dnf update -y
dnf install -y sshpass
dnf install -y maxscale

sshpass -p "toto" ssh -o StrictHostKeyChecking=no -T toto@BDD1 << 'EOF1'
mysql -u root -pSpart-08 << 'EOF2'
show global status like 'wsrep_cluster_size';
create user 'maxscale'@'%' identified by '123';
grant select on mysql.* to 'maxscale'@'%';
GRANT SHOW DATABASES, BINLOG ADMIN, READ ONLY ADMIN, RELOAD, REPLICATION MASTER ADMIN, REPLICATION SLAVE ADMIN, REPLICATION SLAVE, SLAVE MONITOR ON *.* TO 'maxscale'@'%';
create user ahmer@'%' identified by '123';
grant show databases on *.* to ahmer@'%';
flush privileges;
exit
EOF2
exit
EOF1

mv /etc/maxscale.cnf /etc/maxscale.cnf.old
sshpass -p toto scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/conf/Maxscale/maxscale.cnf /etc/

systemctl enable --now maxscale
firewall-cmd --permanent --add-port={8989,3306}/tcp

firewall-cmd --reload

maxctrl create user "maxadmin" "123" --type=admin