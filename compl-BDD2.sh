#!/bin/bash
echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts

firewall-cmd --permanent --add-service=galera
firewall-cmd --reload

mkdir -p /etc/yum.repos.d/old
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/

mv /home/toto/*.repo /etc/yum.repos.d/

dnf update -y
dnf install -y sshpass
dnf install -y mariadb-server

#mv /etc/my.cnf.d/galera.cnf /etc/my.cnf.d/galera.cnf.old
sshpass -p toto scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/conf/BDD2/galera.cnf /etc/my.cnf.d/

systemctl enable --now mariadb

mysql -u root -p "Spart-08" << EOF
show global status like 'wsrep_cluster_size';
exit
EOF