#!/bin/bash

source /root/env_password_BDD

echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts

firewall-cmd --permanent --add-service=galera
firewall-cmd --reload


dnf update -y
dnf install -y sshpass
sshpass -p ${password_toto} scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/mariadb-10.5.25-rhel-9-x86_64-rpms.tar ./
tar xvf mariadb-10.5.25-rhel-9-x86_64-rpms.tar 
cd mariadb-10.5.25-rhel-9-x86_64-rpms/
./setup_repository

dnf install -y mariadb-server

#mv /etc/my.cnf.d/galera.cnf /etc/my.cnf.d/galera.cnf.old
sshpass -p ${password_toto} scp -o StrictHostKeyChecking=no toto@Depot.technobrain.com:~/Mariadb-galera-maxscale/conf/BDD2/galera.cnf /etc/my.cnf.d/

systemctl enable --now mariadb

mysql -u root -p${root_pass_msyql} << EOF
show global status like 'wsrep_cluster_size';
exit
EOF